import Foundation

@main
enum UpdateTests {
    @MainActor static func main() async throws {
        var count = 0
        func check(_ value: Bool, _ note: String) { precondition(value, note); count += 1 }
        func payload(_ tag: String, draft: Bool = false, prerelease: Bool = false, url: String? = nil) throws -> Data {
            try JSONSerialization.data(withJSONObject: ["tag_name": tag, "draft": draft, "prerelease": prerelease,
                "html_url": url ?? ReleaseUpdate.repository + "/releases/tag/" + tag])
        }
        for value in ["1.4", "v1.4.1-beta", "1.4.1+build", "1.04.0", "-1.2.3", "1.2.3.4", "１.2.3", "1.2.99999999999999999999999999"] {
            check(ReleaseVersion(value) == nil, "Rejected invalid/staged version " + value)
        }
        check(ReleaseVersion("v1.10.0")! > ReleaseVersion("1.9.9")!, "Numeric, not lexical ordering")
        check(try ReleaseUpdate.parse(payload("v1.4.1"), current: "1.4.0").isNewer, "New stable version")
        check(try !ReleaseUpdate.parse(payload("v1.4.0"), current: "1.4.0").isNewer, "Same version")
        check(try !ReleaseUpdate.parse(payload("v1.3.0"), current: "1.4.0").isNewer, "Development version ahead of stable")
        for data in [try payload("v1.4.1", draft: true), try payload("v1.4.1", prerelease: true), try payload("v1.4.1", url: "https://example.com/download"), try payload("v1.4.1", url: ReleaseUpdate.repository + "/releases/tag/v1.4.1?redirect=elsewhere"), Data("{}".utf8)] {
            do { _ = try ReleaseUpdate.parse(data, current: "1.4.0"); preconditionFailure("Accepted untrusted release") }
            catch { count += 1 }
        }
        func installer(_ tag: String, name: String? = nil, url: String? = nil) throws -> Data {
            let filename = name ?? "Local-Route-Launcher-\(tag.dropFirst())-\(ReleaseUpdate.MacArchitecture.current.rawValue).dmg"
            var object = try JSONSerialization.jsonObject(with: payload(tag)) as! [String: Any]
            object["assets"] = [["name": filename, "browser_download_url": url ?? ReleaseUpdate.repository + "/releases/download/" + tag + "/" + filename]]
            return try JSONSerialization.data(withJSONObject: object)
        }
        let expectedDownload = ReleaseUpdate.repository + "/releases/download/v1.4.1/Local-Route-Launcher-1.4.1-\(ReleaseUpdate.MacArchitecture.current.rawValue).dmg"
        check(try ReleaseUpdate.parse(installer("v1.4.1"), current: "1.4.0").availableDownload?.absoluteString == expectedDownload, "Direct macOS installer URL")
        check(try ReleaseUpdate.parse(payload("v1.4.1"), current: "1.4.0").availableDownload == nil, "Hide release without installer")
        check(try ReleaseUpdate.parse(installer("v1.4.0"), current: "1.4.0").availableDownload == nil, "Hide current version")
        check(try ReleaseUpdate.parse(installer("v1.3.0"), current: "1.4.0").availableDownload == nil, "Hide older installer")
        check(try ReleaseUpdate.parse(installer("v1.4.1", name: "Local-Route-Launcher-1.4.1-windows-x64-setup.exe"), current: "1.4.0").availableDownload == nil, "Reject other platform")
        #if arch(x86_64)
        check(ReleaseUpdate.MacArchitecture.current == .x86_64, "Intel binary uses Intel updates")
        #else
        check(ReleaseUpdate.MacArchitecture.current == .arm64, "Apple Silicon binary uses arm64 updates")
        #endif
        var multiAsset = try JSONSerialization.jsonObject(with: payload("v1.4.1")) as! [String: Any]
        multiAsset["assets"] = ReleaseUpdate.MacArchitecture.allCases.map { arch in
            let name = "Local-Route-Launcher-1.4.1-\(arch.rawValue).dmg"
            return ["name": name, "browser_download_url": ReleaseUpdate.repository + "/releases/download/v1.4.1/" + name]
        }
        let bothMacs = try JSONSerialization.data(withJSONObject: multiAsset)
        for arch in ReleaseUpdate.MacArchitecture.allCases {
            let filename = "Local-Route-Launcher-1.4.1-\(arch.rawValue).dmg"
            let other: ReleaseUpdate.MacArchitecture = arch == .arm64 ? .x86_64 : .arm64
            check(try ReleaseUpdate.parse(bothMacs, current: "1.4.0", architecture: arch).availableDownload?.lastPathComponent == filename, "Select \(arch.rawValue) from a multi-platform release")
            check(try ReleaseUpdate.parse(installer("v1.4.1", name: filename), current: "1.4.0", architecture: other).availableDownload == nil, "Never offer the wrong Mac architecture")
            check(try ReleaseUpdate.parse(installer("v1.4.1", name: filename, url: "https://example.com/" + filename), current: "1.4.0", architecture: arch).availableDownload == nil, "Reject untrusted \(arch.rawValue) asset")
        }
        for badURL in ["https://example.com/setup.dmg", expectedDownload + "?redirect=elsewhere", expectedDownload.replacingOccurrences(of: "v1.4.1/", with: "v1.3.0/")] {
            check(try ReleaseUpdate.parse(installer("v1.4.1", url: badURL), current: "1.4.0").availableDownload == nil, "Reject mismatched installer")
        }
        let domain = "local.route.update-tests." + UUID().uuidString
        let defaults = UserDefaults(suiteName: domain)!
        defer { defaults.removePersistentDomain(forName: domain) }
        let model = UpdateModel(defaults: defaults, version: "1.4.0")
        check(model.automatic && model.release == nil && !model.checking, "No network on construction")
        model.automatic = false
        check(!UpdateModel(defaults: defaults, version: "1.4.0").automatic, "Persist startup opt-out")
        let release = try ReleaseUpdate.parse(payload("v1.4.1"), current: "1.4.0")
        await model.check { _ in release }
        check(model.release == release && !model.failed && !model.checking, "Success")
        await model.check { _ in throw URLError(.timedOut) }
        check(model.failed && model.release == nil && !model.checking, "Failure clears stale result")
        await model.check { _ in release }
        check(!model.failed && model.release == release, "Retry recovers")
        var calls = 0
        let first = Task { await model.check { _ in calls += 1; try await Task.sleep(nanoseconds: 100_000_000); return release } }
        await Task.yield()
        await model.check { _ in calls += 1; return release }
        _ = await first.value
        check(calls == 1, "Deduplicate concurrent checks")
        let stale = try ReleaseUpdate.parse(installer("v1.4.1"), current: "1.4.0")
        let latest = try ReleaseUpdate.parse(installer("v1.4.2"), current: "1.4.0")
        var opened: [URL] = []
        await model.check { _ in stale }
        await model.downloadLatest(fetch: { current in
            check(current == "1.4.0", "Recheck uses installed version")
            return latest
        }, open: { opened.append($0) })
        check(opened == [latest.availableDownload!], "Click downloads 1.4.2, not cached 1.4.1")
        check(model.release == latest, "Click refreshes shared badge state")
        for tag in ["v1.4.0", "v1.3.0", "v1.4.2"] {
            await model.check { _ in stale }; opened = []
            let data = try tag == "v1.4.2" ? payload(tag) : installer(tag)
            await model.downloadLatest(fetch: { _ in try ReleaseUpdate.parse(data, current: "1.4.0") }, open: { opened.append($0) })
            check(opened.isEmpty && model.release?.availableDownload == nil, "No fallback for current, older or missing installer")
        }
        for data in [Data("{}".utf8), try payload("v1.4.2", prerelease: true), try installer("v1.4.2", url: "https://example.com/setup.dmg")] {
            await model.check { _ in stale }; opened = []
            await model.downloadLatest(fetch: { _ in try ReleaseUpdate.parse(data, current: "1.4.0") }, open: { opened.append($0) })
            check(opened.isEmpty && model.release?.availableDownload == nil, "Reject invalid latest response without cached fallback")
        }
        for error in [URLError(.timedOut), URLError(.notConnectedToInternet), URLError(.badServerResponse)] {
            await model.check { _ in stale }; opened = []
            await model.downloadLatest(fetch: { _ in throw error }, open: { opened.append($0) })
            check(opened.isEmpty && model.failed && model.release == nil, "Fetch failure never opens stale installer")
        }
        // Hold the request open to reproduce rapid clicks from the main/menu controls.
        await model.check { _ in stale }; opened = []; calls = 0
        var resume: CheckedContinuation<ReleaseUpdate, Never>?
        let download = Task { await model.downloadLatest(fetch: { _ in
            calls += 1
            return await withCheckedContinuation { resume = $0 }
        }, open: { opened.append($0) }) }
        while resume == nil { await Task.yield() }
        check(model.checking, "Shared check remains in flight")
        await model.downloadLatest(fetch: { _ in calls += 1; return stale }, open: { opened.append($0) })
        check(calls == 1 && opened.isEmpty, "Concurrent click cannot use cached result")
        resume!.resume(returning: latest)
        await download.value
        check(opened == [latest.availableDownload!] && !model.checking, "One browser launch for concurrent clicks")
        // Even a fetch implementation that ignores cancellation cannot open a browser afterward.
        await model.check { _ in stale }; opened = []; resume = nil
        let cancelled = Task { await model.downloadLatest(fetch: { _ in
            await withCheckedContinuation { resume = $0 }
        }, open: { opened.append($0) }) }
        while resume == nil { await Task.yield() }
        cancelled.cancel(); resume!.resume(returning: latest)
        await cancelled.value
        check(opened.isEmpty && model.release == nil && !model.checking, "Cancelled refresh cannot download")
        print("PASS: \(count) update checks")
    }
}
