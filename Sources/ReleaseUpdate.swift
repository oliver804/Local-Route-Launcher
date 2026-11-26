import Foundation

/// Stable releases only; never treats a prerelease or an arbitrary URL as an update.
struct ReleaseVersion: Comparable, Equatable {
    let parts: [Int]
    init?(_ text: String) {
        let value = text.hasPrefix("v") ? String(text.dropFirst()) : text
        let fields = value.split(separator: ".", omittingEmptySubsequences: false)
        guard fields.count == 3, fields.allSatisfy({ !$0.isEmpty && $0.allSatisfy({ $0.isASCII && $0.isNumber }) && ($0.count == 1 || !$0.hasPrefix("0")) }),
              let major = Int(fields[0]), let minor = Int(fields[1]), let patch = Int(fields[2]) else { return nil }
        parts = [major, minor, patch]
    }
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.parts.lexicographicallyPrecedes(rhs.parts) }
}

struct ReleaseUpdate: Equatable {
    enum MacArchitecture: String, CaseIterable {
        case arm64, x86_64
        static var current: Self {
            #if arch(x86_64)
            return .x86_64
            #else
            return .arm64
            #endif
        }
    }
    static let repository = "https://github.com/oliver804/Local-Route-Launcher"
    static let releasesURL = URL(string: repository + "/releases")!
    static let apiURL = URL(string: "https://api.github.com/repos/oliver804/Local-Route-Launcher/releases/latest")!
    let version: String
    let url: URL
    let isNewer: Bool
    let downloadURL: URL?
    var availableDownload: URL? { isNewer ? downloadURL : nil }
    private struct Asset: Decodable { let name: String; let browser_download_url: String }
    private struct Payload: Decodable { let tag_name: String; let draft: Bool; let prerelease: Bool; let html_url: String; let assets: [Asset]? }
    static func parse(_ data: Data, current: String, architecture: MacArchitecture = .current) throws -> Self {
        let payload = try JSONDecoder().decode(Payload.self, from: data)
        guard !payload.draft, !payload.prerelease, let latest = ReleaseVersion(payload.tag_name), let installed = ReleaseVersion(current),
              payload.html_url == repository + "/releases/tag/" + payload.tag_name,
              let url = URL(string: payload.html_url) else { throw URLError(.cannotParseResponse) }
        let version = payload.tag_name.hasPrefix("v") ? String(payload.tag_name.dropFirst()) : payload.tag_name
        let name = "Local-Route-Launcher-\(version)-\(architecture.rawValue).dmg"
        let expected = repository + "/releases/download/" + payload.tag_name + "/" + name
        let asset = payload.assets?.first { $0.name == name && $0.browser_download_url == expected }
        return Self(version: payload.tag_name, url: url, isNewer: latest > installed, downloadURL: asset.flatMap { URL(string: $0.browser_download_url) })
    }
    static func fetch(current: String) async throws -> Self {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 20
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: apiURL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Local-Route-Launcher", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200, data.count <= 1_048_576 else { throw URLError(.badServerResponse) }
        return try parse(data, current: current)
    }
}

/// Third-party releases are independent of the launcher's GitHub updater.
enum TargetReleases {
    static let google = URL(string: "https://antigravity.google/download")!
    static let openAI = URL(string: "https://persistent.oaistatic.com/codex-app-prod/appcast.xml")!

    static func read(_ url: URL) async -> String? {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode == 200,
              http.url == url, data.count <= 4_000_000 else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func captures(_ pattern: String, in source: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: source, range: NSRange(source.startIndex..., in: source)).compactMap {
            Range($0.range(at: 1), in: source).map { String(source[$0]) }
        }
    }

    static func googleVersion(_ html: String, kind: ApplicationKind, platform: String) -> String? {
        let prefix = kind == .antigravity
            ? "https://storage.googleapis.com/antigravity-public/antigravity-hub/"
            : "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/"
        let file = kind == .antigravity ? "Antigravity.dmg" : "Antigravity%20IDE.dmg"
        let escape = NSRegularExpression.escapedPattern(for:)
        let pattern = #"href=""# + escape(prefix) + #"([0-9]+\.[0-9]+\.[0-9]+)-[0-9]+/"# + escape(platform + "/" + file) + #"""#
        let matches = Set(captures(pattern, in: html))
        guard matches.count == 1 else { return nil }
        return matches.first
    }

    static func chatGPTVersion(_ xml: String, architecture: String, system: OperatingSystemVersion) -> String? {
        let os = ReleaseVersion("\(system.majorVersion).\(system.minorVersion).\(system.patchVersion)")!
        return captures(#"(?s)<item>(.*?)</item>"#, in: xml).compactMap { item -> String? in
            guard !item.contains("<sparkle:channel"), !item.contains("<sparkle:maximumSystemVersion"),
                  captures(#"<sparkle:hardwareRequirements>([^<]+)"#, in: item) == [architecture],
                  let minimum = captures(#"<sparkle:minimumSystemVersion>([0-9.]+)</sparkle:minimumSystemVersion>"#, in: item).first,
                  let required = ReleaseVersion(minimum.split(separator: ".").count == 2 ? minimum + ".0" : minimum),
                  required <= os,
                  let version = captures(#"<sparkle:shortVersionString>([0-9.]+)</sparkle:shortVersionString>"#, in: item).first,
                  ReleaseVersion(version) != nil,
                  item.contains("enclosure url=\"https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-\(architecture)-\(version).zip\"")
            else { return nil }
            return version
        }.max { ReleaseVersion($0)! < ReleaseVersion($1)! }
    }

    static func supportsChatGPT(_ target: TargetApplication) -> Bool {
        guard target.identifier == "com.openai.codex",
              let archive = try? FileHandle(forReadingFrom: target.url.appendingPathComponent("Contents/Resources/app.asar"))
        else { return false }
        defer { try? archive.close() }
        // ASAR starts with Chromium Pickle lengths. Read the package entry only.
        do {
            guard let prefix = try archive.read(upToCount: 16), prefix.count == 16 else { return false }
            func length(at index: Int) -> UInt64 {
                (0..<4).reduce(0) { $0 | (UInt64(prefix[index + $1]) << ($1 * 8)) }
            }
            let headerSize = length(at: 4), jsonSize = length(at: 12)
            guard length(at: 0) == 4, headerSize <= 16_000_000,
                  headerSize >= 8, jsonSize <= headerSize - 8,
                  let header = try archive.read(upToCount: Int(jsonSize)),
                  let directory = try JSONSerialization.jsonObject(with: header) as? [String: Any],
                  let files = directory["files"] as? [String: Any],
                  let entry = files["package.json"] as? [String: Any],
                  let offset = (entry["offset"] as? String).flatMap(UInt64.init), offset <= 8_000_000_000,
                  let size = entry["size"] as? Int, (1...250_000).contains(size)
            else { return false }
            try archive.seek(toOffset: 8 + headerSize + offset)
            guard let data = try archive.read(upToCount: size),
                  let metadata = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return false }
            return metadata["codexBuildFlavor"] as? String == "prod"
                && metadata["codexSparkleFeedUrl"] as? String == openAI.absoluteString
        } catch { return false }
    }

    static func check() async -> [ApplicationKind: String] {
        async let html = read(google)
        async let xml = read(openAI)
        let architecture = ReleaseUpdate.MacArchitecture.current.rawValue
        var result: [ApplicationKind: String] = [:]
        if let html = await html {
            for kind in [ApplicationKind.antigravity, .antigravityIDE] {
                result[kind] = googleVersion(html, kind: kind, platform: architecture == "arm64" ? "darwin-arm" : "darwin-x64")
            }
        }
        if let xml = await xml {
            result[.chatgpt] = chatGPTVersion(xml, architecture: architecture, system: ProcessInfo.processInfo.operatingSystemVersion)
        }
        return result
    }

    static func officialPage(_ kind: ApplicationKind) -> URL {
        kind == .chatgpt ? URL(string: "https://chatgpt.com/download/")! : google
    }
}

enum TargetUpdateCopy {
    static func label(_ version: String, language: AppLanguage) -> String {
        let prefix: String = switch language {
        case .chinese: "更新到 "
        case .traditionalChinese: "更新至 "
        case .english: "Update to "
        case .russian: "Обновить до "
        case .persian: "به‌روزرسانی به "
        case .belarusian: "Абнавіць да "
        case .spanish: "Actualizar a "
        case .arabic: "التحديث إلى "
        case .portuguese: "Atualizar para "
        }
        return prefix + "\u{2066}" + version + "\u{2069}"
    }

    static func check(_ language: AppLanguage) -> String {
        switch language {
        case .chinese: "检查应用更新"
        case .traditionalChinese: "檢查應用程式更新"
        case .english: "Check app updates"
        case .russian: "Проверить обновления приложений"
        case .persian: "بررسی به‌روزرسانی برنامه‌ها"
        case .belarusian: "Праверыць абнаўленні праграм"
        case .spanish: "Buscar actualizaciones de aplicaciones"
        case .arabic: "التحقق من تحديثات التطبيقات"
        case .portuguese: "Procurar atualizações de aplicativos"
        }
    }
}


enum UpdateSchedule {
    static func isDue(at now: Date, after previous: Date, calendar: Calendar = .current) -> Bool {
        let hour = calendar.component(.hour, from: now)
        return (7..<22).contains(hour) && now.timeIntervalSince(previous) >= 6 * 60 * 60
    }
}
