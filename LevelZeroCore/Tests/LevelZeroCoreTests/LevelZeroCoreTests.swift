import Testing
@testable import LevelZeroCore

@Suite struct ProgressionEngineTests {
    // Behavior 1: gain below threshold -> xp increases, no event.
    @Test func gainBelowThresholdAddsXPNoEvent() {
        let (s, events) = ProgressionEngine.apply(
            ProgressionState(xp: 0, level: 1, rank: .e),
            xpGain: 50
        )
        #expect(s.xp == 50)
        #expect(s.level == 1)
        #expect(s.rank == .e)
        #expect(events.isEmpty)
    }

    // Behavior 2: exact threshold (L*100) -> level+1, xp rolls to 0, leveledUp event.
    @Test func exactThresholdLevelsUp() {
        let (s, events) = ProgressionEngine.apply(
            ProgressionState(xp: 0, level: 1, rank: .e),
            xpGain: 100
        )
        #expect(s.xp == 0)
        #expect(s.level == 2)
        #expect(s.rank == .e)
        #expect(events == [.leveledUp(to: 2)])
    }

    // Behavior 3: overflow -> remainder carried into the new level.
    @Test func overflowCarriesRemainder() {
        let (s, events) = ProgressionEngine.apply(
            ProgressionState(xp: 0, level: 1, rank: .e),
            xpGain: 150
        )
        #expect(s.level == 2)
        #expect(s.xp == 50)
        #expect(events == [.leveledUp(to: 2)])
    }

    // Behavior 4: one big gain crosses multiple levels -> ordered leveledUp events.
    @Test func bigGainCrossesMultipleLevels() {
        // L1 +350: ->L2 (xp250), ->L3 (xp50). L3 needs 300, stops.
        let (s, events) = ProgressionEngine.apply(
            ProgressionState(xp: 0, level: 1, rank: .e),
            xpGain: 350
        )
        #expect(s.level == 3)
        #expect(s.xp == 50)
        #expect(events == [.leveledUp(to: 2), .leveledUp(to: 3)])
    }

    // Behavior 6: crossing level 10 -> 11 flips rank E -> D, emits rankedUp.
    @Test func rankBoundaryEtoD() {
        // L10 needs 1000 to reach L11.
        let (s, events) = ProgressionEngine.apply(
            ProgressionState(xp: 0, level: 10, rank: .e),
            xpGain: 1000
        )
        #expect(s.level == 11)
        #expect(s.rank == .d)
        #expect(events == [.leveledUp(to: 11), .rankedUp(to: .d)])
    }

    // Behavior 7: every rank band boundary maps correctly.
    @Test(arguments: [
        (10, Rank.e), (11, Rank.d), (20, Rank.d), (21, Rank.c), (35, Rank.c),
        (36, Rank.b), (50, Rank.b), (51, Rank.a), (75, Rank.a), (76, Rank.s),
    ])
    func rankBands(_ pair: (Int, Rank)) {
        #expect(ProgressionEngine.rank(forLevel: pair.0) == pair.1)
    }

    // Behavior 7b: crossing into S via apply emits rankedUp(.s).
    @Test func rankBoundaryAtoS() {
        // L75 needs 7500 to reach L76.
        let (s, events) = ProgressionEngine.apply(
            ProgressionState(xp: 0, level: 75, rank: .a),
            xpGain: 7500
        )
        #expect(s.level == 76)
        #expect(s.rank == .s)
        #expect(events == [.leveledUp(to: 76), .rankedUp(to: .s)])
    }
}
