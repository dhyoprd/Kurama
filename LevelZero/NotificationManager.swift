import Foundation
import UserNotifications

/// Local notifications (#22): daily/evening/boss reminders + rank-up, with a
/// configurable morning time and a global off switch (persisted in UserDefaults).
final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard

    var enabled: Bool {
        get { defaults.object(forKey: "notif_enabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "notif_enabled"); reschedule() }
    }
    var reminderHour: Int {
        get { defaults.object(forKey: "notif_hour") as? Int ?? 9 }
        set { defaults.set(newValue, forKey: "notif_hour"); reschedule() }
    }
    var reminderMinute: Int {
        get { defaults.object(forKey: "notif_minute") as? Int ?? 0 }
        set { defaults.set(newValue, forKey: "notif_minute"); reschedule() }
    }

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func reschedule() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_morning", "daily_evening", "weekly_boss"])
        guard enabled else { return }
        scheduleDaily(id: "daily_morning", title: "Your quests await", body: "Small actions, real XP.", hour: reminderHour, minute: reminderMinute)
        scheduleDaily(id: "daily_evening", title: "Finish strong", body: "Complete today's quests before midnight.", hour: 20, minute: 0)
        scheduleWeekly(id: "weekly_boss", title: "Weekly Boss", body: "Your boss ends Sunday. Conquer it!", weekday: 1, hour: 18, minute: 0)
    }

    func notifyRankUp(_ rank: String) {
        guard enabled else { return }
        add(id: "rankup_\(UUID().uuidString)", title: "RANK UP!",
            body: "You reached \(rank)-Rank. Your avatar evolves.",
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false))
    }

    private func scheduleDaily(id: String, title: String, body: String, hour: Int, minute: Int) {
        var dc = DateComponents(); dc.hour = hour; dc.minute = minute
        add(id: id, title: title, body: body, trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true))
    }

    private func scheduleWeekly(id: String, title: String, body: String, weekday: Int, hour: Int, minute: Int) {
        var dc = DateComponents(); dc.weekday = weekday; dc.hour = hour; dc.minute = minute
        add(id: id, title: title, body: body, trigger: UNCalendarNotificationTrigger(dateMatching: dc, repeats: true))
    }

    private func add(id: String, title: String, body: String, trigger: UNNotificationTrigger?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
