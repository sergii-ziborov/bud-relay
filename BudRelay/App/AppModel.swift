import Foundation
import SwiftUI

enum Screen: Equatable {
    case home
    case play
    case result
    case map
    case garden
    case greenhouse
    case market
    case daily
    case settings
    case howToPlay
}

@MainActor
@Observable
final class AppModel {
    var screen: Screen = .home
    var progress: ProgressState
    var session: PlaySession?
    var outcome: LevelOutcome?
    var sceneQueue: [StoryScene] = []
    var notice: String?

    private let store: ProgressStore
    private var noticeTask: Task<Void, Never>?
    let uiTesting: Bool

    init(store: ProgressStore = ProgressStore()) {
        self.store = store
        uiTesting = ProcessInfo.processInfo.arguments.contains("ui-testing")
        if uiTesting {
            var fresh = ProgressState.fresh
            fresh.tutorialSeen = true
            fresh.seenScenes = ProcessInfo.processInfo.arguments.contains("show-welcome") ? [] : ["welcome"]
            if ProcessInfo.processInfo.arguments.contains("demo-progress") {
                fresh = AppModel.demoProgress(from: fresh)
            }
            progress = fresh
        } else {
            progress = store.load()
        }
    }

    /// A lived-in save for screenshots and UI tests.
    static func demoProgress(from base: ProgressState) -> ProgressState {
        var demo = base
        for id in 1...9 {
            demo.stars[id] = id % 3 == 0 ? 2 : 3
        }
        demo.coins = 1_240
        demo.flowers = [.daisy: 6, .tulip: 4, .sunflower: 3, .lavender: 5, .rose: 2, .marigold: 3]
        demo.seeds = [.daisy: 2, .tulip: 1, .lavender: 1]
        demo.unlockedKinds = [.daisy, .tulip, .sunflower, .lavender]
        demo.bloomCounts = [.daisy: 34, .tulip: 21, .sunflower: 12, .lavender: 18, .marigold: 6]
        demo.levelsWon = 14
        demo.lifetimeLongestChain = 6
        demo.lifetimeBloomed = 91
        demo.garden.inventory = [.pathStone: 4, .lantern: 1, .planterBox: 2, .compostBin: 1]
        demo.garden.decor = [
            PlacedDecor(decor: .communityBench, cell: GardenCell(2, 2)),
            PlacedDecor(decor: .birdbath, cell: GardenCell(4, 4)),
            PlacedDecor(decor: .pathStone, cell: GardenCell(6, 2)),
            PlacedDecor(decor: .pathStone, cell: GardenCell(5, 2)),
            PlacedDecor(decor: .pathStone, cell: GardenCell(4, 2)),
            PlacedDecor(decor: .lantern, cell: GardenCell(2, 3)),
        ]
        demo.garden.flowers = [
            PlantedFlower(kind: .lavender, cell: GardenCell(1, 0)),
            PlantedFlower(kind: .lavender, cell: GardenCell(1, 1)),
            PlantedFlower(kind: .tulip, cell: GardenCell(0, 4)),
            PlantedFlower(kind: .sunflower, cell: GardenCell(0, 5)),
            PlantedFlower(kind: .daisy, cell: GardenCell(3, 0)),
            PlantedFlower(kind: .rose, cell: GardenCell(5, 5)),
            PlantedFlower(kind: .marigold, cell: GardenCell(6, 0)),
        ]
        demo.gardenGoalsDone = [.restoreBeds, .placeToSit, .waterForBirds, .eveningLight]
        demo.market.completed = 3
        demo.ordersCompleted = 3
        demo.daily = [
            DailyRecord(day: DailyBloom.dayNumber() - 2, bestChain: 4, bloomed: 11),
            DailyRecord(day: DailyBloom.dayNumber() - 1, bestChain: 5, bloomed: 13),
        ]
        demo.dailyStreak = 2
        demo.lastDailyDay = DailyBloom.dayNumber() - 1
        demo.seenScenes = StoryCatalog.byLevel.filter { $0.key <= 9 }.map(\.value.id) + ["welcome", "bench"]
        return demo
    }

    // MARK: - Navigation

    func go(_ destination: Screen) {
        screen = destination
    }

    func goHome() {
        session = nil
        outcome = nil
        screen = .home
    }

    func showWelcomeIfNeeded() {
        guard !progress.seenScenes.contains("welcome") else { return }
        enqueue(.firstLaunch)
    }

    // MARK: - Levels

    func playNext() {
        play(level: progress.nextLevelID)
    }

    func play(level id: Int) {
        guard let level = LevelCatalog.level(id), progress.isUnlocked(level: id) else { return }
        start(level: level, seed: UInt64.random(in: 1...UInt64.max), daily: false)
    }

    func playDaily() {
        let day = DailyBloom.dayNumber()
        start(level: DailyBloom.level(for: day), seed: DailyBloom.seed(for: day), daily: true)
    }

    func retry() {
        guard let session else { return }
        if session.isDaily {
            playDaily()
        } else {
            play(level: session.level.id)
        }
    }

    func nextLevel() {
        guard let outcome, !outcome.isDaily else {
            goHome()
            return
        }
        let next = outcome.levelID + 1
        if LevelCatalog.level(next) != nil, progress.isUnlocked(level: next) {
            play(level: next)
        } else {
            goHome()
        }
    }

    private func start(level: LevelDef, seed: UInt64, daily: Bool) {
        let session = PlaySession(
            level: level,
            seed: seed,
            ownedTools: progress.supplies,
            isDaily: daily,
            hapticsEnabled: progress.hapticsEnabled
        )
        session.onFinished = { [weak self] in self?.finishLevel() }
        self.session = session
        outcome = nil
        screen = .play
    }

    func abandonLevel() {
        guard let session else { return }
        progress.supplies = session.ownedTools
        save()
        goHome()
    }

    func finishLevel() {
        guard let session else { return }
        let run = session.run
        progress.supplies = run.ownedTools
        let firstClear = !session.isDaily && run.won && !progress.isCompleted(run.level.id)
        var dailyBest = false
        if session.isDaily {
            let day = DailyBloom.dayNumber()
            if let index = progress.daily.firstIndex(where: { $0.day == day }) {
                dailyBest = run.stats.longestChain > progress.daily[index].bestChain
                progress.daily[index].bestChain = max(progress.daily[index].bestChain, run.stats.longestChain)
                progress.daily[index].bloomed = max(progress.daily[index].bloomed, run.stats.bloomed)
            } else {
                dailyBest = run.stats.longestChain > 0
                progress.daily.append(DailyRecord(day: day, bestChain: run.stats.longestChain, bloomed: run.stats.bloomed))
                if let last = progress.lastDailyDay, day - last == 1 {
                    progress.dailyStreak += 1
                } else if progress.lastDailyDay != day {
                    progress.dailyStreak = 1
                }
                progress.lastDailyDay = day
            }
            progress.daily = Array(progress.daily.suffix(30))
        }
        var result = Rewards.outcome(run: run, isDaily: session.isDaily, firstClear: firstClear, dailyBest: dailyBest)

        progress.coins += result.coins
        for (kind, count) in result.flowers {
            progress.flowers[kind, default: 0] += count
        }
        for (kind, count) in result.seeds {
            progress.seeds[kind, default: 0] += count
        }
        for (kind, count) in run.stats.bloomedByKind {
            progress.bloomCounts[kind, default: 0] += count
        }
        progress.lifetimeBloomed += run.stats.bloomed
        progress.lifetimeLongestChain = max(progress.lifetimeLongestChain, run.stats.longestChain)

        if run.won, !session.isDaily {
            progress.levelsWon += 1
            progress.stars[run.level.id] = max(progress.stars(for: run.level.id), result.stars)
            if firstClear {
                if let kind = LevelCatalog.unlock(afterCompleting: run.level.id), !progress.unlockedKinds.contains(kind) {
                    progress.unlockedKinds.append(kind)
                    result.unlockedKind = kind
                }
                if let decor = DecorID.earned(atLevel: run.level.id) {
                    progress.garden.inventory[decor, default: 0] += 1
                    result.unlockedDecor = decor
                }
                enqueue(.levelCompleted(run.level.id))
            }
        }
        outcome = result
        save()
        screen = .result
    }

    // MARK: - Garden

    func placeDecor(_ decor: DecorID, at cell: GardenCell) {
        guard progress.garden.place(decor, at: cell) else { return }
        gardenChanged()
    }

    func pickUpDecor(_ id: UUID) {
        progress.garden.pickUp(decorID: id)
        gardenChanged()
    }

    func plantFlower(_ kind: FlowerKind, at cell: GardenCell) {
        guard progress.flowers[kind, default: 0] > 0, progress.garden.plant(kind, at: cell) else { return }
        progress.flowers[kind, default: 0] -= 1
        gardenChanged()
    }

    func uprootFlower(_ id: UUID) {
        guard let kind = progress.garden.uproot(flowerID: id) else { return }
        progress.flowers[kind, default: 0] += 1
        gardenChanged()
    }

    var gardenGoals: [(goal: GardenGoal, done: Bool)] {
        GardenGoal.allCases.map { ($0, progress.gardenGoalsDone.contains($0)) }
    }

    private func gardenChanged() {
        for goal in GardenGoal.allCases where !progress.gardenGoalsDone.contains(goal) && goal.isDone(in: progress.garden) {
            progress.gardenGoalsDone.append(goal)
            progress.coins += goal.reward
            show(notice: "\(goal.title): +\(goal.reward) coins")
            enqueue(.gardenGoal(goal))
        }
        save()
    }

    // MARK: - Market

    func fulfil(orderSlot slot: Int) {
        guard progress.market.activeOrders.indices.contains(slot) else { return }
        let order = MarketCatalog.order(progress.market.activeOrders[slot])
        guard progress.canFulfil(order) else { return }
        for (kind, count) in order.needs {
            progress.flowers[kind, default: 0] -= count
        }
        progress.coins += order.coins
        if let decor = order.decor {
            progress.garden.inventory[decor, default: 0] += 1
        }
        progress.market.activeOrders[slot] = progress.market.nextOrder
        progress.market.nextOrder += 1
        progress.market.completed += 1
        progress.ordersCompleted += 1
        show(notice: "\(order.name) delivered: +\(order.coins) coins")
        if progress.hapticsEnabled { Feedback.success() }
        save()
    }

    func buySeed(_ kind: FlowerKind) {
        let price = MarketCatalog.seedPrice(kind)
        guard progress.isUnlocked(kind), progress.coins >= price else { return }
        progress.coins -= price
        progress.seeds[kind, default: 0] += 1
        save()
    }

    func buySupply(_ tool: Tool) {
        guard progress.coins >= tool.price else { return }
        progress.coins -= tool.price
        progress.supplies[tool, default: 0] += 1
        save()
    }

    func buyDecor(_ decor: DecorID) {
        guard let price = decor.price, progress.coins >= price else { return }
        progress.coins -= price
        progress.garden.inventory[decor, default: 0] += 1
        save()
    }

    func sell(_ kind: FlowerKind) {
        guard progress.flowers[kind, default: 0] > 0 else { return }
        progress.flowers[kind, default: 0] -= 1
        progress.coins += kind.value
        save()
    }

    var activeOrders: [Order] {
        progress.market.activeOrders.map(MarketCatalog.order)
    }

    // MARK: - Greenhouse

    func selectVariant(_ index: Int, for kind: FlowerKind) {
        guard index < progress.variantsUnlocked(for: kind) else { return }
        progress.variants[kind] = index
        save()
    }

    // MARK: - Settings

    func toggleHaptics() {
        progress.hapticsEnabled.toggle()
        save()
    }

    func markTutorialSeen() {
        progress.tutorialSeen = true
        save()
    }

    func resetProgress() {
        progress = .fresh
        progress.tutorialSeen = true
        store.save(progress)
    }

    func save() {
        store.save(progress)
    }

    // MARK: - Story

    private func enqueue(_ trigger: StoryTrigger) {
        guard let scene = StoryCatalog.scene(for: trigger), !progress.seenScenes.contains(scene.id) else { return }
        progress.seenScenes.append(scene.id)
        sceneQueue.append(scene)
        save()
    }

    var currentScene: StoryScene? { sceneQueue.first }

    func dismissScene() {
        guard !sceneQueue.isEmpty else { return }
        sceneQueue.removeFirst()
    }

    // MARK: - Notices

    func show(notice text: String) {
        notice = text
        noticeTask?.cancel()
        noticeTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            self?.notice = nil
        }
    }
}
