import Foundation

struct LevelOutcome: Hashable, Sendable {
    let levelID: Int
    let isDaily: Bool
    let won: Bool
    let stars: Int
    let stats: LevelStats
    let turnsLeft: Int
    let coins: Int
    let flowers: [FlowerKind: Int]
    let seeds: [FlowerKind: Int]
    var unlockedKind: FlowerKind?
    var unlockedDecor: DecorID?
    var firstClear: Bool
    var dailyBest: Bool
}

enum Rewards {
    /// A relay of three earns a flower, five earns two, eight earns three. Valuable kinds first.
    static func flowers(forChain chain: Int, kinds: [FlowerKind]) -> [FlowerKind: Int] {
        let count: Int
        switch chain {
        case ..<3: count = 0
        case 3..<5: count = 1
        case 5..<8: count = 2
        default: count = 3
        }
        guard count > 0, !kinds.isEmpty else { return [:] }
        let ordered = kinds.sorted { $0.value > $1.value }
        var unique: [FlowerKind] = []
        for kind in ordered where !unique.contains(kind) {
            unique.append(kind)
        }
        var result: [FlowerKind: Int] = [:]
        for index in 0..<count {
            let kind = unique[index % unique.count]
            result[kind, default: 0] += 1
        }
        return result
    }

    static func coins(stats: LevelStats, stars: Int, won: Bool) -> Int {
        guard won else { return 5 }
        return 20 + stars * 15 + stats.bloomed * 2 + stats.longestChain * 4
    }

    static func outcome(run: LevelRun, isDaily: Bool, firstClear: Bool, dailyBest: Bool = false) -> LevelOutcome {
        let stars = run.stars
        return LevelOutcome(
            levelID: run.level.id,
            isDaily: isDaily,
            won: run.won,
            stars: stars,
            stats: run.stats,
            turnsLeft: run.turnsLeft,
            coins: coins(stats: run.stats, stars: isDaily ? min(run.stats.longestChain / 2, 3) : stars, won: run.won),
            flowers: run.won ? run.stats.flowersEarned : [:],
            seeds: run.stats.seedsEarned,
            unlockedKind: nil,
            unlockedDecor: nil,
            firstClear: firstClear,
            dailyBest: dailyBest
        )
    }
}
