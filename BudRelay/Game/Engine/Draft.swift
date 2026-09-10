import Foundation

/// Deals flowers from shuffled bags so every kind in the level shows up regularly.
enum Draft {
    static let bagSize = 8

    static func queue(kinds: [FlowerKind], seed: UInt64, count: Int) -> [FlowerKind] {
        precondition(!kinds.isEmpty, "A level needs at least one flower kind")
        var rng = SeededRNG(seed: seed)
        var result: [FlowerKind] = []
        while result.count < count {
            var bag = kinds
            while bag.count < bagSize {
                bag.append(weightedPick(kinds, rng: &rng))
            }
            bag.shuffle(using: &rng)
            result.append(contentsOf: bag)
        }
        return Array(result.prefix(count))
    }

    /// Quick flowers appear a little more often; the slow, valuable ones stay special.
    private static func weightedPick(_ kinds: [FlowerKind], rng: inout SeededRNG) -> FlowerKind {
        let weights = kinds.map { kind -> Int in
            switch kind.growTurns {
            case 1: 3
            case 2, 3: 3
            default: 2
            }
        }
        let total = weights.reduce(0, +)
        var roll = rng.int(below: total)
        for (kind, weight) in zip(kinds, weights) {
            if roll < weight { return kind }
            roll -= weight
        }
        return kinds[kinds.count - 1]
    }
}
