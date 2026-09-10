import Foundation

enum DecorCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case paths
    case decor
    case utilities
    case flowers

    var id: String { rawValue }

    var name: String {
        switch self {
        case .paths: "Paths"
        case .decor: "Decor"
        case .utilities: "Utilities"
        case .flowers: "Flowers"
        }
    }

    var symbol: String {
        switch self {
        case .paths: "circle.grid.2x2.fill"
        case .decor: "chair.fill"
        case .utilities: "drop.fill"
        case .flowers: "camera.macro"
        }
    }
}

enum DecorID: String, CaseIterable, Codable, Identifiable, Sendable, Hashable, CodingKeyRepresentable {
    case pathStone
    case planterBox
    case lantern
    case communityBench
    case birdbath
    case birdhouse
    case gardenArch
    case pond
    case pergola
    case compostBin
    case beeHotel
    case rainBarrel
    case herbSpiral
    case sundial

    var id: String { rawValue }

    var name: String {
        switch self {
        case .pathStone: "Path Stone"
        case .planterBox: "Planter Box"
        case .lantern: "Lantern"
        case .communityBench: "Community Bench"
        case .birdbath: "Birdbath"
        case .birdhouse: "Birdhouse"
        case .gardenArch: "Garden Arch"
        case .pond: "Small Pond"
        case .pergola: "Pergola"
        case .compostBin: "Compost Bin"
        case .beeHotel: "Bee Hotel"
        case .rainBarrel: "Rain Barrel"
        case .herbSpiral: "Herb Spiral"
        case .sundial: "Sundial"
        }
    }

    var category: DecorCategory {
        switch self {
        case .pathStone: .paths
        case .planterBox, .lantern, .communityBench, .birdbath, .birdhouse, .gardenArch, .pond, .pergola, .herbSpiral, .sundial: .decor
        case .compostBin, .beeHotel, .rainBarrel: .utilities
        }
    }

    var symbol: String {
        switch self {
        case .pathStone: "circle.fill"
        case .planterBox: "shippingbox.fill"
        case .lantern: "lamp.floor.fill"
        case .communityBench: "chair.lounge.fill"
        case .birdbath: "bird.fill"
        case .birdhouse: "house.fill"
        case .gardenArch: "archivebox.fill"
        case .pond: "water.waves"
        case .pergola: "tent.fill"
        case .compostBin: "trash.fill"
        case .beeHotel: "ant.fill"
        case .rainBarrel: "cylinder.fill"
        case .herbSpiral: "tornado"
        case .sundial: "sun.max.fill"
        }
    }

    /// Coins at the market. Nil means the piece is earned, not bought.
    var price: Int? {
        switch self {
        case .pathStone: 20
        case .planterBox: 80
        case .lantern: 90
        case .communityBench: 150
        case .birdbath: 200
        case .birdhouse: 120
        case .gardenArch: 300
        case .pond: 400
        case .pergola: 500
        case .compostBin, .beeHotel, .rainBarrel, .herbSpiral, .sundial: nil
        }
    }

    var blurb: String {
        switch self {
        case .pathStone: "A flat stone so nobody walks through the beds."
        case .planterBox: "A raised bed. Plant a flower on top."
        case .lantern: "Warm light for evenings on the bench."
        case .communityBench: "Where neighbours end up staying past dark."
        case .birdbath: "Shallow water. The robins find it first."
        case .birdhouse: "A small house for a small family."
        case .gardenArch: "An entrance worth walking through."
        case .pond: "Still water and a frog or two."
        case .pergola: "Shade, climbing roses, and a long table."
        case .compostBin: "Turns level leftovers into richer soil."
        case .beeHotel: "Hollow stems for solitary bees."
        case .rainBarrel: "Catches the roof water for dry weeks."
        case .herbSpiral: "A stone spiral with a herb on every step."
        case .sundial: "Old, a little slow, and everyone checks it anyway."
        }
    }

    /// The level whose first clear grants this piece.
    var earnedAtLevel: Int? {
        switch self {
        case .compostBin: 10
        case .beeHotel: 30
        case .rainBarrel: 40
        case .herbSpiral: 50
        case .sundial: 60
        default: nil
        }
    }

    static func earned(atLevel id: Int) -> DecorID? {
        allCases.first { $0.earnedAtLevel == id }
    }
}

struct GardenCell: Hashable, Codable, Sendable {
    let row: Int
    let col: Int

    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }

    var neighbors: [GardenCell] {
        [GardenCell(row - 1, col), GardenCell(row + 1, col), GardenCell(row, col - 1), GardenCell(row, col + 1)]
            .filter(GardenState.contains)
    }
}

struct PlacedDecor: Hashable, Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var decor: DecorID
    var cell: GardenCell
}

struct PlantedFlower: Hashable, Codable, Sendable, Identifiable {
    var id: UUID = UUID()
    var kind: FlowerKind
    var cell: GardenCell
}

struct GardenState: Hashable, Codable, Sendable {
    static let columns = 6
    static let rows = 7

    var decor: [PlacedDecor] = []
    var flowers: [PlantedFlower] = []
    var inventory: [DecorID: Int] = [:]

    static var allCells: [GardenCell] {
        (0..<rows).flatMap { row in (0..<columns).map { GardenCell(row, $0) } }
    }

    static func contains(_ cell: GardenCell) -> Bool {
        cell.row >= 0 && cell.row < rows && cell.col >= 0 && cell.col < columns
    }

    func decor(at cell: GardenCell) -> PlacedDecor? {
        decor.first { $0.cell == cell }
    }

    func flower(at cell: GardenCell) -> PlantedFlower? {
        flowers.first { $0.cell == cell }
    }

    func isFree(_ cell: GardenCell) -> Bool {
        GardenState.contains(cell) && decor(at: cell) == nil && flower(at: cell) == nil
    }

    func count(of decor: DecorID) -> Int {
        self.decor.filter { $0.decor == decor }.count
    }

    func count(of kind: FlowerKind) -> Int {
        flowers.filter { $0.kind == kind }.count
    }

    @discardableResult
    mutating func place(_ piece: DecorID, at cell: GardenCell) -> Bool {
        guard isFree(cell), inventory[piece, default: 0] > 0 else { return false }
        inventory[piece, default: 0] -= 1
        decor.append(PlacedDecor(decor: piece, cell: cell))
        return true
    }

    @discardableResult
    mutating func plant(_ kind: FlowerKind, at cell: GardenCell) -> Bool {
        guard isFree(cell) else { return false }
        flowers.append(PlantedFlower(kind: kind, cell: cell))
        return true
    }

    /// Returns the piece to inventory.
    mutating func pickUp(decorID: UUID) {
        guard let index = decor.firstIndex(where: { $0.id == decorID }) else { return }
        let piece = decor.remove(at: index)
        inventory[piece.decor, default: 0] += 1
    }

    /// Returns the flower kind so the caller can put it back in the basket.
    mutating func uproot(flowerID: UUID) -> FlowerKind? {
        guard let index = flowers.firstIndex(where: { $0.id == flowerID }) else { return nil }
        return flowers.remove(at: index).kind
    }

    var hasBench: Bool { count(of: .communityBench) > 0 }
    var hasBees: Bool { count(of: .beeHotel) > 0 || count(of: .lavender) >= 2 }
    var hasBirds: Bool { count(of: .birdbath) > 0 || count(of: .birdhouse) > 0 }

    /// How alive the garden feels: every piece and every flower counts.
    var life: Int {
        decor.reduce(0) { $0 + ($1.decor.category == .paths ? 1 : 3) } + flowers.count * 2
    }

    /// Neighbours who come by. A bench is what makes them stay.
    var visitors: Int {
        guard hasBench else { return 0 }
        return min(4, 1 + life / 12)
    }

    func lanternNextToBench() -> Bool {
        for bench in decor where bench.decor == .communityBench {
            for cell in bench.cell.neighbors where decor(at: cell)?.decor == .lantern {
                return true
            }
        }
        return false
    }
}

enum GardenGoal: String, CaseIterable, Codable, Identifiable, Sendable, Hashable {
    case restoreBeds
    case layPath
    case placeToSit
    case waterForBirds
    case eveningLight
    case beeHotel
    case rainBarrel
    case pollinatorBed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .restoreBeds: "Restore the flower beds"
        case .layPath: "Lay a path"
        case .placeToSit: "A place to sit"
        case .waterForBirds: "Water for the birds"
        case .eveningLight: "Light by the bench"
        case .beeHotel: "Open the bee hotel"
        case .rainBarrel: "Catch the rain"
        case .pollinatorBed: "Plant a pollinator bed"
        }
    }

    var detail: String {
        switch self {
        case .restoreBeds: "Plant four flowers from your basket."
        case .layPath: "Place five path stones."
        case .placeToSit: "Place a community bench."
        case .waterForBirds: "Place a birdbath or a birdhouse."
        case .eveningLight: "Put a lantern right next to the bench."
        case .beeHotel: "Place the bee hotel earned in the schoolyard."
        case .rainBarrel: "Place the rain barrel earned at the market."
        case .pollinatorBed: "Plant four lavender, two daisies, and two sunflowers."
        }
    }

    var reward: Int {
        switch self {
        case .restoreBeds: 60
        case .layPath: 60
        case .placeToSit: 100
        case .waterForBirds: 100
        case .eveningLight: 120
        case .beeHotel: 150
        case .rainBarrel: 150
        case .pollinatorBed: 200
        }
    }

    func isDone(in garden: GardenState) -> Bool {
        switch self {
        case .restoreBeds: garden.flowers.count >= 4
        case .layPath: garden.count(of: .pathStone) >= 5
        case .placeToSit: garden.hasBench
        case .waterForBirds: garden.hasBirds
        case .eveningLight: garden.lanternNextToBench()
        case .beeHotel: garden.count(of: .beeHotel) > 0
        case .rainBarrel: garden.count(of: .rainBarrel) > 0
        case .pollinatorBed: garden.count(of: .lavender) >= 4 && garden.count(of: .daisy) >= 2 && garden.count(of: .sunflower) >= 2
        }
    }
}
