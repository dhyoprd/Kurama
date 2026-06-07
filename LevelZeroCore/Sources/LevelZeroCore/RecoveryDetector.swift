import Foundation

// RecoveryDetector — anti-burnout inactivity check.
// Spec (design doc D): if a user goes >= 36h without activity, they are inactive.
//   The caller then resets the streak to 0 (no XP penalty) and gates the
//   dashboard to a single recovery quest.

public enum RecoveryStatus: Equatable, Sendable {
    case active
    case inactive
}

public enum RecoveryDetector {
    /// Inactivity threshold in seconds (36 hours).
    public static let inactivityThreshold: TimeInterval = 36 * 60 * 60

    public static func evaluate(lastActiveAt: Date, now: Date) -> RecoveryStatus {
        let elapsed = now.timeIntervalSince(lastActiveAt)
        return elapsed >= inactivityThreshold ? .inactive : .active
    }
}
