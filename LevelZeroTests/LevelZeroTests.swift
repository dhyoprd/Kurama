import XCTest
import LevelZeroCore
@testable import LevelZero

final class LevelZeroTests: XCTestCase {
    
    func testQuestRewardCalculationWithoutProof() {
        let rewardE = QuestRewardCalculator.reward(difficulty: .e, proofAttached: false)
        XCTAssertEqual(rewardE.xp, 50)
        XCTAssertEqual(rewardE.statDelta, 1)
        
        let rewardA = QuestRewardCalculator.reward(difficulty: .a, proofAttached: false)
        XCTAssertEqual(rewardA.xp, 400)
        XCTAssertEqual(rewardA.statDelta, 8)
    }
    
    func testQuestRewardCalculationWithProof() {
        let rewardE = QuestRewardCalculator.reward(difficulty: .e, proofAttached: true)
        XCTAssertEqual(rewardE.xp, 70) // 50 + 20 proof bonus
        XCTAssertEqual(rewardE.statDelta, 1)
    }
    
    func testConfigReadingTemplateValues() {
        // Verify that Config compiles and reads the plist securely
        let url = Config.supabaseURL
        XCTAssertNotNil(url)
    }
}
