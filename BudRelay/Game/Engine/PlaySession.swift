import Foundation
import SwiftUI

/// Drives one level on screen: selection, animation of the cascade, hints, tools.
@MainActor
@Observable
final class PlaySession {
    enum Phase: Equatable {
        case planning
        case animating
        case finished
    }

    private(set) var run: LevelRun
    let isDaily: Bool
    let hapticsEnabled: Bool

    var phase: Phase = .planning
    var displayBoard: Board
    var selectedCard: Int?
    var selectedTool: Tool?
    var activeWave: Wave?
    var justBloomed: Set<Cell> = []
    var harvestFloaters: [Harvest] = []
    var chainBanner: Int?
    var echoCelebration: Int?
    var echoCells: [Cell] = []
    var echoStartedAt = Date()
    var lastReport: TurnReport?
    var hintsLeft: Int
    var hint: Bot.Move?
    var seedSwapUsedThisTurn = false
    var swapCardIndex: Int?
    var onFinished: (() -> Void)?

    init(level: LevelDef, seed: UInt64, ownedTools: [Tool: Int], isDaily: Bool, hapticsEnabled: Bool) {
        let run = LevelRun(level: level, seed: seed, ownedTools: ownedTools, endless: isDaily)
        self.run = run
        self.isDaily = isDaily
        self.hapticsEnabled = hapticsEnabled
        displayBoard = run.board
        hintsLeft = level.hints
    }

    var level: LevelDef { run.level }
    var board: Board { run.board }
    var hand: [FlowerKind] { run.hand }
    var next: FlowerKind { run.next }
    var turnsLeft: Int { run.turnsLeft }
    var stats: LevelStats { run.stats }
    var ownedTools: [Tool: Int] { run.ownedTools }

    func toolCount(_ tool: Tool) -> Int { run.count(of: tool) }

    var goalProgress: [(goal: Goal, progress: Int, done: Bool)] {
        level.goals.map { goal in
            (goal, goal.progress(stats: run.stats, board: run.board), goal.isDone(stats: run.stats, board: run.board))
        }
    }

    var canTend: Bool {
        phase == .planning && !run.isOver
    }

    // MARK: - Selection

    func select(card index: Int) {
        guard phase == .planning else { return }
        selectedTool = nil
        swapCardIndex = nil
        selectedCard = selectedCard == index ? nil : index
        hint = nil
        if hapticsEnabled { Feedback.tap() }
    }

    @discardableResult
    func beginCardDrag(_ index: Int, expectedKind: FlowerKind) -> Bool {
        guard phase == .planning, hand.indices.contains(index), hand[index] == expectedKind else { return false }
        selectedTool = nil
        swapCardIndex = nil
        selectedCard = index
        hint = nil
        if hapticsEnabled { Feedback.pickup() }
        return true
    }

    func cancelCardDrag() {
        selectedCard = nil
        hint = nil
        if hapticsEnabled { Feedback.returnToHand() }
    }

    func select(tool: Tool) {
        guard phase == .planning, toolCount(tool) > 0 else { return }
        selectedCard = nil
        swapCardIndex = nil
        selectedTool = selectedTool == tool ? nil : tool
        hint = nil
        if hapticsEnabled { Feedback.tap() }
    }

    func clearSelection() {
        selectedCard = nil
        selectedTool = nil
        swapCardIndex = nil
    }

    func isHighlighted(_ cell: Cell) -> Bool {
        guard phase == .planning else { return false }
        if let tool = selectedTool {
            return run.canUse(tool, at: cell)
        }
        if selectedCard != nil {
            return run.board.canPlant(at: cell)
        }
        return false
    }

    var hintCell: Cell? {
        if case let .place(_, cell) = hint { return cell }
        return nil
    }

    var hintCard: Int? {
        if case let .place(card, _) = hint { return card }
        return nil
    }

    // MARK: - Actions

    func tap(cell: Cell) {
        guard phase == .planning else { return }
        if let tool = selectedTool {
            if run.use(tool, at: cell) {
                displayBoard = run.board
                if hapticsEnabled { Feedback.place() }
                if toolCount(tool) == 0 { selectedTool = nil }
            } else if hapticsEnabled {
                Feedback.warn()
            }
            return
        }
        guard let index = selectedCard else { return }
        if !place(card: index, expectedKind: nil, at: cell), hapticsEnabled {
            Feedback.warn()
        }
    }

    /// Places a card delivered by SwiftUI drag and drop. Tap-to-place calls the
    /// same path, so both interactions always follow identical game rules.
    @discardableResult
    func drop(_ payload: FlowerDragPayload, at cell: Cell) -> Bool {
        place(card: payload.cardIndex, expectedKind: payload.kind, at: cell)
    }

    @discardableResult
    private func place(card index: Int, expectedKind: FlowerKind?, at cell: Cell) -> Bool {
        guard phase == .planning, hand.indices.contains(index) else { return false }
        if let expectedKind, hand[index] != expectedKind { return false }
        guard run.board.canPlant(at: cell) else { return false }
        guard let report = run.place(card: index, at: cell) else { return false }
        selectedCard = nil
        selectedTool = nil
        hint = nil
        seedSwapUsedThisTurn = false
        if hapticsEnabled { Feedback.place() }
        Task { await animate(report) }
        return true
    }

    func tend() {
        guard canTend, let report = run.tend() else { return }
        clearSelection()
        hint = nil
        seedSwapUsedThisTurn = false
        Task { await animate(report) }
    }

    func useSeed(_ kind: FlowerKind, on index: Int) {
        guard phase == .planning, !seedSwapUsedThisTurn else { return }
        run.swap(card: index, to: kind)
        seedSwapUsedThisTurn = true
        swapCardIndex = nil
        selectedCard = index
        if hapticsEnabled { Feedback.tap() }
    }

    func requestHint() {
        guard phase == .planning, hintsLeft > 0 else { return }
        hintsLeft -= 1
        let move = Bot.bestMove(in: run)
        hint = move
        selectedTool = nil
        if case let .place(card, _) = move {
            selectedCard = card
        }
    }

    // MARK: - Animation

    private func animate(_ report: TurnReport) async {
        phase = .animating
        lastReport = report
        displayBoard = report.boardAfterTick
        harvestFloaters = report.harvested
        if !report.harvested.isEmpty {
            try? await Task.sleep(for: .milliseconds(380))
        } else {
            try? await Task.sleep(for: .milliseconds(140))
        }
        harvestFloaters = []
        for (index, wave) in report.waves.enumerated() {
            withAnimation(.spring(duration: 0.35, bounce: 0.35)) {
                displayBoard = wave.board
                justBloomed = Set(wave.bloomed)
                activeWave = wave
            }
            if hapticsEnabled {
                index == 0 ? Feedback.bloom() : Feedback.relay()
            }
            try? await Task.sleep(for: .milliseconds(index == 0 ? 360 : 440))
        }
        if report.chain >= 4 {
            echoCells = report.bloomedCells
            echoStartedAt = Date()
            withAnimation(.easeOut(duration: 0.2)) {
                echoCelebration = (report.chain - 2) / 2
            }
            if hapticsEnabled { Feedback.success() }
            try? await Task.sleep(for: .milliseconds(1050))
        } else if report.chain >= 2 {
            withAnimation(.spring(duration: 0.4, bounce: 0.4)) {
                chainBanner = report.chain
            }
            if hapticsEnabled, report.chain >= 3 { Feedback.success() }
            try? await Task.sleep(for: .milliseconds(650))
        }
        withAnimation(.easeOut(duration: 0.25)) {
            chainBanner = nil
            echoCelebration = nil
            justBloomed = []
            activeWave = nil
            displayBoard = run.board
        }
        if run.isOver {
            try? await Task.sleep(for: .milliseconds(350))
            phase = .finished
            onFinished?()
        } else {
            phase = .planning
        }
    }
}
