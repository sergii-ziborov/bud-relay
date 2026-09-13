import Foundation

enum ChapterID: String, CaseIterable, Codable, Identifiable, Sendable, Hashable {
    case communityGarden
    case rooftopGarden
    case schoolyardGarden
    case greenhouseMarket
    case lakesidePark
    case botanicalGarden

    var id: String { rawValue }

    var number: Int { (ChapterID.allCases.firstIndex(of: self) ?? 0) + 1 }

    var name: String {
        switch self {
        case .communityGarden: "Community Garden"
        case .rooftopGarden: "Rooftop Garden"
        case .schoolyardGarden: "Schoolyard Garden"
        case .greenhouseMarket: "Greenhouse Market"
        case .lakesidePark: "Lakeside Park"
        case .botanicalGarden: "Old Botanical Garden"
        }
    }

    var tagline: String {
        switch self {
        case .communityGarden: "Learn the relay. Wake up the first beds."
        case .rooftopGarden: "Tight planters and thirsty soil."
        case .schoolyardGarden: "Grow a mix, bring the bees."
        case .greenhouseMarket: "Roses, orders, and fertilizer."
        case .lakesidePark: "Rain one day, heat the next."
        case .botanicalGarden: "The longest relays in the district."
        }
    }

    var symbol: String {
        switch self {
        case .communityGarden: "leaf.fill"
        case .rooftopGarden: "building.2.fill"
        case .schoolyardGarden: "graduationcap.fill"
        case .greenhouseMarket: "storefront.fill"
        case .lakesidePark: "water.waves"
        case .botanicalGarden: "building.columns.fill"
        }
    }

    var levelRange: ClosedRange<Int> {
        let start = (number - 1) * 10 + 1
        return start...(start + 9)
    }
}

struct PresetPlant: Hashable, Sendable {
    let cell: Cell
    let kind: FlowerKind
    let turns: Int
}

struct StarThresholds: Hashable, Sendable {
    let two: Int
    let three: Int
}

struct LevelDef: Identifiable, Hashable, Sendable {
    let id: Int
    let chapter: ChapterID
    let goals: [Goal]
    let turns: Int
    let kinds: [FlowerKind]
    let weather: Weather
    let blocked: [Cell]
    let preset: [PresetPlant]
    let dry: [Cell]
    let stars: StarThresholds
    let grants: [Tool: Int]
    let hints: Int

    var indexInChapter: Int { (id - 1) % 10 + 1 }
    var title: String { "Level \(id)" }

    func initialBoard() -> Board {
        var board = Board()
        board.block(blocked)
        for plant in preset where board.canPlant(at: plant.cell) {
            board[plant.cell].plant = Plant(kind: plant.kind, stage: .bud(turnsLeft: plant.turns))
        }
        if weather != .mild {
            board.setMoisture(.wet, at: board.usableCells)
        }
        board.setMoisture(.dry, at: dry)
        return board
    }
}

enum LevelCatalog {
    static let all: [LevelDef] = build()

    static func level(_ id: Int) -> LevelDef? {
        guard id >= 1, id <= all.count else { return nil }
        return all[id - 1]
    }

    static func levels(in chapter: ChapterID) -> [LevelDef] {
        all.filter { $0.chapter == chapter }
    }

    static var count: Int { all.count }

    /// The flower each level introduces the first time it is completed.
    static func unlock(afterCompleting id: Int) -> FlowerKind? {
        switch id {
        case 6: .lavender
        case 14: .marigold
        case 18: .poppy
        case 24: .rose
        case 32: .daffodil
        case 40: .hydrangea
        case 42: .iris
        case 48: .aster
        case 54: .peony
        default: nil
        }
    }

    static let startingKinds: [FlowerKind] = [.daisy, .tulip, .sunflower]

    // MARK: - Patterns

    private static let corners = [Cell(0, 0), Cell(0, 4), Cell(4, 0), Cell(4, 4)]
    private static let pillars = [Cell(1, 1), Cell(1, 3), Cell(3, 1), Cell(3, 3)]
    private static let centerStone = [Cell(2, 2)]
    private static let leftWall = (0..<5).map { Cell($0, 0) }
    private static let topWall = (0..<5).map { Cell(0, $0) }
    private static let rooftopL = [Cell(0, 0), Cell(0, 1), Cell(1, 0), Cell(4, 4), Cell(4, 3), Cell(3, 4)]
    private static let plankRow = [Cell(2, 0), Cell(2, 1), Cell(2, 3), Cell(2, 4)]
    private static let pondCells = [Cell(1, 2), Cell(2, 1), Cell(2, 2), Cell(2, 3), Cell(3, 2)]
    private static let path = [Cell(0, 2), Cell(1, 2), Cell(3, 2), Cell(4, 2)]
    private static let terrace = [Cell(0, 0), Cell(0, 1), Cell(0, 2), Cell(4, 4), Cell(4, 3), Cell(4, 2)]

    private static let ring = [Cell(1, 1), Cell(1, 2), Cell(1, 3), Cell(2, 1), Cell(2, 3), Cell(3, 1), Cell(3, 2), Cell(3, 3)]
    private static let edgeMiddles = [Cell(0, 2), Cell(2, 0), Cell(2, 4), Cell(4, 2)]
    private static let diagonal = [Cell(0, 0), Cell(1, 1), Cell(2, 2), Cell(3, 3), Cell(4, 4)]

    private static func buds(_ kind: FlowerKind, turns: Int, at cells: [Cell]) -> [PresetPlant] {
        cells.map { PresetPlant(cell: $0, kind: kind, turns: turns) }
    }

    private static let base3: [FlowerKind] = [.daisy, .tulip, .sunflower]
    private static let withLavender: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender]
    private static let withMarigold: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender, .marigold]
    private static let allSix: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender, .marigold, .rose]
    private static let rooftopLateKinds = withMarigold + [FlowerKind.poppy]
    private static let withDaffodil = allSix + [FlowerKind.daffodil]
    private static let lakesideKinds = withDaffodil + [FlowerKind.hydrangea]
    private static let lakesideIrisKinds = lakesideKinds + [FlowerKind.iris]
    private static let lateLakesideKinds: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender, .rose, .daffodil, .hydrangea, .aster]
    private static let botanicalKinds: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender, .rose, .daffodil, .hydrangea, .aster]
    private static let botanicalRareKinds: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender, .rose, .hydrangea, .aster, .peony]
    private static let botanicalHeatKinds: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender, .marigold, .hydrangea, .aster, .peony]

    // MARK: - Catalog

    private static func make(
        _ id: Int,
        _ chapter: ChapterID,
        goals: [Goal],
        turns: Int,
        kinds: [FlowerKind],
        weather: Weather = .mild,
        blocked: [Cell] = [],
        preset: [PresetPlant] = [],
        dry: [Cell] = [],
        stars: (Int, Int) = (2, 5),
        grants: [Tool: Int] = [:],
        hints: Int = 3
    ) -> LevelDef {
        LevelDef(
            id: id,
            chapter: chapter,
            goals: goals,
            turns: turns,
            kinds: kinds,
            weather: weather,
            blocked: blocked,
            preset: preset,
            dry: dry,
            stars: StarThresholds(two: stars.0, three: stars.1),
            grants: grants,
            hints: hints
        )
    }

    private static func build() -> [LevelDef] {
        var levels: [LevelDef] = []

        // Chapter 1 — Community Garden. Learn the relay.
        levels += [
            make(1, .communityGarden, goals: [.bloom(4)], turns: 8, kinds: [.daisy, .tulip], stars: (2, 4)),
            make(2, .communityGarden, goals: [.chain(2)], turns: 8, kinds: [.daisy, .tulip], stars: (3, 5)),
            make(3, .communityGarden, goals: [.bloom(8)], turns: 12, kinds: base3, stars: (2, 4)),
            make(4, .communityGarden, goals: [.chain(3)], turns: 12, kinds: base3, stars: (5, 8)),
            make(5, .communityGarden, goals: [.grow(.sunflower, 2), .bloom(8)], turns: 14, kinds: base3, stars: (3, 6)),
            make(6, .communityGarden, goals: [.chain(4)], turns: 14, kinds: base3, preset: buds(.tulip, turns: 4, at: [Cell(2, 1), Cell(2, 3)]), stars: (5, 8)),
            make(7, .communityGarden, goals: [.bloom(12)], turns: 17, kinds: withLavender, stars: (2, 4)),
            make(8, .communityGarden, goals: [.grow(.lavender, 3), .chain(3)], turns: 16, kinds: withLavender, stars: (3, 6)),
            make(9, .communityGarden, goals: [.chain(4), .bloom(10)], turns: 18, kinds: withLavender, blocked: centerStone, preset: buds(.tulip, turns: 4, at: [Cell(1, 2)]), stars: (3, 6)),
            make(10, .communityGarden, goals: [.chain(5)], turns: 18, kinds: withLavender, preset: buds(.rose, turns: 5, at: [Cell(2, 2)]) + buds(.tulip, turns: 5, at: [Cell(2, 0), Cell(2, 4)]), stars: (6, 10)),
        ]

        // Chapter 2 — Rooftop Garden. Tight planters and dry soil.
        levels += [
            make(11, .rooftopGarden, goals: [.bloom(8)], turns: 12, kinds: withLavender, blocked: corners, stars: (2, 4)),
            make(12, .rooftopGarden, goals: [.chain(3), .bloom(8)], turns: 14, kinds: withLavender, blocked: rooftopL, stars: (3, 6)),
            make(13, .rooftopGarden, goals: [.bloom(8)], turns: 14, kinds: withLavender, weather: .hotDay, stars: (3, 5), grants: [.water: 3]),
            make(14, .rooftopGarden, goals: [.chain(4)], turns: 16, kinds: withLavender, blocked: pillars, preset: buds(.tulip, turns: 4, at: [Cell(2, 2)]), stars: (6, 10)),
            make(15, .rooftopGarden, goals: [.grow(.marigold, 2), .bloom(8)], turns: 16, kinds: withMarigold, weather: .hotDay, stars: (3, 6), grants: [.water: 2, .mulch: 1]),
            make(16, .rooftopGarden, goals: [.bloom(12)], turns: 17, kinds: withMarigold, blocked: plankRow, stars: (2, 4)),
            make(17, .rooftopGarden, goals: [.chain(4), .grow(.tulip, 3)], turns: 22, kinds: withMarigold, weather: .hotDay, blocked: corners, preset: buds(.tulip, turns: 4, at: [Cell(2, 2), Cell(2, 3)]), stars: (3, 7), grants: [.water: 4]),
            make(18, .rooftopGarden, goals: [.emptyPlots(6), .bloom(10)], turns: 16, kinds: withMarigold, blocked: rooftopL, stars: (3, 5)),
            make(19, .rooftopGarden, goals: [.grow(.poppy, 2), .chain(4)], turns: 19, kinds: rooftopLateKinds, blocked: leftWall, preset: buds(.tulip, turns: 4, at: [Cell(1, 2), Cell(3, 2)]) + buds(.sunflower, turns: 5, at: [Cell(2, 2)]), stars: (6, 10)),
            make(20, .rooftopGarden, goals: [.chain(4), .bloom(12)], turns: 24, kinds: rooftopLateKinds, weather: .hotDay, blocked: pillars, preset: buds(.tulip, turns: 4, at: [Cell(2, 1), Cell(2, 2), Cell(2, 3)]), stars: (3, 6), grants: [.water: 4, .mulch: 2]),
        ]

        // Chapter 3 — Schoolyard Garden. Biodiversity and bees.
        levels += [
            make(21, .schoolyardGarden, goals: [.grow(.lavender, 3), .grow(.daisy, 3)], turns: 15, kinds: withMarigold, stars: (3, 5)),
            make(22, .schoolyardGarden, goals: [.pollinator(1)], turns: 14, kinds: withMarigold, preset: buds(.lavender, turns: 3, at: [Cell(2, 2)]), stars: (5, 9)),
            make(23, .schoolyardGarden, goals: [.pollinator(2), .bloom(8)], turns: 18, kinds: withMarigold, stars: (3, 6)),
            make(24, .schoolyardGarden, goals: [.grow(.sunflower, 3), .grow(.lavender, 3), .chain(3)], turns: 18, kinds: withMarigold, stars: (4, 7)),
            make(25, .schoolyardGarden, goals: [.pollinator(2), .chain(4)], turns: 19, kinds: allSix, blocked: centerStone, stars: (3, 6)),
            make(26, .schoolyardGarden, goals: [.grow(.rose, 2), .bloom(10)], turns: 18, kinds: allSix, stars: (4, 7)),
            make(27, .schoolyardGarden, goals: [.pollinator(3)], turns: 20, kinds: allSix, preset: buds(.lavender, turns: 3, at: [Cell(1, 1), Cell(3, 3)]), stars: (4, 8)),
            make(28, .schoolyardGarden, goals: [.chain(4), .grow(.marigold, 2)], turns: 18, kinds: allSix, blocked: corners, preset: buds(.tulip, turns: 4, at: [Cell(2, 2)]), stars: (3, 6)),
            make(29, .schoolyardGarden, goals: [.bloom(16)], turns: 21, kinds: allSix, weather: .rain, stars: (2, 4)),
            make(30, .schoolyardGarden, goals: [.pollinator(2), .chain(4)], turns: 20, kinds: allSix, preset: buds(.lavender, turns: 4, at: [Cell(2, 2)]) + buds(.sunflower, turns: 5, at: [Cell(2, 3)]), stars: (4, 8)),
        ]

        // Chapter 4 — Greenhouse Market. Harvest counts and fertilizer.
        levels += [
            make(31, .greenhouseMarket, goals: [.harvest(6)], turns: 14, kinds: allSix, stars: (3, 5)),
            make(32, .greenhouseMarket, goals: [.harvest(8), .grow(.rose, 2)], turns: 16, kinds: allSix, stars: (3, 5), grants: [.fertilizer: 1]),
            make(33, .greenhouseMarket, goals: [.grow(.daffodil, 2), .harvest(8)], turns: 20, kinds: withDaffodil, blocked: path, preset: buds(.tulip, turns: 4, at: [Cell(2, 2)]), stars: (3, 6)),
            make(34, .greenhouseMarket, goals: [.harvest(10)], turns: 18, kinds: withDaffodil, stars: (4, 6), grants: [.fertilizer: 2]),
            make(35, .greenhouseMarket, goals: [.grow(.rose, 3), .chain(4)], turns: 18, kinds: withDaffodil, preset: buds(.rose, turns: 5, at: [Cell(2, 2)]), stars: (5, 8)),
            make(36, .greenhouseMarket, goals: [.harvest(10), .pollinator(1)], turns: 18, kinds: withDaffodil, weather: .hotDay, stars: (3, 6), grants: [.water: 3, .mulch: 1]),
            make(37, .greenhouseMarket, goals: [.chain(5), .harvest(8)], turns: 24, kinds: withDaffodil, blocked: pillars, preset: buds(.tulip, turns: 4, at: edgeMiddles), stars: (4, 8)),
            make(38, .greenhouseMarket, goals: [.emptyPlots(8), .harvest(10)], turns: 18, kinds: withDaffodil, stars: (4, 6)),
            make(39, .greenhouseMarket, goals: [.harvest(12), .grow(.sunflower, 3)], turns: 22, kinds: withDaffodil, stars: (3, 5), grants: [.fertilizer: 2, .compost: 2]),
            make(40, .greenhouseMarket, goals: [.chain(6)], turns: 20, kinds: withDaffodil, preset: buds(.tulip, turns: 4, at: [Cell(1, 2), Cell(3, 2)]) + buds(.rose, turns: 4, at: [Cell(2, 1), Cell(2, 3)]), stars: (7, 11)),
        ]

        // Chapter 5 — Lakeside Park. Weather swings and pre-planted beds.
        levels += [
            make(41, .lakesidePark, goals: [.grow(.hydrangea, 2), .bloom(12)], turns: 18, kinds: lakesideKinds, weather: .rain, blocked: pondCells, stars: (2, 4)),
            make(42, .lakesidePark, goals: [.chain(4), .bloom(10)], turns: 18, kinds: lakesideKinds, weather: .hotDay, dry: topWall, stars: (3, 6), grants: [.water: 3]),
            make(43, .lakesidePark, goals: [.grow(.iris, 2), .chain(4)], turns: 20, kinds: lakesideIrisKinds, weather: .rain, preset: buds(.tulip, turns: 4, at: [Cell(1, 1), Cell(1, 3)]) + buds(.rose, turns: 5, at: [Cell(3, 2)]), stars: (5, 9)),
            make(44, .lakesidePark, goals: [.pollinator(2), .harvest(8)], turns: 20, kinds: lakesideKinds, blocked: terrace, stars: (4, 7)),
            make(45, .lakesidePark, goals: [.bloom(14), .emptyPlots(6)], turns: 20, kinds: lakesideKinds, weather: .hotDay, stars: (2, 4), grants: [.water: 4, .mulch: 2]),
            make(46, .lakesidePark, goals: [.chain(6)], turns: 22, kinds: lakesideKinds, weather: .rain, preset: buds(.tulip, turns: 5, at: [Cell(1, 2), Cell(3, 2)]) + buds(.sunflower, turns: 5, at: [Cell(2, 1), Cell(2, 3)]), stars: (7, 11)),
            make(47, .lakesidePark, goals: [.grow(.rose, 3), .grow(.lavender, 3), .chain(4)], turns: 24, kinds: lakesideKinds, blocked: pondCells, stars: (3, 6)),
            make(48, .lakesidePark, goals: [.chain(4), .pollinator(2)], turns: 28, kinds: lakesideKinds, weather: .hotDay, blocked: corners, preset: buds(.tulip, turns: 4, at: [Cell(2, 2)]), stars: (4, 8), grants: [.water: 7]),
            make(49, .lakesidePark, goals: [.grow(.aster, 3), .bloom(16)], turns: 24, kinds: lateLakesideKinds, weather: .rain, stars: (2, 4)),
            make(50, .lakesidePark, goals: [.chain(6), .harvest(10)], turns: 24, kinds: lateLakesideKinds, preset: buds(.tulip, turns: 5, at: pillars), stars: (4, 8)),
        ]

        // Chapter 6 — Old Botanical Garden. Everything at once.
        levels += [
            make(51, .botanicalGarden, goals: [.chain(5), .bloom(12)], turns: 22, kinds: allSix, blocked: pillars, preset: buds(.tulip, turns: 4, at: [Cell(2, 2)]) + buds(.sunflower, turns: 4, at: [Cell(0, 2), Cell(4, 2)]), stars: (3, 6)),
            make(52, .botanicalGarden, goals: [.chain(6)], turns: 22, kinds: botanicalKinds, blocked: centerStone, preset: buds(.tulip, turns: 5, at: [Cell(1, 2), Cell(3, 2), Cell(2, 1), Cell(2, 3)]), stars: (7, 11)),
            make(53, .botanicalGarden, goals: [.harvest(10), .pollinator(2)], turns: 26, kinds: botanicalKinds, weather: .hotDay, stars: (3, 6), grants: [.water: 4, .mulch: 2]),
            make(54, .botanicalGarden, goals: [.grow(.rose, 3), .chain(4)], turns: 24, kinds: botanicalKinds, stars: (4, 7), grants: [.compost: 3]),
            make(55, .botanicalGarden, goals: [.grow(.peony, 2), .chain(5)], turns: 26, kinds: botanicalRareKinds, blocked: corners, preset: buds(.tulip, turns: 4, at: [Cell(2, 1), Cell(2, 3)]), stars: (4, 8)),
            make(56, .botanicalGarden, goals: [.bloom(20)], turns: 26, kinds: botanicalRareKinds, weather: .rain, blocked: path, stars: (2, 4)),
            make(57, .botanicalGarden, goals: [.chain(7)], turns: 24, kinds: botanicalRareKinds, preset: buds(.tulip, turns: 5, at: pillars) + buds(.sunflower, turns: 5, at: [Cell(2, 2)]), stars: (7, 12)),
            make(58, .botanicalGarden, goals: [.pollinator(2), .harvest(8)], turns: 28, kinds: botanicalHeatKinds, weather: .hotDay, blocked: pillars, stars: (4, 7), grants: [.water: 4, .mulch: 2]),
            make(59, .botanicalGarden, goals: [.chain(5), .grow(.sunflower, 3)], turns: 26, kinds: botanicalRareKinds, blocked: terrace, preset: buds(.tulip, turns: 4, at: [Cell(2, 1), Cell(2, 3)]), stars: (4, 8)),
            make(60, .botanicalGarden, goals: [.chain(8)], turns: 26, kinds: botanicalRareKinds, preset: buds(.tulip, turns: 5, at: pillars) + buds(.sunflower, turns: 5, at: [Cell(0, 2), Cell(4, 2)]), stars: (7, 12), grants: [.compost: 2]),
        ]

        return levels
    }
}
