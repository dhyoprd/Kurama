import Testing
@testable import LevelZeroCore

@Suite struct ReadingFocusTimerTests {
    // Fold a sequence of events from a fresh session.
    static func run(_ events: [ReadingEvent], from start: ReadingSession = ReadingSession()) -> ReadingSession {
        events.reduce(start) { ReadingFocusTimer.reduce($0, $1) }
    }

    // Behavior 1: a tick while reading advances elapsed by 1.
    @Test func tickAdvancesElapsed() {
        let s = ReadingFocusTimer.reduce(ReadingSession(), .tick)
        #expect(s.elapsed == 1)
        #expect(s.phase == .reading)
    }

    // Behavior 2: reaching 600s active -> awaiting reflection.
    @Test func reachingFocusDurationAwaitsReflection() {
        let start = ReadingSession(phase: .reading, elapsed: 599, secondsSincePageTurn: 0)
        let s = ReadingFocusTimer.reduce(start, .tick)
        #expect(s.elapsed == 600)
        #expect(s.phase == .awaitingReflection)
    }

    // Behavior 3: 180s with no page-turn -> paused.
    @Test func idleLimitPauses() {
        let s = Self.run(Array(repeating: .tick, count: 180))
        #expect(s.phase == .paused)
        #expect(s.elapsed == 180)
    }

    // Behavior 4: page-turn while reading resets the idle counter (no premature pause).
    @Test func pageTurnResetsIdle() {
        // 179 ticks (about to pause), page-turn, then 179 more -> still reading.
        var events = Array(repeating: ReadingEvent.tick, count: 179)
        events.append(.pageTurn)
        events += Array(repeating: .tick, count: 179)
        let s = Self.run(events)
        #expect(s.phase == .reading)
        #expect(s.elapsed == 358)
        #expect(s.secondsSincePageTurn == 179)
    }

    // Behavior 5: page-turn while paused resumes reading.
    @Test func pageTurnResumesFromPaused() {
        var events = Array(repeating: ReadingEvent.tick, count: 180) // -> paused
        events.append(.pageTurn)                                     // -> resume
        let s = Self.run(events)
        #expect(s.phase == .reading)
        #expect(s.secondsSincePageTurn == 0)
    }

    // Behavior 6: non-empty takeaway in awaitingReflection -> claimed +25 XP.
    @Test func nonEmptyTakeawayClaimsXP() {
        let start = ReadingSession(phase: .awaitingReflection, elapsed: 600)
        let s = ReadingFocusTimer.reduce(start, .submitTakeaway("Systems beat goals."))
        #expect(s.phase == .claimed)
        #expect(s.xpAwarded == 25)
    }

    // Behavior 7: empty/whitespace takeaway is rejected -> stays awaiting, no XP.
    @Test func emptyTakeawayRejected() {
        let start = ReadingSession(phase: .awaitingReflection, elapsed: 600)
        let s = ReadingFocusTimer.reduce(start, .submitTakeaway("   "))
        #expect(s.phase == .awaitingReflection)
        #expect(s.xpAwarded == 0)
    }

    // Behavior 8: no double-claim once claimed.
    @Test func noDoubleClaim() {
        let claimed = ReadingSession(phase: .claimed, elapsed: 600, xpAwarded: 25)
        let s = ReadingFocusTimer.reduce(claimed, .submitTakeaway("again"))
        #expect(s.phase == .claimed)
        #expect(s.xpAwarded == 25)
    }
}
