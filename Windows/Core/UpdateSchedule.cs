namespace LocalRouteLauncher;

public static class UpdateSchedule
{
    public static bool IsDue(DateTimeOffset now, DateTimeOffset previous) =>
        now.Hour is >= 7 and < 22 && now - previous >= TimeSpan.FromHours(6);
}
