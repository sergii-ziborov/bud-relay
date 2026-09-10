import XCTest
@testable import BudRelay

/// Prints how the bot fares on every level. Read the log to tune turn budgets and goals.
final class TuningReportTests: XCTestCase {
    func testPrintLevelTable() {
        var lines: [String] = ["LEVEL TABLE"]
        for level in LevelCatalog.all {
            var wins = 0
            var stars: [Int] = []
            var chains: [Int] = []
            var blooms: [Int] = []
            var left: [Int] = []
            for seed in UInt64(1)...4 {
                let run = Bot.play(level: level, seed: seed, ownedTools: [.water: 2])
                if run.won { wins += 1 }
                stars.append(run.stars)
                chains.append(run.stats.longestChain)
                blooms.append(run.stats.bloomed)
                left.append(run.turnsLeft)
            }
            let goals = level.goals.map(\.label).joined(separator: " + ")
            lines.append("L\(level.id) t\(level.turns) [\(goals)] wins \(wins)/4 stars \(stars) chain \(chains) blooms \(blooms) left \(left)")
        }
        print(lines.joined(separator: "\n"))
    }
}
