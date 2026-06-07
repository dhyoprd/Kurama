import Foundation
import Testing
@testable import LevelZeroCore

@Suite struct RecoveryDetectorTests {
    static let base = Date(timeIntervalSince1970: 1_000_000)
    static func hours(_ h: Double) -> Date { base.addingTimeInterval(h * 3600) }

    // Behavior 1: well past 36h -> inactive.
    @Test func longGapIsInactive() {
        let s = RecoveryDetector.evaluate(lastActiveAt: Self.base, now: Self.hours(40))
        #expect(s == .inactive)
    }

    // Behavior 2: boundary around the 36h threshold (>= 36h = inactive).
    @Test(arguments: [
        (0.0, RecoveryStatus.active),
        (35.0, .active),
        (35.99, .active),
        (36.0, .inactive),   // exact threshold counts as inactive
        (48.0, .inactive),
    ])
    func thresholdBoundary(_ t: (Double, RecoveryStatus)) {
        let s = RecoveryDetector.evaluate(lastActiveAt: Self.base, now: Self.hours(t.0))
        #expect(s == t.1)
    }
}
