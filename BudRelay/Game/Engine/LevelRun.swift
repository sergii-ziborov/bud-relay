import Foundation

/// Pure state of one level in progress. The session on screen and the bot both drive it.
struct LevelRun: Hashable, Sendable {
    let level: LevelDef
    let seed: UInt64
    let endless: Bool

    var board: Board
    var hand: [FlowerKind]
    var next: FlowerKind
    var turnsLeft: Int
    var stats = LevelStats()
    var freeTools: [Tool: Int]
    var ownedTools: [Tool: Int]
    var isOver = false
    var won = false

    private var queue: [FlowerKind]
    private var cursor: Int

    init(level: LevelDef, seed: UInt64, ownedTools: [Tool: Int] = [:], endless: Bool = false) {
        self.level = level
        self.seed = seed
        self.endless = endless
        board = level.initialBoard()
        turnsLeft = level.turns
        freeTools = level.grants
        self.ownedTools = ownedTools
        queue = Draft.queue(kinds: level.kinds, seed: seed, count: level.turns + 8)
        hand = Array(queue[0..<3])
        next = queue[3]
        cursor = 4
    }

    var isWon: Bool {
        LevelRules.isWon(goals: level.goals, stats: stats, board: board)
    }

    var stars: Int {
        LevelRules.stars(level: level, turnsLeft: turnsLeft, won: won)
    }

    func count(of tool: Tool) -> Int {
        freeTools[tool, default: 0] + ownedTools[tool, default: 0]
    }

    // MARK: - Turns

    @discardableResult
    mutating func place(card index: Int, at cell: Cell) -> TurnReport? {
        guard !isOver, hand.indices.contains(index), board.canPlant(at: cell) else { return nil }
        board.plant(hand[index], at: cell)
        hand.remove(at: index)
        hand.append(next)
        next = queue[cursor % queue.count]
        cursor += 1
        return finishTurn()
    }

    /// Spend a turn tending the beds without planting.
    @discardableResult
    mutating func tend() -> TurnReport? {
        guard !isOver else { return nil }
        return finishTurn()
    }

    private mutating func finishTurn() -> TurnReport {
        let report = Relay.resolveTurn(board: board, weather: level.weather)
        board = report.finalBoard
        stats.record(report)
        turnsLeft -= 1
        if !endless, isWon {
            isOver = true
            won = true
        } else if turnsLeft <= 0 {
            isOver = true
            won = endless || isWon
        }
        return report
    }

    // MARK: - Tools

    func canUse(_ tool: Tool, at cell: Cell) -> Bool {
        guard !isOver, count(of: tool) > 0, Board.contains(cell) else { return false }
        let plot = board[cell]
        if plot.blocked { return false }
        switch tool {
        case .water: return plot.moisture != .wet || Board.neighbors(of: cell).contains { board[$0].moisture != .wet && !board[$0].blocked }
        case .compost: return plot.isEmpty && !plot.composted
        case .fertilizer: return plot.plant?.stage.isBud == true && plot.plant?.fertilized == false
        case .mulch: return !plot.mulched
        case .shears: return plot.plant != nil
        }
    }

    func targets(for tool: Tool) -> [Cell] {
        Board.allCells.filter { canUse(tool, at: $0) }
    }

    @discardableResult
    mutating func use(_ tool: Tool, at cell: Cell) -> Bool {
        guard canUse(tool, at: cell) else { return false }
        switch tool {
        case .water:
            board.setMoisture(.wet, at: ([cell] + Board.neighbors(of: cell)).filter { !board[$0].blocked })
        case .compost:
            board[cell].composted = true
        case .fertilizer:
            board[cell].plant?.fertilized = true
        case .mulch:
            board[cell].mulched = true
        case .shears:
            board[cell].plant = nil
        }
        if freeTools[tool, default: 0] > 0 {
            freeTools[tool, default: 0] -= 1
        } else {
            ownedTools[tool, default: 0] -= 1
        }
        return true
    }

    /// Swap a card in hand for a flower from a seed packet.
    mutating func swap(card index: Int, to kind: FlowerKind) {
        guard hand.indices.contains(index) else { return }
        hand[index] = kind
    }
}
