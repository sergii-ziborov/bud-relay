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
