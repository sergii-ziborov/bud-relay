import Foundation

struct Cell: Hashable, Codable, Sendable, Comparable {
    let row: Int
    let col: Int

    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }

    static func < (lhs: Cell, rhs: Cell) -> Bool {
        lhs.row == rhs.row ? lhs.col < rhs.col : lhs.row < rhs.row
    }
}

enum Moisture: Int, Codable, Sendable, Hashable, Comparable {
    case dry = 0
    case normal = 1
    case wet = 2

    static func < (lhs: Moisture, rhs: Moisture) -> Bool { lhs.rawValue < rhs.rawValue }

    var drier: Moisture {
        Moisture(rawValue: max(0, rawValue - 1)) ?? .dry
    }
}

enum PlantStage: Codable, Sendable, Hashable {
    case bud(turnsLeft: Int)
    case bloom(stayLeft: Int)

    var isBud: Bool {
        if case .bud = self { return true }
        return false
    }

    var isBloom: Bool {
        if case .bloom = self { return true }
        return false
    }

    var turnsLeft: Int? {
        if case let .bud(turnsLeft) = self { return turnsLeft }
        return nil
    }
}

struct Plant: Codable, Sendable, Hashable {
    var kind: FlowerKind
    var stage: PlantStage
    var fertilized: Bool = false

    static func bud(_ kind: FlowerKind, turns: Int? = nil) -> Plant {
        Plant(kind: kind, stage: .bud(turnsLeft: turns ?? kind.growTurns))
    }
}

struct Plot: Codable, Sendable, Hashable {
    var blocked: Bool = false
    var moisture: Moisture = .normal
    var mulched: Bool = false
    var composted: Bool = false
    var plant: Plant?

    var isEmpty: Bool { !blocked && plant == nil }
}

struct Board: Codable, Sendable, Hashable {
    static let size = 5

    var plots: [Plot]

    init() {
        plots = Array(repeating: Plot(), count: Board.size * Board.size)
    }

    static var allCells: [Cell] {
        (0..<size).flatMap { row in (0..<size).map { Cell(row, $0) } }
    }

    static func index(of cell: Cell) -> Int {
        cell.row * size + cell.col
    }

    static func contains(_ cell: Cell) -> Bool {
        cell.row >= 0 && cell.row < size && cell.col >= 0 && cell.col < size
    }

    static func neighbors(of cell: Cell) -> [Cell] {
        [
            Cell(cell.row - 1, cell.col),
            Cell(cell.row + 1, cell.col),
            Cell(cell.row, cell.col - 1),
            Cell(cell.row, cell.col + 1),
        ].filter(contains)
    }

    subscript(cell: Cell) -> Plot {
        get { plots[Board.index(of: cell)] }
        set { plots[Board.index(of: cell)] = newValue }
    }

    var emptyCells: [Cell] {
        Board.allCells.filter { self[$0].isEmpty }
    }

    var usableCells: [Cell] {
        Board.allCells.filter { !self[$0].blocked }
    }

    var plantedCells: [Cell] {
        Board.allCells.filter { self[$0].plant != nil }
    }

    var budCells: [Cell] {
        Board.allCells.filter { self[$0].plant?.stage.isBud == true }
    }

    var bloomCells: [Cell] {
        Board.allCells.filter { self[$0].plant?.stage.isBloom == true }
    }

    var emptyCount: Int { emptyCells.count }

    func canPlant(at cell: Cell) -> Bool {
        Board.contains(cell) && self[cell].isEmpty
    }

    /// Plants a bud. Composted soil gives the bud a head start and is used up.
    mutating func plant(_ kind: FlowerKind, at cell: Cell) {
        guard canPlant(at: cell) else { return }
        var plot = self[cell]
        var turns = kind.growTurns
        if plot.composted {
            turns = max(1, turns - 1)
            plot.composted = false
        }
        plot.plant = Plant(kind: kind, stage: .bud(turnsLeft: turns))
        self[cell] = plot
    }

    mutating func remove(at cell: Cell) {
        guard Board.contains(cell) else { return }
        plots[Board.index(of: cell)].plant = nil
    }

    mutating func block(_ cells: [Cell]) {
        for cell in cells where Board.contains(cell) {
            plots[Board.index(of: cell)].blocked = true
            plots[Board.index(of: cell)].plant = nil
        }
    }

    mutating func setMoisture(_ moisture: Moisture, at cells: [Cell]) {
        for cell in cells where Board.contains(cell) {
            plots[Board.index(of: cell)].moisture = moisture
        }
    }
}
