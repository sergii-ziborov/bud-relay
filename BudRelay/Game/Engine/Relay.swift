import Foundation

struct RelayPulse: Hashable, Sendable {
    let from: Cell
    let to: Cell
}

/// One step of a cascade. Wave 0 holds the buds that bloomed on their own timer.
struct Wave: Hashable, Sendable {
    var bloomed: [Cell]
    var pulses: [RelayPulse]
    var board: Board
}

struct Harvest: Hashable, Sendable {
    let cell: Cell
    let kind: FlowerKind
    let yield: Int
}

struct TurnReport: Hashable, Sendable {
    var harvested: [Harvest]
    var boardAfterTick: Board
    var waves: [Wave]
    /// Size of the largest connected group of flowers that bloomed this turn.
    var chain: Int
    /// Every flower that bloomed this turn, connected or not.
    var bloomedCount: Int
    var bloomedKinds: [FlowerKind]
    var pollinatorSeeds: [FlowerKind]
    var thirsty: [Cell]
    var finalBoard: Board

    var bloomedCells: [Cell] { waves.flatMap(\.bloomed) }
    var isCascade: Bool { chain >= 2 }
}

enum Relay {
    /// Flowers only relay to neighbours, so a relay chain is a connected group of blooms.
    static func largestConnectedGroup(_ cells: [Cell], pulses: [RelayPulse] = []) -> Int {
        var remaining = Set(cells)
        var pulseLinks: [Cell: [Cell]] = [:]
        for pulse in pulses {
            pulseLinks[pulse.from, default: []].append(pulse.to)
            pulseLinks[pulse.to, default: []].append(pulse.from)
        }
        var best = 0
        while let start = remaining.first {
            remaining.remove(start)
            var stack = [start]
            var size = 0
            while let cell = stack.popLast() {
                size += 1
                let connected = Board.neighbors(of: cell) + pulseLinks[cell, default: []]
                for neighbor in connected where remaining.contains(neighbor) {
                    remaining.remove(neighbor)
                    stack.append(neighbor)
                }
            }
            best = max(best, size)
        }
        return best
    }

    /// Resolves one gardening turn: harvest finished blooms, tick buds, cascade, then weather.
    static func resolveTurn(board start: Board, weather: Weather) -> TurnReport {
        var board = start
        var harvested: [Harvest] = []

        // 1. Blooms that have stayed long enough are collected and free their plot.
        for cell in Board.allCells {
            guard let plant = board[cell].plant, case let .bloom(stayLeft) = plant.stage else { continue }
            let remaining = stayLeft - 1
            if remaining <= 0 {
                let yield = plant.kind.harvestYield + (plant.fertilized ? 1 : 0)
                harvested.append(Harvest(cell: cell, kind: plant.kind, yield: yield))
                board[cell].plant = nil
            } else {
                board[cell].plant?.stage = .bloom(stayLeft: remaining)
            }
        }

        // 2. Every bud on soil that is not dry gets one care cycle.
        var thirsty: [Cell] = []
        var wave0: [Cell] = []
        for cell in Board.allCells {
            guard let plant = board[cell].plant, case let .bud(turnsLeft) = plant.stage else { continue }
            if board[cell].moisture == .dry {
                thirsty.append(cell)
                continue
            }
            let remaining = turnsLeft - 1
            if remaining <= 0 {
                wave0.append(cell)
            } else {
                board[cell].plant?.stage = .bud(turnsLeft: remaining)
            }
        }
        let boardAfterTick = board

        // 3. Cascade: each bloom hands care points to neighbouring buds.
        var waves: [Wave] = []
        var current = wave0
        var bloomedKinds: [FlowerKind] = []
        while !current.isEmpty {
            for cell in current {
                guard let plant = board[cell].plant else { continue }
                board[cell].plant?.stage = .bloom(stayLeft: plant.kind.bloomStay)
                bloomedKinds.append(plant.kind)
            }
            var pulses: [RelayPulse] = []
            var nextWave: [Cell] = []
            for cell in current {
                guard let bloomer = board[cell].plant else { continue }
                for neighbor in bloomer.kind.relayNeighbors(of: cell) {
                    guard let plant = board[neighbor].plant, case let .bud(turnsLeft) = plant.stage else { continue }
                    pulses.append(RelayPulse(from: cell, to: neighbor))
                    let remaining = turnsLeft - bloomer.kind.relayPower
                    if remaining <= 0 {
                        board[neighbor].plant?.stage = .bud(turnsLeft: 0)
                        if !nextWave.contains(neighbor) {
                            nextWave.append(neighbor)
                        }
                    } else {
                        board[neighbor].plant?.stage = .bud(turnsLeft: remaining)
                    }
                }
            }
            waves.append(Wave(bloomed: current, pulses: pulses, board: board))
            current = nextWave.sorted()
        }

        // 4. Bees visit when lavender blooms in the same cascade as daisies or sunflowers.
        var pollinatorSeeds: [FlowerKind] = []
        let lavenders = bloomedKinds.filter { $0 == .lavender }.count
        if bloomedKinds.count >= 2, lavenders > 0,
           let partner = bloomedKinds.first(where: { $0.pollinatorFriendly && $0 != .lavender }) {
            pollinatorSeeds = Array(repeating: partner, count: lavenders)
        }

        // 5. Weather settles on the soil for the next decision.
        switch weather {
        case .mild:
            break
        case .rain:
            for cell in Board.allCells where !board[cell].blocked {
                board[cell].moisture = .wet
            }
        case .hotDay:
            let shielded = Set(board.bloomCells
                .filter { board[$0].plant?.kind == .marigold }
                .flatMap { Board.neighbors(of: $0) + [$0] })
            for cell in Board.allCells where !board[cell].blocked {
                if board[cell].mulched || shielded.contains(cell) { continue }
                board[cell].moisture = board[cell].moisture.drier
            }
        }

        let allBloomed = waves.flatMap(\.bloomed)
        return TurnReport(
            harvested: harvested,
            boardAfterTick: boardAfterTick,
            waves: waves,
            chain: largestConnectedGroup(allBloomed, pulses: waves.flatMap(\.pulses)),
            bloomedCount: allBloomed.count,
            bloomedKinds: bloomedKinds,
            pollinatorSeeds: pollinatorSeeds,
            thirsty: thirsty,
            finalBoard: board
        )
    }
}
