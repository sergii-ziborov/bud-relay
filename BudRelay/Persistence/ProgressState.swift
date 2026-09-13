import Foundation

struct DailyRecord: Hashable, Codable, Sendable {
    let day: Int
    var bestChain: Int
    var bloomed: Int
}

struct ProgressState: Hashable, Codable, Sendable {
    var stars: [Int: Int] = [:]
    var coins: Int = 120
    var flowers: [FlowerKind: Int] = [:]
    var seeds: [FlowerKind: Int] = [.daisy: 1]
    var supplies: [Tool: Int] = [.water: 3, .compost: 1, .fertilizer: 1, .mulch: 1, .shears: 2]
    var unlockedKinds: [FlowerKind] = LevelCatalog.startingKinds
    var bloomCounts: [FlowerKind: Int] = [:]
    var variants: [FlowerKind: Int] = [:]
    var garden = GardenState()
    var gardenGoalsDone: [GardenGoal] = []
    var market = MarketState()
    var seenScenes: [String] = []
    var daily: [DailyRecord] = []
    var dailyStreak: Int = 0
    var lastDailyDay: Int?
    var hapticsEnabled = true
    var tutorialSeen = false
    var levelsWon = 0
    var lifetimeLongestChain = 0
    var lifetimeBloomed = 0
    var ordersCompleted = 0

    static let fresh = ProgressState()

    // MARK: - Levels

    func stars(for levelID: Int) -> Int {
        stars[levelID, default: 0]
    }

    var totalStars: Int {
        stars.values.reduce(0, +)
    }

    func isCompleted(_ levelID: Int) -> Bool {
        stars(for: levelID) > 0
    }

    func isUnlocked(level id: Int) -> Bool {
        id == 1 || isCompleted(id - 1)
    }

    func isUnlocked(_ chapter: ChapterID) -> Bool {
        isUnlocked(level: chapter.levelRange.lowerBound)
    }

    /// The first level not yet cleared, or the last one once everything is done.
    var nextLevelID: Int {
        for id in 1...LevelCatalog.count where !isCompleted(id) {
            return id
        }
        return LevelCatalog.count
    }

    var currentChapter: ChapterID {
        LevelCatalog.level(nextLevelID)?.chapter ?? .communityGarden
    }

    func stars(in chapter: ChapterID) -> Int {
        chapter.levelRange.reduce(0) { $0 + stars(for: $1) }
    }

    // MARK: - Greenhouse

    func variantsUnlocked(for kind: FlowerKind) -> Int {
        let count = bloomCounts[kind, default: 0]
        return FlowerKind.variantThresholds.filter { count >= $0 }.count
    }

    func variant(for kind: FlowerKind) -> Int {
        min(variants[kind, default: 0], max(0, variantsUnlocked(for: kind) - 1))
    }

    func isUnlocked(_ kind: FlowerKind) -> Bool {
        unlockedKinds.contains(kind)
    }

    func isUnlocked(_ tree: TreeKind) -> Bool {
        nextLevelID > tree.unlockLevel || isCompleted(tree.unlockLevel)
    }

    /// Adds species introduced by completed levels. This migrates older saves
    /// when a game update expands the field guide without touching other data.
    mutating func reconcileFlowerUnlocks() {
        for kind in LevelCatalog.startingKinds where !unlockedKinds.contains(kind) {
            unlockedKinds.append(kind)
        }
        for level in LevelCatalog.all where isCompleted(level.id) {
            if let kind = LevelCatalog.unlock(afterCompleting: level.id), !unlockedKinds.contains(kind) {
                unlockedKinds.append(kind)
            }
        }
    }

    /// Migrates gardens created by the former free-form grid into authored
    /// landscape sites. Compatible pieces keep their exact cell and identity;
    /// the rest move to the first suitable open site or return safely to the
    /// player's inventory/basket when the current estate has no room yet.
    mutating func reconcileGardenLayout(at date: Date = Date()) {
        let oldGarden = garden
        let openCells = GardenRegion.allCases.flatMap { region in
            Array(region.cells.prefix(region.capacity(at: playerLevel)))
        }
        var rebuilt = GardenState()
        rebuilt.inventory = oldGarden.inventory
        rebuilt.regionCare = oldGarden.regionCare
        rebuilt.regionLastTendedAt = oldGarden.regionLastTendedAt
        rebuilt.activityLastCompletedAt = oldGarden.activityLastCompletedAt
        var pendingDecor: [PlacedDecor] = []
        var pendingFlowers: [PlantedFlower] = []

        func copyTimers(for id: UUID, into state: inout GardenState) {
            state.itemPlacedAt[id] = oldGarden.itemPlacedAt[id] ?? date
            state.itemLastCollectedAt[id] = oldGarden.itemLastCollectedAt[id]
        }

        for item in oldGarden.decor {
            let region = GardenRegion.region(for: item.cell)
            if region.isOpen(item.cell, at: playerLevel),
               GardenPlacementRules.canPlace(item.decor, at: item.cell),
               rebuilt.isFree(item.cell) {
                rebuilt.decor.append(item)
                copyTimers(for: item.id, into: &rebuilt)
            } else {
                pendingDecor.append(item)
            }
        }
        for flower in oldGarden.flowers {
            let region = GardenRegion.region(for: flower.cell)
            if region.isOpen(flower.cell, at: playerLevel),
               GardenPlacementRules.canPlantFlower(at: flower.cell),
               rebuilt.isFree(flower.cell) {
                rebuilt.flowers.append(flower)
                copyTimers(for: flower.id, into: &rebuilt)
            } else {
                pendingFlowers.append(flower)
            }
        }

        for item in pendingDecor {
            if let destination = openCells.first(where: { rebuilt.isFree($0) && GardenPlacementRules.canPlace(item.decor, at: $0) }) {
                rebuilt.decor.append(PlacedDecor(id: item.id, decor: item.decor, cell: destination))
                copyTimers(for: item.id, into: &rebuilt)
            } else {
                rebuilt.inventory[item.decor, default: 0] += 1
            }
        }
        for flower in pendingFlowers {
            if let destination = openCells.first(where: { rebuilt.isFree($0) && GardenPlacementRules.canPlantFlower(at: $0) }) {
                rebuilt.flowers.append(PlantedFlower(id: flower.id, kind: flower.kind, cell: destination))
                copyTimers(for: flower.id, into: &rebuilt)
            } else {
                flowers[flower.kind, default: 0] += 1
            }
        }
        garden = rebuilt
    }

    var flowerCount: Int {
        flowers.values.reduce(0, +)
    }

    func canFulfil(_ order: Order) -> Bool {
        order.needs.allSatisfy { flowers[$0.key, default: 0] >= $0.value }
    }

    var streakIsAlive: Bool {
        guard let last = lastDailyDay else { return false }
        return DailyBloom.dayNumber() - last <= 1
    }

    var displayedStreak: Int {
        streakIsAlive ? dailyStreak : 0
    }

    func dailyRecord(for day: Int) -> DailyRecord? {
        daily.first { $0.day == day }
    }

    var playerLevel: Int {
        1 + totalStars / 6 + levelsWon / 4
    }
}
