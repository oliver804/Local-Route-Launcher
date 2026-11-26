using System.Diagnostics;
using System.Net.Http;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;

namespace LocalRouteLauncher;

public sealed partial class MainWindow
{
    private const string GoogleDownloads = "https://antigravity.google/download";
    private const string ChatGPTStore = "ms-windows-store://pdp/?ProductId=9PLM9XGG6VKS";
    private const string ChatGPTManifest = "https://persistent.oaistatic.com/codex-app-prod/windows-store-update.json";
    private static readonly HttpClient TargetUpdateClient = new(new HttpClientHandler { AllowAutoRedirect = false })
        { Timeout = TimeSpan.FromSeconds(12), MaxResponseContentBufferSize = 4_000_000 };
    private readonly Dictionary<string, (Version Version, string Label)> targetReleases = [];
    private readonly Dictionary<string, string> detectedUpdatePaths = [];
    private string TargetUpdatePath(string id)
    {
        var configured = Profile(id).ApplicationPath;
        return configured.Length == 0 ? detectedUpdatePaths.GetValueOrDefault(id, "") : configured;
    }
    private bool checkingTargets;
    private DateTime lastTargetCheck;

    private static Version? InstalledTargetVersion(TargetApp target, string path)
    {
        try
        {
            if (!WindowsPlatform.IsCompatible(path, target.Id)) return null;
            if (target.Id == "chatgpt")
            {
                // Compare Store package versions only within the matching public x64 package.
                var package = Regex.Match(path, @"(?:^|[\\/])OpenAI\.Codex_([0-9.]+)_x64__2p2nqsd0c76g0[\\/]", RegexOptions.IgnoreCase);
                return Version.TryParse(package.Groups[1].Value, out var version) ? version : null;
            }
            return Version.TryParse(FileVersionInfo.GetVersionInfo(path).ProductVersion, out var installed) ? installed : null;
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or ArgumentException) { return null; }
    }

    private string? TargetUpdate(TargetApp target)
    {
        if (!targetReleases.TryGetValue(target.Id, out var release)) return null;
        var installed = InstalledTargetVersion(target, TargetUpdatePath(target.Id));
        if (installed is null) return null;
        if (target.Id != "chatgpt" && installed.Revision == 0)
            installed = new Version(installed.Major, installed.Minor, installed.Build);
        return installed < release.Version ? release.Label : null;
    }

    private string TargetUpdateLabel(string version)
    {
        var prefix = settings.ResolvedLanguage switch {
            "zh-CN" => "更新到", "zh-TW" => "更新至", "ru" => "Обновить до", "fa" => "به‌روزرسانی به",
            "be" => "Абнавіць да", "es" => "Actualizar a", "ar" => "التحديث إلى", "pt" => "Atualizar para", _ => "Update to"
        };
        return $"{prefix} \u2066{version}\u2069";
    }

    private string CheckTargetUpdateLabel => settings.ResolvedLanguage switch {
        "zh-CN" => "检查应用更新", "zh-TW" => "檢查應用程式更新", "ru" => "Проверить обновления приложений",
        "fa" => "بررسی به‌روزرسانی برنامه‌ها", "be" => "Праверыць абнаўленні праграм", "es" => "Buscar actualizaciones de aplicaciones",
        "ar" => "التحقق من تحديثات التطبيقات", "pt" => "Procurar atualizações de aplicativos", _ => "Check app updates"
    };

    private Button TargetUpdateButton(TargetApp target, string version, bool compact = false)
    {
        var label = TargetUpdateLabel(version);
        var content = new StackPanel { Orientation = Orientation.Horizontal };
        content.Children.Add(UpdateGlyph());
        content.Children.Add(new TextBlock { Text = label });
        var button = new Button { Style = roundedButtonStyle, Content = content, ToolTip = label,
            Foreground = accent, Background = field, BorderThickness = new Thickness(0),
            FontSize = compact ? 9 : 11, Padding = new Thickness(4, 2, 4, 2), Margin = new Thickness(4, 0, 0, 0),
            VerticalAlignment = VerticalAlignment.Center };
        System.Windows.Automation.AutomationProperties.SetName(button, label);
        button.Click += (_, _) => {
            try { Process.Start(new ProcessStartInfo(target.Id == "chatgpt" ? ChatGPTStore : GoogleDownloads) { UseShellExecute = true }); }
            catch (System.ComponentModel.Win32Exception) { /* A missing handler should not affect the launcher. */ }
        };
        return button;
    }

    private async Task<string?> ReadTargetFeed(string url)
    {
        try { return await TargetUpdateClient.GetStringAsync(url, updateCancellation.Token); }
        catch (Exception ex) when (ex is HttpRequestException or OperationCanceledException) { return null; }
    }

    private async Task CheckTargetUpdates(bool force = false)
    {
        if (smoke || quitting || checkingTargets || (!force && DateTime.UtcNow - lastTargetCheck < TimeSpan.FromMinutes(15))) return;
        checkingTargets = true;
        try
        {
            var googleTask = ReadTargetFeed(GoogleDownloads);
            var chatTask = ReadTargetFeed(ChatGPTManifest);
            var discovery = await Task.WhenAll(TargetApp.All.Where(target => Profile(target.Id).ApplicationPath.Length == 0)
                .Select(async target => (target.Id, Paths: await WindowsPlatform.Discover(target.Id))));
            var google = await googleTask;
            var chat = await chatTask;
            if (quitting || updateCancellation.IsCancellationRequested) return;
            detectedUpdatePaths.Clear();
            foreach (var (id, paths) in discovery)
                if (paths.Length == 1) detectedUpdatePaths[id] = paths[0];
            targetReleases.Clear();
            if (google != null)
            {
                ReadGoogleRelease(google, "antigravity", "https://storage.googleapis.com/antigravity-public/antigravity-hub/", "Antigravity-x64.exe");
                ReadGoogleRelease(google, "antigravityIDE", "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/", "Antigravity%20IDE.exe");
            }
            if (chat != null)
            {
                try
                {
                    using var json = JsonDocument.Parse(chat);
                    var root = json.RootElement;
                    if (root.GetProperty("schemaVersion").GetInt32() == 1
                        && root.GetProperty("packageIdentity").GetString() == "OpenAI.Codex"
                        && root.GetProperty("storeProductId").GetString() == "9PLM9XGG6VKS"
                        && Version.TryParse(root.GetProperty("buildVersion").GetString(), out var build) && build.Revision >= 0
                        && Version.TryParse(root.GetProperty("releaseVersion").GetString(), out var release))
                        targetReleases["chatgpt"] = (build, release.ToString());
                }
                catch (Exception ex) when (ex is JsonException or KeyNotFoundException or InvalidOperationException or FormatException) { }
            }
            // Let an in-flight launch/save operation rebuild the main UI with the new results.
            if (!busy && !rebuilding)
            {
                drafts[settings.SelectedApplication] = (host.Text, port.Text);
                Build();
                RestoreDraft();
            }
            RefreshAuxiliaryWindows();
        }
        finally { checkingTargets = false; lastTargetCheck = DateTime.UtcNow; }
    }

    private void ReadGoogleRelease(string html, string id, string prefix, string file)
    {
        var pattern = "href=\"" + Regex.Escape(prefix) + @"([0-9]+\.[0-9]+\.[0-9]+)-[0-9]+/windows-x64/" + Regex.Escape(file) + "\"";
        var matches = Regex.Matches(html, pattern).Select(match => match.Groups[1].Value).Distinct().ToArray();
        if (matches.Length == 1 && Version.TryParse(matches[0], out var release))
            targetReleases[id] = (release, matches[0]);
    }
}
