import Testing
@testable import LevelZeroCore

@Suite struct OnboardingValidatorTests {
    static func validDraft() -> OnboardingDraft {
        OnboardingDraft(
            characterName: "JinWoo",
            goals: [.buildBody],
            lifeClass: .warrior,
            intensity: .normal,
            heightCm: 175,
            weightKg: 70
        )
    }

    // Behavior 1: a complete, valid draft has no errors.
    @Test func validDraftHasNoErrors() {
        #expect(OnboardingValidator.validate(Self.validDraft()).isEmpty)
    }

    @Test func emptyNameFlagged() {
        var d = Self.validDraft(); d.characterName = "   "
        #expect(OnboardingValidator.validate(d) == [.emptyName])
    }

    @Test func badNameLengthFlagged() {
        var short = Self.validDraft(); short.characterName = "a"
        #expect(OnboardingValidator.validate(short) == [.invalidName])
        var long = Self.validDraft(); long.characterName = String(repeating: "x", count: 21)
        #expect(OnboardingValidator.validate(long) == [.invalidName])
    }

    @Test func noGoalFlagged() {
        var d = Self.validDraft(); d.goals = []
        #expect(OnboardingValidator.validate(d) == [.noGoal])
    }

    @Test func noLifeClassFlagged() {
        var d = Self.validDraft(); d.lifeClass = nil
        #expect(OnboardingValidator.validate(d) == [.noLifeClass])
    }

    @Test(arguments: [nil, 10.0, 400.0])
    func badHeightFlagged(_ h: Double?) {
        var d = Self.validDraft(); d.heightCm = h
        #expect(OnboardingValidator.validate(d) == [.invalidHeight])
    }

    @Test(arguments: [nil, 5.0, 600.0])
    func badWeightFlagged(_ w: Double?) {
        var d = Self.validDraft(); d.weightKg = w
        #expect(OnboardingValidator.validate(d) == [.invalidWeight])
    }

    // Errors combine in field order.
    @Test func emptyDraftReportsAllInOrder() {
        #expect(OnboardingValidator.validate(OnboardingDraft())
            == [.emptyName, .noGoal, .noLifeClass, .invalidHeight, .invalidWeight])
    }
}
