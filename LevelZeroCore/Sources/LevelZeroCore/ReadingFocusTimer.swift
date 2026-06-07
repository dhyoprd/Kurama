import Foundation

// ReadingFocusTimer — pure reducer for a 10-minute focus reading session.
// Spec (design doc F, PRD #14/#15):
//   - 600s active-reading countdown.
//   - Anti-idle: 180s with no page-turn pauses the timer; a page-turn resumes it.
//   - On reaching 600s -> awaiting reflection.
//   - A non-empty takeaway claims +25 XP. Empty is rejected; no double-claim.
// Driven by discrete events (tick = 1 active second). No wall clock.

public enum ReadingPhase: Equatable, Sendable {
    case reading
    case paused
    case awaitingReflection
    case claimed
}

public struct ReadingSession: Equatable, Sendable {
    public var phase: ReadingPhase
    public var elapsed: Int               // active reading seconds toward focusDuration
    public var secondsSincePageTurn: Int
    public var xpAwarded: Int

    public init(
        phase: ReadingPhase = .reading,
        elapsed: Int = 0,
        secondsSincePageTurn: Int = 0,
        xpAwarded: Int = 0
    ) {
        self.phase = phase
        self.elapsed = elapsed
        self.secondsSincePageTurn = secondsSincePageTurn
        self.xpAwarded = xpAwarded
    }
}

public enum ReadingEvent: Equatable, Sendable {
    case tick                       // one active reading second elapsed
    case pageTurn
    case submitTakeaway(String)
}

public enum ReadingFocusTimer {
    public static let focusDuration = 600
    public static let idleLimit = 180
    public static let readingXP = 25

    public static func reduce(_ state: ReadingSession, _ event: ReadingEvent) -> ReadingSession {
        switch event {
        case .tick:
            guard state.phase == .reading else { return state }
            var s = state
            s.elapsed += 1
            s.secondsSincePageTurn += 1
            if s.elapsed >= focusDuration {
                s.phase = .awaitingReflection
            } else if s.secondsSincePageTurn >= idleLimit {
                s.phase = .paused
            }
            return s

        case .pageTurn:
            switch state.phase {
            case .reading:
                var s = state
                s.secondsSincePageTurn = 0
                return s
            case .paused:
                var s = state
                s.phase = .reading
                s.secondsSincePageTurn = 0
                return s
            case .awaitingReflection, .claimed:
                return state
            }

        case .submitTakeaway(let text):
            guard state.phase == .awaitingReflection else { return state }
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return state }
            var s = state
            s.phase = .claimed
            s.xpAwarded = readingXP
            return s
        }
    }
}
