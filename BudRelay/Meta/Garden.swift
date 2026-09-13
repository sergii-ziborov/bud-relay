import Foundation

enum DecorCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case paths
    case decor
    case utilities
    case flowers
    case trees

    var id: String { rawValue }

    var name: String {
        return switch self {
        case .paths: "Paths"
        case .decor: "Decor"
        case .utilities: "Utilities"
        case .flowers: "Flowers"
        case .trees: "Trees"
        }
    }

    var symbol: String {
        switch self {
        case .paths: "circle.grid.2x2.fill"
        case .decor: "chair.fill"
        case .utilities: "drop.fill"
        case .flowers: "camera.macro"
        case .trees: "tree.fill"
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
    case appleTree
    case pearTree
    case cherryTree
    case lemonTree
    case mapleTree
    case willowTree

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
        case .appleTree: "Apple Tree"
        case .pearTree: "Pear Tree"
        case .cherryTree: "Cherry Tree"
        case .lemonTree: "Lemon Tree"
        case .mapleTree: "Field Maple"
        case .willowTree: "Willow Tree"
        }
    }

    var category: DecorCategory {
        switch self {
        case .pathStone: .paths
        case .planterBox, .lantern, .communityBench, .birdbath, .birdhouse, .gardenArch, .pond, .pergola, .herbSpiral, .sundial: .decor
        case .compostBin, .beeHotel, .rainBarrel: .utilities
        case .appleTree, .pearTree, .cherryTree, .lemonTree, .mapleTree, .willowTree: .trees
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
        case .appleTree, .pearTree, .cherryTree, .lemonTree, .mapleTree, .willowTree: "tree.fill"
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
        case .appleTree: 260
        case .pearTree: 280
        case .cherryTree: 320
        case .lemonTree: 340
        case .mapleTree: 300
        case .willowTree: 420
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
        case .appleTree: "Spring blossom, summer shade, and baskets to share in autumn."
        case .pearTree: "A patient orchard tree with soft white blossom."
        case .cherryTree: "Clouds of spring flowers above a small community harvest."
        case .lemonTree: "Glossy evergreen leaves and bright fruit for the greenhouse yard."
        case .mapleTree: "A calm native canopy that turns gold when the days shorten."
        case .willowTree: "A waterside tree whose long branches cool the pond edge."
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

    var treeKind: TreeKind? {
        TreeKind.allCases.first { $0.decor == self }
    }

    static func earned(atLevel id: Int) -> DecorID? {
        allCases.first { $0.earnedAtLevel == id }
    }
}

/// The permanent garden is one connected estate made of distinct buildable areas.
/// Existing saves keep their 6×7 cell identifiers; the view projects each group
/// onto a different part of the illustrated map instead of exposing one field.
enum GardenRegion: String, CaseIterable, Codable, Identifiable, Sendable, Hashable {
    case courtyard
    case meadow
    case orchard
    case waterside
    case greenhouseYard

    var id: String { rawValue }

    var name: String {
        switch self {
        case .courtyard: "Community Courtyard"
        case .meadow: "Wildflower Meadow"
        case .orchard: "Neighbourhood Orchard"
        case .waterside: "Pond Garden"
        case .greenhouseYard: "Greenhouse Yard"
        }
    }

    var tagline: String {
        switch self {
        case .courtyard: "The first beds beside the old gate."
        case .meadow: "A loose, sunny home for pollinators."
        case .orchard: "Fruit trees planted for future neighbours."
        case .waterside: "Cool shade, reeds, birds, and moving water."
        case .greenhouseYard: "Rare plants and the tools that keep them growing."
        }
    }

    var symbol: String {
        switch self {
        case .courtyard: "house.and.flag.fill"
        case .meadow: "camera.macro"
        case .orchard: "tree.fill"
        case .waterside: "water.waves"
        case .greenhouseYard: "building.2.fill"
        }
    }

    var requiredPlayerLevel: Int {
        switch self {
        case .courtyard: 1
        case .meadow: 4
        case .orchard: 8
        case .waterside: 15
        case .greenhouseYard: 24
        }
    }

    func isUnlocked(playerLevel: Int) -> Bool { playerLevel >= requiredPlayerLevel }

    /// A district opens as a small foothold, then gains one curated build site
    /// every two player levels. The estate therefore expands for the whole game
    /// instead of exposing forty-two invisible slots on day one.
    func capacity(at playerLevel: Int) -> Int {
        guard isUnlocked(playerLevel: playerLevel) else { return 0 }
        return min(cells.count, initialCapacity + max(0, playerLevel - requiredPlayerLevel) / 2)
    }

    var initialCapacity: Int {
        switch self {
        case .courtyard: 4
        case .meadow, .orchard: 2
        case .waterside, .greenhouseYard: 2
        }
    }

    var restorationTarget: Int {
        switch self {
        case .courtyard: 18
        case .meadow, .orchard: 12
        case .waterside, .greenhouseYard: 16
        }
    }

    /// Expansion order is centre-out and deliberately exposes useful kinds of
    /// terrain first. Cell IDs stay unchanged for save compatibility.
    var cells: [GardenCell] {
        switch self {
        case .courtyard:
            [GardenCell(5, 0), GardenCell(5, 3), GardenCell(6, 2), GardenCell(6, 3), GardenCell(5, 1), GardenCell(5, 4), GardenCell(6, 1), GardenCell(6, 4), GardenCell(5, 2), GardenCell(5, 5), GardenCell(6, 0), GardenCell(6, 5)]
        case .meadow:
            [GardenCell(4, 1), GardenCell(3, 1), GardenCell(4, 0), GardenCell(4, 2), GardenCell(3, 0), GardenCell(3, 2)]
        case .orchard:
            [GardenCell(4, 4), GardenCell(3, 4), GardenCell(4, 3), GardenCell(4, 5), GardenCell(3, 3), GardenCell(3, 5)]
        case .waterside:
            [GardenCell(2, 2), GardenCell(2, 1), GardenCell(1, 2), GardenCell(1, 1), GardenCell(2, 0), GardenCell(1, 0), GardenCell(0, 2), GardenCell(0, 1), GardenCell(0, 0)]
        case .greenhouseYard:
            [GardenCell(2, 3), GardenCell(2, 4), GardenCell(1, 3), GardenCell(1, 4), GardenCell(2, 5), GardenCell(1, 5), GardenCell(0, 3), GardenCell(0, 4), GardenCell(0, 5)]
        }
    }

    func isOpen(_ cell: GardenCell, at playerLevel: Int) -> Bool {
        guard let index = cells.firstIndex(of: cell) else { return false }
        return index < capacity(at: playerLevel)
    }

    static func region(for cell: GardenCell) -> GardenRegion {
        if cell.row >= 5 { return .courtyard }
        if cell.row >= 3 { return cell.col < 3 ? .meadow : .orchard }
        return cell.col < 3 ? .waterside : .greenhouseYard
    }
}

enum GardenRestorationStage: String, Sendable, Hashable {
    case shrouded
    case neglected
    case recovering
    case thriving

    var name: String {
        switch self {
        case .shrouded: "Unexplored"
        case .neglected: "Polluted"
        case .recovering: "Recovering"
        case .thriving: "Thriving"
        }
    }

    var symbol: String {
        switch self {
        case .shrouded: "cloud.fog.fill"
        case .neglected: "exclamationmark.triangle.fill"
        case .recovering: "leaf.fill"
        case .thriving: "sparkles"
        }
    }
}

enum GardenSpotKind: String, Sendable, Hashable {
    case flowerBed
    case lawn
    case orchard
    case path
    case waterside
    case service
}

enum GardenRewardKind: Hashable, Sendable {
    case coins
    case flower
    case seed
    case tool(Tool)

    var symbol: String {
        switch self {
        case .coins: "dollarsign.circle.fill"
        case .flower: "camera.macro"
        case .seed: "leaf.fill"
        case .tool(let tool): tool.symbol
        }
    }
}

struct GardenProduction: Hashable, Sendable {
    let reward: GardenRewardKind
    let amount: Int
    let cooldown: TimeInterval
    let action: String
}

struct GardenActivityDefinition: Hashable, Sendable {
    let name: String
    let detail: String
    let symbol: String
    let reward: GardenRewardKind?
    let amount: Int
    let restoration: Int
    let cooldown: TimeInterval
}

/// Small recurring jobs make every district useful even before the player owns
/// enough decorations to fill it. Their locations are authored into the estate.
enum GardenActivityID: String, CaseIterable, Codable, Identifiable, Hashable, Sendable {
    case tidyLeaves
    case communityBoard
    case fillBirdFeeder
    case gatherWildSeeds
    case countButterflies
    case removeLitter
    case collectFruitCrate
    case pruneBranches
    case inspectHive
    case fillWateringCan
    case clearReeds
    case feedDucks
    case turnCompost
    case takeCutting
    case repairTools

    var id: String { rawValue }

    var region: GardenRegion {
        switch self {
        case .tidyLeaves, .communityBoard, .fillBirdFeeder: .courtyard
        case .gatherWildSeeds, .countButterflies, .removeLitter: .meadow
        case .collectFruitCrate, .pruneBranches, .inspectHive: .orchard
        case .fillWateringCan, .clearReeds, .feedDucks: .waterside
        case .turnCompost, .takeCutting, .repairTools: .greenhouseYard
        }
    }

    var x: CGFloat {
        switch self {
        case .tidyLeaves: 0.15
        case .communityBoard: 0.84
        case .fillBirdFeeder: 0.49
        case .gatherWildSeeds: 0.15
        case .countButterflies: 0.42
        case .removeLitter: 0.28
        case .collectFruitCrate: 0.58
        case .pruneBranches: 0.84
        case .inspectHive: 0.72
        case .fillWateringCan: 0.15
        case .clearReeds: 0.40
        case .feedDucks: 0.25
        case .turnCompost: 0.56
        case .takeCutting: 0.84
        case .repairTools: 0.84
        }
    }

    var y: CGFloat {
        switch self {
        case .tidyLeaves: 0.77
        case .communityBoard: 0.79
        case .fillBirdFeeder: 0.93
        case .gatherWildSeeds: 0.44
        case .countButterflies: 0.46
        case .removeLitter: 0.58
        case .collectFruitCrate: 0.45
        case .pruneBranches: 0.48
        case .inspectHive: 0.58
        case .fillWateringCan: 0.19
        case .clearReeds: 0.23
        case .feedDucks: 0.30
        case .turnCompost: 0.08
        case .takeCutting: 0.10
        case .repairTools: 0.28
        }
    }

    var definition: GardenActivityDefinition {
        let hour: TimeInterval = 3_600
        return switch self {
        case .tidyLeaves:
            GardenActivityDefinition(name: "Sweep fallen leaves", detail: "Open the old courtyard paths.", symbol: "leaf.fill", reward: nil, amount: 0, restoration: 2, cooldown: 2 * hour)
        case .communityBoard:
            GardenActivityDefinition(name: "Read the noticeboard", detail: "Neighbours leave small thank-you gifts.", symbol: "text.bubble.fill", reward: .coins, amount: 3, restoration: 1, cooldown: 4 * hour)
        case .fillBirdFeeder:
            GardenActivityDefinition(name: "Check the bird feeder", detail: "Birds carry seeds from nearby gardens.", symbol: "bird.fill", reward: .seed, amount: 1, restoration: 1, cooldown: 5 * hour)
        case .gatherWildSeeds:
            GardenActivityDefinition(name: "Gather wild seeds", detail: "Save a few seeds for the next relay.", symbol: "laurel.leading", reward: .seed, amount: 1, restoration: 1, cooldown: 4 * hour)
        case .countButterflies:
            GardenActivityDefinition(name: "Follow the butterflies", detail: "They lead you to a fresh bloom.", symbol: "butterfly.fill", reward: .flower, amount: 1, restoration: 1, cooldown: 6 * hour)
        case .removeLitter:
            GardenActivityDefinition(name: "Clear windblown litter", detail: "A cleaner meadow welcomes pollinators.", symbol: "trash.slash.fill", reward: .coins, amount: 2, restoration: 3, cooldown: 3 * hour)
        case .collectFruitCrate:
            GardenActivityDefinition(name: "Collect the fruit crate", detail: "Share the harvest at the local market.", symbol: "shippingbox.fill", reward: .coins, amount: 10, restoration: 1, cooldown: 6 * hour)
        case .pruneBranches:
            GardenActivityDefinition(name: "Prune fallen branches", detail: "Healthy trees open the orchard canopy.", symbol: "scissors", reward: .tool(.shears), amount: 1, restoration: 2, cooldown: 8 * hour)
        case .inspectHive:
            GardenActivityDefinition(name: "Inspect the orchard hive", detail: "The bees leave useful seeds behind.", symbol: "ant.fill", reward: .seed, amount: 2, restoration: 1, cooldown: 6 * hour)
        case .fillWateringCan:
            GardenActivityDefinition(name: "Fill the watering can", detail: "Fresh pond water is ready for a relay.", symbol: "drop.fill", reward: .tool(.water), amount: 1, restoration: 1, cooldown: 4 * hour)
        case .clearReeds:
            GardenActivityDefinition(name: "Clear the overgrown reeds", detail: "Let light and water move through again.", symbol: "water.waves", reward: nil, amount: 0, restoration: 3, cooldown: 3 * hour)
        case .feedDucks:
            GardenActivityDefinition(name: "Visit the ducks", detail: "A lively pond draws the community closer.", symbol: "bird.fill", reward: .coins, amount: 4, restoration: 1, cooldown: 5 * hour)
        case .turnCompost:
            GardenActivityDefinition(name: "Turn the compost", detail: "Yesterday's cuttings become tomorrow's soil.", symbol: "leaf.arrow.circlepath", reward: .tool(.compost), amount: 1, restoration: 2, cooldown: 6 * hour)
        case .takeCutting:
            GardenActivityDefinition(name: "Take a greenhouse cutting", detail: "Raise a new flower for the community.", symbol: "camera.macro", reward: .flower, amount: 1, restoration: 1, cooldown: 8 * hour)
        case .repairTools:
            GardenActivityDefinition(name: "Repair the garden tools", detail: "Well-kept tools make care go further.", symbol: "wrench.and.screwdriver.fill", reward: .tool(.fertilizer), amount: 1, restoration: 2, cooldown: 8 * hour)
        }
    }
}

enum GardenClock {
    static func short(_ interval: TimeInterval) -> String {
        let minutes = max(1, Int(ceil(interval / 60)))
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        let remainder = minutes % 60
        return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
    }
}

extension DecorID {
    /// Productive decorations make the estate useful between puzzle sessions.
    /// Every object still restores its district passively even without a reward.
    var gardenProduction: GardenProduction? {
        let hour: TimeInterval = 3_600
        return switch self {
        case .pathStone:
            nil
        case .communityBench:
            GardenProduction(reward: .coins, amount: 4, cooldown: 4 * hour, action: "Welcome neighbours")
        case .planterBox:
            GardenProduction(reward: .flower, amount: 1, cooldown: 4 * hour, action: "Gather a bloom")
        case .lantern:
            GardenProduction(reward: .coins, amount: 6, cooldown: 6 * hour, action: "Light the evening path")
        case .birdbath:
            GardenProduction(reward: .seed, amount: 1, cooldown: 5 * hour, action: "Welcome the birds")
        case .beeHotel:
            GardenProduction(reward: .seed, amount: 1, cooldown: 4 * hour, action: "Check the bee hotel")
        case .rainBarrel, .pond, .willowTree:
            GardenProduction(reward: .tool(.water), amount: 1, cooldown: 4 * hour, action: "Collect water")
        case .compostBin:
            GardenProduction(reward: .tool(.compost), amount: 1, cooldown: 5 * hour, action: "Turn the compost")
        case .herbSpiral:
            GardenProduction(reward: .tool(.fertilizer), amount: 1, cooldown: 6 * hour, action: "Clip useful herbs")
        case .birdhouse:
            GardenProduction(reward: .seed, amount: 1, cooldown: 6 * hour, action: "Collect a dropped seed")
        case .gardenArch, .pergola:
            GardenProduction(reward: .coins, amount: 8, cooldown: 8 * hour, action: "Host a garden visit")
        case .sundial:
            GardenProduction(reward: .coins, amount: 5, cooldown: 6 * hour, action: "Read the sundial")
        case .appleTree, .pearTree, .cherryTree, .lemonTree:
            GardenProduction(reward: .coins, amount: 12, cooldown: 6 * hour, action: "Gather the harvest")
        case .mapleTree:
            GardenProduction(reward: .coins, amount: 8, cooldown: 8 * hour, action: "Rest in the shade")
        }
    }

    var restorationRate: Int {
        switch category {
        case .paths: 1
        case .decor: 2
        case .utilities: 3
        case .flowers, .trees: 2
        }
    }
}

/// Curated terrain rules make every placement belong to the rendered scene.
/// They replace the former free-form hidden grid while retaining its cell IDs.
enum GardenPlacementRules {
    static func spotKind(at cell: GardenCell) -> GardenSpotKind {
        switch GardenRegion.region(for: cell) {
        case .courtyard:
            if [GardenCell(5, 0), GardenCell(5, 5), GardenCell(6, 3)].contains(cell) { return .path }
            if [GardenCell(5, 1), GardenCell(5, 2), GardenCell(5, 4), GardenCell(6, 1), GardenCell(6, 2), GardenCell(6, 4)].contains(cell) { return .flowerBed }
            return .lawn
        case .meadow:
            return cell == GardenCell(3, 2) ? .service : .flowerBed
        case .orchard:
            return cell.col == 5 ? .flowerBed : .orchard
        case .waterside:
            if [GardenCell(2, 2), GardenCell(1, 2), GardenCell(0, 2)].contains(cell) { return .waterside }
            if cell.col == 1 { return .lawn }
            return .path
        case .greenhouseYard:
            if cell.col == 3 { return .service }
            if cell.col == 4 { return .flowerBed }
            return .lawn
        }
    }

    static func canPlantFlower(at cell: GardenCell) -> Bool {
        spotKind(at: cell) == .flowerBed
    }

    static func canPlace(_ decor: DecorID, at cell: GardenCell) -> Bool {
        let spot = spotKind(at: cell)
        let region = GardenRegion.region(for: cell)
        switch decor {
        case .pathStone:
            return spot == .path
        case .appleTree, .pearTree, .cherryTree:
            return region == .orchard && spot == .orchard
        case .lemonTree:
            return region == .greenhouseYard && spot == .lawn
        case .mapleTree:
            return spot == .lawn && region != .greenhouseYard
        case .willowTree:
            return region == .waterside && spot == .waterside
        case .pond:
            return region == .waterside && spot == .waterside
        case .compostBin, .rainBarrel:
            return spot == .service
        case .beeHotel:
            return spot == .service || (region == .meadow && spot == .flowerBed)
        case .planterBox, .herbSpiral:
            return spot == .flowerBed || spot == .lawn
        case .communityBench, .birdbath, .pergola:
            return spot == .lawn || spot == .waterside
        case .lantern, .birdhouse, .gardenArch, .sundial:
            return spot == .lawn || spot == .path || spot == .service
        }
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
    var itemPlacedAt: [UUID: Date] = [:]
    var itemLastCollectedAt: [UUID: Date] = [:]
    var regionCare: [GardenRegion: Int] = [:]
    var regionLastTendedAt: [GardenRegion: Date] = [:]
    var activityLastCompletedAt: [GardenActivityID: Date] = [:]

    init(
        decor: [PlacedDecor] = [],
        flowers: [PlantedFlower] = [],
        inventory: [DecorID: Int] = [:],
        itemPlacedAt: [UUID: Date] = [:],
        itemLastCollectedAt: [UUID: Date] = [:],
        regionCare: [GardenRegion: Int] = [:],
        regionLastTendedAt: [GardenRegion: Date] = [:],
        activityLastCompletedAt: [GardenActivityID: Date] = [:]
    ) {
        self.decor = decor
        self.flowers = flowers
        self.inventory = inventory
        self.itemPlacedAt = itemPlacedAt
        self.itemLastCollectedAt = itemLastCollectedAt
        self.regionCare = regionCare
        self.regionLastTendedAt = regionLastTendedAt
        self.activityLastCompletedAt = activityLastCompletedAt
    }

    private enum CodingKeys: String, CodingKey {
        case decor, flowers, inventory, itemPlacedAt, itemLastCollectedAt, regionCare, regionLastTendedAt, activityLastCompletedAt
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        decor = try values.decodeIfPresent([PlacedDecor].self, forKey: .decor) ?? []
        flowers = try values.decodeIfPresent([PlantedFlower].self, forKey: .flowers) ?? []
        inventory = try values.decodeIfPresent([DecorID: Int].self, forKey: .inventory) ?? [:]
        itemPlacedAt = try values.decodeIfPresent([UUID: Date].self, forKey: .itemPlacedAt) ?? [:]
        itemLastCollectedAt = try values.decodeIfPresent([UUID: Date].self, forKey: .itemLastCollectedAt) ?? [:]
        regionCare = try values.decodeIfPresent([GardenRegion: Int].self, forKey: .regionCare) ?? [:]
        regionLastTendedAt = try values.decodeIfPresent([GardenRegion: Date].self, forKey: .regionLastTendedAt) ?? [:]
        activityLastCompletedAt = try values.decodeIfPresent([GardenActivityID: Date].self, forKey: .activityLastCompletedAt) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(decor, forKey: .decor)
        try values.encode(flowers, forKey: .flowers)
        try values.encode(inventory, forKey: .inventory)
        try values.encode(itemPlacedAt, forKey: .itemPlacedAt)
        try values.encode(itemLastCollectedAt, forKey: .itemLastCollectedAt)
        try values.encode(regionCare, forKey: .regionCare)
        try values.encode(regionLastTendedAt, forKey: .regionLastTendedAt)
        try values.encode(activityLastCompletedAt, forKey: .activityLastCompletedAt)
    }

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
    mutating func place(_ piece: DecorID, at cell: GardenCell, date: Date = Date()) -> Bool {
        guard isFree(cell), inventory[piece, default: 0] > 0 else { return false }
        inventory[piece, default: 0] -= 1
        let placed = PlacedDecor(decor: piece, cell: cell)
        decor.append(placed)
        itemPlacedAt[placed.id] = date
        return true
    }

    @discardableResult
    mutating func plant(_ kind: FlowerKind, at cell: GardenCell, date: Date = Date()) -> Bool {
        guard isFree(cell) else { return false }
        let flower = PlantedFlower(kind: kind, cell: cell)
        flowers.append(flower)
        itemPlacedAt[flower.id] = date
        return true
    }

    /// Returns the piece to inventory.
    mutating func pickUp(decorID: UUID) {
        guard let index = decor.firstIndex(where: { $0.id == decorID }) else { return }
        let piece = decor.remove(at: index)
        inventory[piece.decor, default: 0] += 1
        itemPlacedAt[decorID] = nil
        itemLastCollectedAt[decorID] = nil
    }

    /// Returns the flower kind so the caller can put it back in the basket.
    mutating func uproot(flowerID: UUID) -> FlowerKind? {
        guard let index = flowers.firstIndex(where: { $0.id == flowerID }) else { return nil }
        let kind = flowers.remove(at: index).kind
        itemPlacedAt[flowerID] = nil
        itemLastCollectedAt[flowerID] = nil
        return kind
    }

    var hasBench: Bool { count(of: .communityBench) > 0 }
    var hasBees: Bool { count(of: .beeHotel) > 0 || count(of: .lavender) >= 2 }
    var hasBirds: Bool { count(of: .birdbath) > 0 || count(of: .birdhouse) > 0 }
    var treeCount: Int { decor.filter { $0.decor.treeKind != nil }.count }
    var distinctFlowerCount: Int { Set(flowers.map(\.kind)).count }

    func life(in region: GardenRegion) -> Int {
        let regionalDecor = decor.filter { GardenRegion.region(for: $0.cell) == region }
        let regionalFlowers = flowers.filter { GardenRegion.region(for: $0.cell) == region }
        return regionalDecor.reduce(0) { $0 + ($1.decor.category == .paths ? 1 : 3) } + regionalFlowers.count * 2
    }

    func passiveRestoration(in region: GardenRegion, at date: Date = Date()) -> Int {
        let decorPoints = decor
            .filter { GardenRegion.region(for: $0.cell) == region }
            .reduce(0) { total, item in
                let placed = itemPlacedAt[item.id] ?? date
                let ticks = min(8, max(0, Int(date.timeIntervalSince(placed) / (6 * 3_600))))
                return total + ticks * item.decor.restorationRate
            }
        let flowerPoints = flowers
            .filter { GardenRegion.region(for: $0.cell) == region }
            .reduce(0) { total, flower in
                let placed = itemPlacedAt[flower.id] ?? date
                return total + min(4, max(0, Int(date.timeIntervalSince(placed) / (12 * 3_600))))
            }
        return decorPoints + flowerPoints
    }

    func restorationProgress(in region: GardenRegion, at date: Date = Date()) -> Double {
        let points = life(in: region) + regionCare[region, default: 0] + passiveRestoration(in: region, at: date)
        return min(1, Double(points) / Double(region.restorationTarget))
    }

    func restorationStage(in region: GardenRegion, playerLevel: Int, at date: Date = Date()) -> GardenRestorationStage {
        guard region.isUnlocked(playerLevel: playerLevel) else { return .shrouded }
        let progress = restorationProgress(in: region, at: date)
        if progress < 0.20 { return .neglected }
        if progress < 0.72 { return .recovering }
        return .thriving
    }

    func remainingCollectionTime(for id: UUID, cooldown: TimeInterval, at date: Date = Date()) -> TimeInterval {
        guard let collected = itemLastCollectedAt[id] else { return 0 }
        return max(0, cooldown - date.timeIntervalSince(collected))
    }

    func canCollect(from id: UUID, cooldown: TimeInterval, at date: Date = Date()) -> Bool {
        remainingCollectionTime(for: id, cooldown: cooldown, at: date) <= 0
    }

    static let regionTendCooldown: TimeInterval = 60 * 60
    static let flowerHarvestCooldown: TimeInterval = 6 * 60 * 60

    func remainingTendTime(in region: GardenRegion, at date: Date = Date()) -> TimeInterval {
        guard let tended = regionLastTendedAt[region] else { return 0 }
        return max(0, Self.regionTendCooldown - date.timeIntervalSince(tended))
    }

    func canTend(_ region: GardenRegion, at date: Date = Date()) -> Bool {
        remainingTendTime(in: region, at: date) <= 0
    }

    func remainingActivityTime(for activity: GardenActivityID, at date: Date = Date()) -> TimeInterval {
        guard let completed = activityLastCompletedAt[activity] else { return 0 }
        return max(0, activity.definition.cooldown - date.timeIntervalSince(completed))
    }

    func canComplete(_ activity: GardenActivityID, at date: Date = Date()) -> Bool {
        remainingActivityTime(for: activity, at: date) <= 0
    }

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
    case diverseBorders
    case youngOrchard
    case pondRetreat

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
        case .diverseBorders: "A garden of many kinds"
        case .youngOrchard: "Plant the neighbourhood orchard"
        case .pondRetreat: "Make a pond retreat"
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
        case .diverseBorders: "Grow eight different flower species across the estate."
        case .youngOrchard: "Place three trees in the orchard."
        case .pondRetreat: "Place a pond, a bench, and a willow near the water."
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
        case .diverseBorders: 240
        case .youngOrchard: 300
        case .pondRetreat: 400
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
        case .diverseBorders: garden.distinctFlowerCount >= 8
        case .youngOrchard:
            garden.decor.filter { $0.decor.treeKind != nil && GardenRegion.region(for: $0.cell) == .orchard }.count >= 3
        case .pondRetreat:
            garden.decor.contains { $0.decor == .pond && GardenRegion.region(for: $0.cell) == .waterside }
                && garden.decor.contains { $0.decor == .communityBench && GardenRegion.region(for: $0.cell) == .waterside }
                && garden.decor.contains { $0.decor == .willowTree && GardenRegion.region(for: $0.cell) == .waterside }
        }
    }
}
