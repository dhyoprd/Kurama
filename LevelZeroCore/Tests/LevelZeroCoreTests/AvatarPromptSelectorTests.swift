import Testing
@testable import LevelZeroCore

@Suite struct AvatarPromptSelectorTests {
    // Behavior 1: strength maps to the warrior archetype.
    @Test func strengthIsWarrior() {
        #expect(AvatarPromptSelector.archetype(for: .strength) == .warrior)
    }

    // Behavior 2: every stat maps to an archetype (discipline -> warrior).
    @Test(arguments: [
        (Stat.strength, Archetype.warrior), (.discipline, .warrior),
        (.intelligence, .mage), (.mind, .mage),
        (.wealth, .noble), (.charisma, .noble),
    ])
    func archetypeMapping(_ t: (Stat, Archetype)) {
        #expect(AvatarPromptSelector.archetype(for: t.0) == t.1)
    }

    // Behavior 3: top stat is the maximum; ties break by canonical order.
    @Test func topStatPicksMaximum() {
        let stats = Stats(strength: 10, intelligence: 12, discipline: 9, charisma: 11, wealth: 8, mind: 30)
        #expect(AvatarPromptSelector.topStat(of: stats) == .mind)
    }

    @Test func topStatTieBreaksFirst() {
        let stats = Stats() // all 10 -> strength (first canonical)
        #expect(AvatarPromptSelector.topStat(of: stats) == .strength)
    }

    // Behavior 4: prompt composes rank tier + archetype flavor, full-body.
    @Test func promptComposesTierAndFlavor() {
        let pE = AvatarPromptSelector.prompt(rank: .e, topStat: .strength)
        #expect(pE.contains("full-body"))
        #expect(pE.contains("novice"))
        #expect(pE.contains("battle armor"))

        let pS = AvatarPromptSelector.prompt(rank: .s, topStat: .intelligence)
        #expect(pS.contains("monarch"))
        #expect(pS.contains("mage robes"))
    }

    // Behavior 5: every rank yields a non-empty full-body prompt.
    @Test(arguments: [Rank.e, .d, .c, .b, .a, .s])
    func everyRankProducesPrompt(_ rank: Rank) {
        let p = AvatarPromptSelector.prompt(rank: rank, topStat: .wealth)
        #expect(p.contains("full-body"))
        #expect(p.contains("gold neon")) // noble flavor
    }

    // Behavior 6: life class -> signature stat (initial archetype at L1).
    @Test(arguments: [
        (LifeClass.warrior, Stat.strength), (.scholar, .intelligence),
        (.monk, .mind), (.builder, .wealth), (.strategist, .charisma),
    ])
    func signatureStatPerClass(_ t: (LifeClass, Stat)) {
        #expect(AvatarPromptSelector.signatureStat(for: t.0) == t.1)
    }

    // Behavior 7: L1 prompt by life class picks the right archetype flavor.
    @Test func l1PromptMatchesLifeClass() {
        #expect(AvatarPromptSelector.prompt(rank: .e, lifeClass: .warrior).contains("battle armor"))
        #expect(AvatarPromptSelector.prompt(rank: .e, lifeClass: .scholar).contains("mage robes"))
        #expect(AvatarPromptSelector.prompt(rank: .e, lifeClass: .builder).contains("gold neon"))
    }
}
