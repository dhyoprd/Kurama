import Foundation
import Testing
@testable import LevelZeroCore

@Suite struct WeeklyBossLifecycleTests {
    static let weekStart = Date(timeIntervalSince1970: 1_700_000_000) // treat as Monday 00:00
    static func day(_ d: Double) -> Date { weekStart.addingTimeInterval(d * 24 * 3600) }

    // Behavior 1: conquer before the deadline -> completed + reward.
    @Test func conquerBeforeDeadlineRewards() {
        let s = BossState(weekStart: Self.weekStart)
        let (out, reward) = WeeklyBossLifecycle.conquer(s, now: Self.day(2)) // Wednesday
        #expect(out.status == .completed)
        #expect(reward == BossReward(xp: 1000, statBonus: 15))
    }

    // Behavior 2: conquer after the deadline -> no reward, status unchanged.
    @Test func conquerAfterDeadlineNoReward() {
        let s = BossState(weekStart: Self.weekStart)
        let (out, reward) = WeeklyBossLifecycle.conquer(s, now: Self.day(8))
        #expect(reward == nil)
        #expect(out.status == .active)
    }

    // Behavior 3: no double-claim once completed.
    @Test func noDoubleConquer() {
        let done = BossState(status: .completed, weekStart: Self.weekStart)
        let (out, reward) = WeeklyBossLifecycle.conquer(done, now: Self.day(2))
        #expect(reward == nil)
        #expect(out.status == .completed)
    }

    // Behavior 4: evaluate past the deadline auto-fails an active boss.
    @Test func evaluateAutoFailsPastDeadline() {
        let s = BossState(weekStart: Self.weekStart)
        let out = WeeklyBossLifecycle.evaluate(s, now: Self.day(8))
        #expect(out.status == .failed)
    }

    // Behavior 5: evaluate before the deadline leaves it active.
    @Test func evaluateBeforeDeadlineStaysActive() {
        let s = BossState(weekStart: Self.weekStart)
        let out = WeeklyBossLifecycle.evaluate(s, now: Self.day(5))
        #expect(out.status == .active)
    }

    // Behavior 6: reroll allowed before Wed 23:59, when none used yet.
    @Test func canRerollEarlyInWeek() {
        let s = BossState(weekStart: Self.weekStart)
        #expect(WeeklyBossLifecycle.canReroll(s, now: Self.day(1)) == true)  // Tuesday
    }

    // Behavior 7: reroll blocked after the Wednesday window.
    @Test func cannotRerollAfterWindow() {
        let s = BossState(weekStart: Self.weekStart)
        #expect(WeeklyBossLifecycle.canReroll(s, now: Self.day(4)) == false) // Friday
    }

    // Behavior 8: reroll blocked once one has been used.
    @Test func cannotRerollTwice() {
        let s = BossState(weekStart: Self.weekStart, rerollsUsed: 1)
        #expect(WeeklyBossLifecycle.canReroll(s, now: Self.day(1)) == false)
    }

    // Behavior 9: reroll when allowed bumps the counter, stays active.
    @Test func rerollConsumesOne() {
        let s = BossState(weekStart: Self.weekStart)
        let out = WeeklyBossLifecycle.reroll(s, now: Self.day(1))
        #expect(out.rerollsUsed == 1)
        #expect(out.status == .active)
        #expect(WeeklyBossLifecycle.canReroll(out, now: Self.day(1)) == false) // now exhausted
    }

    // Behavior 10: reroll when not allowed leaves state unchanged.
    @Test func rerollNoOpWhenBlocked() {
        let s = BossState(weekStart: Self.weekStart, rerollsUsed: 1)
        let out = WeeklyBossLifecycle.reroll(s, now: Self.day(1))
        #expect(out == s)
    }
}
