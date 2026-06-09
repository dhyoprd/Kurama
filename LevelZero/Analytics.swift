import Foundation

/// Lightweight analytics (#24): logs the 12 product events to the console and
/// persists them to the analytics_events table (fire-and-forget).
enum Analytics {
    static func log(_ event: String, _ properties: [String: String] = [:]) {
        print("[analytics] \(event) \(properties)")
        Task { await record(event, properties) }
    }

    private struct EventRow: Encodable {
        let user_id: String
        let event: String
        let properties: [String: String]
    }

    private static func record(_ event: String, _ properties: [String: String]) async {
        guard let client = SupabaseManager.shared.client,
              let uid = try? await client.auth.session.user.id else { return }
        try? await client.from("analytics_events").insert(
            EventRow(user_id: uid.uuidString, event: event, properties: properties)
        ).execute()
    }
}
