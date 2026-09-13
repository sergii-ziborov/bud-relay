import Foundation

enum Goal: Hashable, Sendable, Codable {
    case bloom(Int)
    case chain(Int)
    case grow(FlowerKind, Int)
    case pollinator(Int)
    case harvest(Int)
    case emptyPlots(Int)

    var target: Int {
        switch self {
        case let .bloom(n), let .chain(n), let .pollinator(n), let .harvest(n), let .emptyPlots(n): n
        case let .grow(_, n): n
        }
    }

    /// Empty-plot goals describe the board at the moment the other goals finish.
    var isCondition: Bool {
        if case .emptyPlots = self { return true }
        return false
    }

    func progress(stats: LevelStats, board: Board) -> Int {
        switch self {
        case .bloom: min(stats.bloomed, target)
        case .chain: min(stats.longestChain, target)
        case let .grow(kind, _): min(stats.bloomedByKind[kind, default: 0], target)
        case .pollinator: min(stats.pollinatorBonuses, target)
        case .harvest: min(stats.harvested, target)
        case .emptyPlots: min(board.emptyCount, target)
        }
    }

    func isDone(stats: LevelStats, board: Board) -> Bool {
        progress(stats: stats, board: board) >= target
    }

    var label: String {
        switch self {
        case let .bloom(n): "Bloom \(n) flowers"
        case let .chain(n): "Make a relay ×\(n)"
        case let .grow(kind, n): "Bloom \(n) \((n == 1 ? kind.name : kind.pluralName).lowercased())"
        case let .pollinator(n): "Bring \(n) bee visit\(n == 1 ? "" : "s")"
        case let .harvest(n): "Collect \(n) flowers"
        case let .emptyPlots(n): "Finish with \(n) empty plots"
        }
    }

    var symbol: String {
        switch self {
        case .bloom: "camera.macro"
        case .chain: "link"
        case .grow: "leaf.fill"
        case .pollinator: "ant.fill"
        case .harvest: "basket.fill"
        case .emptyPlots: "circle.dashed"
        }
    }

    var kind: FlowerKind? {
        if case let .grow(kind, _) = self { return kind }
        return nil
    }
}

struct LevelStats: Hashable, Sendable, Codable {
    var bloomed = 0
    var bloomedByKind: [FlowerKind: Int] = [:]
    var longestChain = 0
    var chains: [Int] = []
    var pollinatorBonuses = 0
    var harvested = 0
    var harvestedByKind: [FlowerKind: Int] = [:]
    var seedsEarned: [FlowerKind: Int] = [:]
    var flowersEarned: [FlowerKind: Int] = [:]
    /// Long cascades send a lasting pulse of care into the estate.
    var gardenEcho = 0
    var turnsPlayed = 0

    mutating func record(_ report: TurnReport) {
        turnsPlayed += 1
        bloomed += report.bloomedCount
        for kind in report.bloomedKinds {
            bloomedByKind[kind, default: 0] += 1
        }
        if report.chain > 0 {
            chains.append(report.chain)
            longestChain = max(longestChain, report.chain)
            if report.chain >= 4 {
                gardenEcho += (report.chain - 2) / 2
            }
            for (kind, count) in Rewards.flowers(forChain: report.chain, kinds: report.bloomedKinds) {
                flowersEarned[kind, default: 0] += count
            }
        }
        if !report.pollinatorSeeds.isEmpty {
            pollinatorBonuses += 1
            for kind in report.pollinatorSeeds {
                seedsEarned[kind, default: 0] += 1
            }
        }
        for harvest in report.harvested {
            harvested += harvest.yield
            harvestedByKind[harvest.kind, default: 0] += harvest.yield
        }
    }
}

enum LevelRules {
    static func isWon(goals: [Goal], stats: LevelStats, board: Board) -> Bool {
        goals.allSatisfy { $0.isDone(stats: stats, board: board) }
    }

    static func stars(level: LevelDef, turnsLeft: Int, won: Bool) -> Int {
        guard won else { return 0 }
        if turnsLeft >= level.stars.three { return 3 }
        if turnsLeft >= level.stars.two { return 2 }
        return 1
    }
}
