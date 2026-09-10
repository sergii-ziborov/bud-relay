import Foundation

/// A two-ply gardener: it scores each placement by what happens now and by the best
/// follow-up next turn. Good enough to hint, and to prove every level can be finished.
enum Bot {
    enum Move: Hashable, Sendable {
        case place(card: Int, cell: Cell)
        case tend
    }

    private struct Candidate {
        let move: Move
        let run: LevelRun
        let score: Double
    }

    static func bestMove(in run: LevelRun) -> Move {
        guard !run.isOver else { return .tend }
        let firstPly = candidates(in: run).sorted { $0.score > $1.score }
        guard let top = firstPly.first else { return .tend }
        if top.run.isOver { return top.move }
        var best: (move: Move, score: Double) = (top.move, -Double.infinity)
        for candidate in firstPly.prefix(6) {
            var total = candidate.score
            if !candidate.run.isOver {
                let followUp = candidates(in: candidate.run).map(\.score).max() ?? 0
                total += followUp * 0.7
            }
            if total > best.score {
                best = (candidate.move, total)
            }
        }
        return best.move
    }

    private static func candidates(in run: LevelRun) -> [Candidate] {
        var result: [Candidate] = []
        var seenKinds = Set<FlowerKind>()
        let cells = candidateCells(in: run.board)
        for (index, kind) in run.hand.enumerated() {
            guard seenKinds.insert(kind).inserted else { continue }
            for cell in cells {
                var next = run
                guard let report = next.place(card: index, at: cell) else { continue }
                result.append(Candidate(move: .place(card: index, cell: cell), run: next, score: evaluate(report: report, placed: kind, before: run, after: next)))
            }
        }
        if !run.board.budCells.isEmpty {
            var next = run
            if let report = next.tend() {
                result.append(Candidate(move: .tend, run: next, score: evaluate(report: report, placed: nil, before: run, after: next) - 8))
            }
        }
        return result
    }

    /// Empty plots next to something growing, plus a few open plots with room around them.
    private static func candidateCells(in board: Board) -> [Cell] {
        let empty = board.emptyCells
        let planted = Set(board.plantedCells)
        var near = empty.filter { cell in Board.neighbors(of: cell).contains { planted.contains($0) } }
        let open = empty
            .filter { !near.contains($0) }
            .sorted { a, b in
                let ra = Board.neighbors(of: a).filter { board[$0].isEmpty }.count
                let rb = Board.neighbors(of: b).filter { board[$0].isEmpty }.count
                return ra == rb ? a < b : ra > rb
            }
        near.append(contentsOf: open.prefix(3))
        return near
    }

    static func evaluate(report: TurnReport, placed: FlowerKind?, before: LevelRun, after: LevelRun) -> Double {
        var score = immediate(report: report, before: before.stats, after: after)
        if after.won {
            score += 1_500 + Double(after.turnsLeft) * 25
            return score
        }
        if after.isOver {
            return score - 800
        }
        if let placed, after.level.goals.contains(where: { $0.kind == placed }) {
            score += 10
        }
        // What the beds will do on their own: buds that will bloom together are worth planning for.
        var sim = after
        var discount = 0.6
        for _ in 0..<4 {
            guard let future = sim.tend() else { break }
            let value = immediate(report: future, before: after.stats, after: sim)
            score += value * discount
            discount *= 0.6
            if sim.isOver { break }
        }
        return score
    }

    /// Value of one resolved turn against the level goals.
    private static func immediate(report: TurnReport, before: LevelStats, after: LevelRun) -> Double {
        let board = after.board
        var score = 0.0
        let chainGoalOpen = after.level.goals.contains { goal in
            if case .chain = goal { return !goal.isDone(stats: before, board: board) }
            return false
        }
        for goal in after.level.goals {
            let was = goal.progress(stats: before, board: board)
            let now = goal.progress(stats: after.stats, board: board)
            let done = goal.isDone(stats: after.stats, board: board)
            switch goal {
            case .emptyPlots:
                let others = after.level.goals.filter { !$0.isCondition }
                if others.allSatisfy({ $0.isDone(stats: after.stats, board: board) }) {
                    score += Double(now) * 30
                }
            case .chain:
                score += Double(max(0, now - was)) * 80
                if done, was < goal.target { score += 600 }
            default:
                score += Double(max(0, now - was)) * 40
                if done, was < goal.target { score += 120 }
            }
        }
        var bloomValue = Double(report.chain * report.chain) * 6 + report.bloomedKinds.reduce(0.0) { $0 + Double($1.value) }
        if report.chain == 1, chainGoalOpen { bloomValue *= 0.4 }
        score += bloomValue
        if !report.pollinatorSeeds.isEmpty { score += 25 }
        for cell in board.budCells {
            guard let mine = board[cell].plant?.stage.turnsLeft else { continue }
            for neighbor in Board.neighbors(of: cell) {
                guard let theirs = board[neighbor].plant?.stage.turnsLeft else { continue }
                score += abs(mine - theirs) <= 1 ? 6 : 2
            }
            if mine > after.turnsLeft { score -= 30 }
        }
        score -= Double(report.thirsty.count) * 4
        return score
    }

    /// Plays a whole level with a simple watering habit. Used by tests to validate the catalog.
    static func play(level: LevelDef, seed: UInt64, ownedTools: [Tool: Int] = [:]) -> LevelRun {
        var run = LevelRun(level: level, seed: seed, ownedTools: ownedTools)
        var safety = level.turns + 4
        while !run.isOver, safety > 0 {
            safety -= 1
            if run.count(of: .water) > 0 {
                let thirsty = run.board.budCells.filter { run.board[$0].moisture == .dry }
                if let cell = thirsty.first { run.use(.water, at: cell) }
            }
            switch bestMove(in: run) {
            case let .place(card, cell):
                run.place(card: card, at: cell)
            case .tend:
                run.tend()
            }
        }
        return run
    }
}
