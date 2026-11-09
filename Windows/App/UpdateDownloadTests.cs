using System.Net.Http;

namespace LocalRouteLauncher;

public sealed partial class MainWindow
{
    // Installed-app smoke regression: exercise the same action used by main/tray buttons.
    // Injected responses and browser capture keep smoke runs completely offline.
    internal async Task VerifyUpdateDownloads()
    {
        if (!smoke) throw new InvalidOperationException("Smoke mode required");
        void Check(bool ok, string message) { if (!ok) throw new InvalidOperationException(message); }
        ReleaseUpdate Installer(string version) => ReleaseUpdate.Parse(System.Text.Json.JsonSerializer.Serialize(new {
            tag_name = "v" + version, draft = false, prerelease = false,
            html_url = ReleaseUpdate.Repository + "/releases/tag/v" + version,
            assets = new[] { new { name = $"Local-Route-Launcher-{version}-windows-x64-setup.exe",
                browser_download_url = ReleaseUpdate.Repository + $"/releases/download/v{version}/Local-Route-Launcher-{version}-windows-x64-setup.exe" } }
        }), Program.Version);
        var stale = Installer("99.0.0");
        var latest = Installer("99.0.1");
        var opened = new List<string>();
        updateRelease = stale;
        await DownloadUpdate((current, _) => {
            Check(current == Program.Version, "Refresh must use installed version");
            return Task.FromResult(latest);
        }, opened.Add);
        Check(opened.SequenceEqual(new[] { latest.AvailableDownload! }) && updateRelease == latest,
            "Click must download fresh release instead of cached badge release");

        foreach (var unavailable in new[] { latest with { DownloadUrl = null }, latest with { IsNewer = false },
            Installer(Program.Version), Installer("1.0.0") }) {
            updateRelease = stale; opened.Clear();
            await DownloadUpdate((_, _) => Task.FromResult(unavailable), opened.Add);
            Check(opened.Count == 0 && !UpdateAvailable, "Missing or non-new installer must never fall back");
        }
        foreach (var error in new Exception[] { new HttpRequestException("offline or rate limited"),
            new TaskCanceledException("timeout"), new System.Text.Json.JsonException("invalid response") }) {
            updateRelease = stale; opened.Clear();
            await DownloadUpdate((_, _) => Task.FromException<ReleaseUpdate>(error), opened.Add);
            Check(opened.Count == 0 && updateRelease == null && !updateChecking, "Failure must clear stale download");
        }

        updateRelease = stale; opened.Clear();
        var pending = new TaskCompletionSource<ReleaseUpdate>(TaskCreationOptions.RunContinuationsAsynchronously);
        int requests = 0;
        Task<ReleaseUpdate> Fetch(string _, CancellationToken token) { requests++; return pending.Task; }
        var first = DownloadUpdate(Fetch, opened.Add);
        Check(updateChecking && !UpdateAvailable, "Hide badge during refresh");
        await DownloadUpdate(Fetch, opened.Add);
        Check(requests == 1 && opened.Count == 0, "Concurrent click cannot open cached installer");
        pending.SetResult(latest);
        await first;
        Check(opened.SequenceEqual(new[] { latest.AvailableDownload! }), "Concurrent clicks open browser once");

        // Cancel the lifetime token last; subsequent smoke checks do not request updates.
        updateRelease = stale; opened.Clear();
        pending = new TaskCompletionSource<ReleaseUpdate>(TaskCreationOptions.RunContinuationsAsynchronously);
        var cancelled = DownloadUpdate(Fetch, opened.Add);
        updateCancellation.Cancel();
        pending.SetResult(latest);
        await cancelled;
        Check(opened.Count == 0 && updateRelease == null && !updateChecking, "No download after cancellation");
    }
}
