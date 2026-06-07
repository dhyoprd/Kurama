import Testing
@testable import LevelZeroCore

@Suite struct AvatarDialogueSelectorTests {
    // Behavior 1: weakest stat is the minimum.
    @Test func picksMinimumStat() {
        let stats = Stats(strength: 20, intelligence: 5, discipline: 15, charisma: 12, wealth: 18, mind: 30)
        #expect(AvatarDialogueSelector.weakestStat(of: stats) == .intelligence)
    }

    // Behavior 2: ties break by canonical order (strength first).
    @Test func tieBreaksByCanonicalOrder() {
        let stats = Stats(strength: 5, intelligence: 8, discipline: 8, charisma: 8, wealth: 8, mind: 5)
        #expect(AvatarDialogueSelector.weakestStat(of: stats) == .strength)
    }

    // Behavior 3: the chosen line belongs to the weakest stat's pool.
    @Test func lineTargetsWeakestStat() {
        let stats = Stats(strength: 20, intelligence: 5, discipline: 15, charisma: 12, wealth: 18, mind: 30)
        var rng = SeededRandomNumberGenerator(seed: 42)
        let line = AvatarDialogueSelector.line(for: stats, using: &rng)
        #expect(AvatarDialogueSelector.lines(for: .intelligence).contains(line))
    }

    // Behavior 4: same seed -> same line (deterministic).
    @Test func deterministicWithSeed() {
        let stats = Stats(strength: 20, intelligence: 5, discipline: 15, charisma: 12, wealth: 18, mind: 30)
        var a = SeededRandomNumberGenerator(seed: 7)
        var b = SeededRandomNumberGenerator(seed: 7)
        #expect(AvatarDialogueSelector.line(for: stats, using: &a)
             == AvatarDialogueSelector.line(for: stats, using: &b))
    }
}
