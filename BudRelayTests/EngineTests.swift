import XCTest
@testable import BudRelay

final class DraftTests: XCTestCase {
    func testQueueIsDeterministic() {
        let a = Draft.queue(kinds: [.daisy, .tulip, .sunflower], seed: 42, count: 30)
        let b = Draft.queue(kinds: [.daisy, .tulip, .sunflower], seed: 42, count: 30)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, Draft.queue(kinds: [.daisy, .tulip, .sunflower], seed: 43, count: 30))
    }

    func testEveryBagHoldsEveryKind() {
        let kinds: [FlowerKind] = [.daisy, .tulip, .sunflower, .lavender]
        let queue = Draft.queue(kinds: kinds, seed: 7, count: Draft.bagSize * 5)
        for bag in stride(from: 0, to: queue.count, by: Draft.bagSize) {
            let slice = Set(queue[bag..<(bag + Draft.bagSize)])
            XCTAssertEqual(slice, Set(kinds))
        }
    }
}

final class LevelRunTests: XCTestCase {
    func testPlacingUsesTurnAndAdvancesHand() {
        guard let level = LevelCatalog.level(1) else { return XCTFail("missing level") }
        var run = LevelRun(level: level, seed: 1)
        let next = run.next
        let report = run.place(card: 0, at: Cell(2, 2))
        XCTAssertNotNil(report)
        XCTAssertEqual(run.turnsLeft, level.turns - 1)
        XCTAssertEqual(run.hand.count, 3)
        XCTAssertEqual(run.hand[2], next)
        XCTAssertNotNil(run.board[Cell(2, 2)].plant)
    }

    func testPlacingOnOccupiedPlotIsRefused() {
        guard let level = LevelCatalog.level(1) else { return XCTFail("missing level") }
        var run = LevelRun(level: level, seed: 1)
        run.place(card: 0, at: Cell(0, 0))
        XCTAssertNil(run.place(card: 0, at: Cell(0, 0)))
        XCTAssertEqual(run.turnsLeft, level.turns - 1)
    }

    func testFreeToolsAreSpentBeforeOwnedOnes() {
        guard let level = LevelCatalog.level(13) else { return XCTFail("missing level") }
        var run = LevelRun(level: level, seed: 1, ownedTools: [.water: 2])
        XCTAssertEqual(run.count(of: .water), 5)
        run.board.setMoisture(.dry, at: [Cell(2, 2), Cell(2, 3)])
        XCTAssertFalse(run.canUse(.water, at: Cell(0, 0)), "a wet corner with wet neighbours needs no water")
        XCTAssertTrue(run.use(.water, at: Cell(2, 2)))
        XCTAssertEqual(run.freeTools[.water], 2)
        XCTAssertEqual(run.ownedTools[.water], 2)
        XCTAssertEqual(run.board[Cell(2, 2)].moisture, .wet)
        XCTAssertEqual(run.board[Cell(2, 3)].moisture, .wet)
    }

    func testShearsRemoveAPlant() {
        guard let level = LevelCatalog.level(1) else { return XCTFail("missing level") }
        var run = LevelRun(level: level, seed: 3, ownedTools: [.shears: 1])
        run.place(card: 0, at: Cell(1, 1))
        XCTAssertTrue(run.use(.shears, at: Cell(1, 1)))
        XCTAssertNil(run.board[Cell(1, 1)].plant)
        XCTAssertFalse(run.canUse(.shears, at: Cell(1, 1)))
    }

    func testLevelEndsWhenTurnsRunOut() {
        guard let level = LevelCatalog.level(1) else { return XCTFail("missing level") }
        var run = LevelRun(level: level, seed: 5)
        var turns = 0
        while !run.isOver, turns < 50 {
            run.tend()
            turns += 1
        }
        XCTAssertTrue(run.isOver)
        XCTAssertFalse(run.won)
        XCTAssertEqual(turns, level.turns)
    }

    func testSeedSwapReplacesCard() {
        guard let level = LevelCatalog.level(1) else { return XCTFail("missing level") }
        var run = LevelRun(level: level, seed: 5)
        run.swap(card: 1, to: .sunflower)
        XCTAssertEqual(run.hand[1], .sunflower)
    }
}

final class LevelCatalogTests: XCTestCase {
    func testCatalogShape() {
        XCTAssertEqual(LevelCatalog.count, 60)
        XCTAssertEqual(LevelCatalog.all.map(\.id), Array(1...60))
        for chapter in ChapterID.allCases {
            XCTAssertEqual(LevelCatalog.levels(in: chapter).count, 10, chapter.name)
        }
    }

    func testLevelsOnlyUseFlowersAlreadyUnlocked() {
        var unlocked = Set(LevelCatalog.startingKinds)
        for level in LevelCatalog.all {
            XCTAssertTrue(Set(level.kinds).isSubset(of: unlocked), "level \(level.id) uses locked flowers")
            for goal in level.goals {
                if let kind = goal.kind {
                    XCTAssertTrue(level.kinds.contains(kind), "level \(level.id) asks for a flower it never deals")
                }
            }
            if let kind = LevelCatalog.unlock(afterCompleting: level.id) {
                unlocked.insert(kind)
            }
        }
    }

    func testPresetPlantsSitOnUsablePlots() {
        for level in LevelCatalog.all {
            let board = level.initialBoard()
            for plant in level.preset {
                XCTAssertFalse(level.blocked.contains(plant.cell), "level \(level.id) preset on a stone")
                XCTAssertNotNil(board[plant.cell].plant)
            }
            XCTAssertGreaterThanOrEqual(board.emptyCount, 12, "level \(level.id) leaves too little room")
        }
    }

    func testStarThresholdsFitInsideTurnBudget() {
        for level in LevelCatalog.all {
            XCTAssertLessThan(level.stars.three, level.turns, "level \(level.id)")
            XCTAssertLessThan(level.stars.two, level.stars.three, "level \(level.id)")
        }
    }

    func testEveryLevelIsBeatableByTheBot() {
        var failures: [String] = []
        for level in LevelCatalog.all {
            var wins = 0
            var bestStars = 0
            for seed in UInt64(1)...3 {
                let run = Bot.play(level: level, seed: seed, ownedTools: [.water: 2])
                if run.won { wins += 1 }
                bestStars = max(bestStars, run.stars)
            }
            let required = level.id <= 30 ? 2 : 1
            if wins < required {
                failures.append("level \(level.id) won \(wins)/3 (best \(bestStars)★)")
            }
        }
        XCTAssertTrue(failures.isEmpty, failures.joined(separator: "\n"))
    }
}

final class RewardsTests: XCTestCase {
    func testChainFlowerRule() {
        XCTAssertEqual(Rewards.flowers(forChain: 2, kinds: [.daisy, .daisy]), [:])
        XCTAssertEqual(Rewards.flowers(forChain: 3, kinds: [.daisy, .rose, .tulip]), [.rose: 1])
        XCTAssertEqual(Rewards.flowers(forChain: 5, kinds: [.daisy, .daisy, .daisy, .daisy, .daisy]), [.daisy: 2])
        XCTAssertEqual(Rewards.flowers(forChain: 9, kinds: [.sunflower, .tulip, .daisy, .daisy, .daisy, .daisy, .daisy, .daisy, .daisy]), [.sunflower: 1, .tulip: 1, .daisy: 1])
    }

    func testCoinsRewardStarsAndBlooms() {
        var stats = LevelStats()
        stats.bloomed = 10
        stats.longestChain = 4
        XCTAssertEqual(Rewards.coins(stats: stats, stars: 3, won: true), 20 + 45 + 20 + 16)
        XCTAssertEqual(Rewards.coins(stats: stats, stars: 0, won: false), 5)
    }

    func testStatsCollectFlowersFromChains() {
        var board = Board()
        board[Cell(2, 2)].plant = Plant(kind: .daisy, stage: .bud(turnsLeft: 1))
        board[Cell(2, 3)].plant = Plant(kind: .tulip, stage: .bud(turnsLeft: 2))
        board[Cell(2, 4)].plant = Plant(kind: .sunflower, stage: .bud(turnsLeft: 3))
        let report = Relay.resolveTurn(board: board, weather: .mild)
        var stats = LevelStats()
        stats.record(report)
        XCTAssertEqual(stats.longestChain, 3)
        XCTAssertEqual(stats.flowersEarned, [.sunflower: 1])
        XCTAssertEqual(stats.bloomedByKind[.tulip], 1)
    }
}

final class DailyTests: XCTestCase {
    func testSameDaySameLevel() {
        XCTAssertEqual(DailyBloom.level(for: 250), DailyBloom.level(for: 250))
        XCTAssertNotEqual(DailyBloom.level(for: 250).kinds + DailyBloom.level(for: 250).blocked.map { _ in .daisy },
                          DailyBloom.level(for: 251).kinds + DailyBloom.level(for: 251).blocked.map { _ in .daisy })
    }

    func testDailyLevelsAreWellFormed() {
        for day in 1...120 {
            let level = DailyBloom.level(for: day)
            XCTAssertEqual(level.kinds.count, 4)
            XCTAssertTrue(level.kinds.contains { $0.growTurns == 1 }, "day \(day) has no quick flower")
            XCTAssertGreaterThanOrEqual(level.initialBoard().emptyCount, 18)
        }
    }

    func testDayNumberStartsAtOne() {
        XCTAssertEqual(DailyBloom.dayNumber(for: DailyBloom.epoch), 1)
        XCTAssertEqual(DailyBloom.dayNumber(for: DailyBloom.epoch.addingTimeInterval(86_400 * 10)), 11)
    }
}

final class MetaTests: XCTestCase {
    func testGardenPlacementUsesInventory() {
        var garden = GardenState()
        XCTAssertFalse(garden.place(.communityBench, at: GardenCell(0, 0)))
        garden.inventory[.communityBench] = 1
        XCTAssertTrue(garden.place(.communityBench, at: GardenCell(0, 0)))
        XCTAssertFalse(garden.place(.communityBench, at: GardenCell(0, 1)), "inventory is empty now")
        XCTAssertFalse(garden.plant(.daisy, at: GardenCell(0, 0)), "occupied")
        XCTAssertTrue(GardenGoal.placeToSit.isDone(in: garden))
        garden.pickUp(decorID: garden.decor[0].id)
        XCTAssertEqual(garden.inventory[.communityBench], 1)
        XCTAssertTrue(garden.decor.isEmpty)
    }

    func testLanternGoalNeedsAdjacency() {
        var garden = GardenState()
        garden.inventory = [.communityBench: 1, .lantern: 1]
        garden.place(.communityBench, at: GardenCell(2, 2))
        garden.place(.lantern, at: GardenCell(0, 0))
        XCTAssertFalse(GardenGoal.eveningLight.isDone(in: garden))
        garden.pickUp(decorID: garden.decor.first { $0.decor == .lantern }!.id)
        garden.place(.lantern, at: GardenCell(2, 3))
        XCTAssertTrue(GardenGoal.eveningLight.isDone(in: garden))
    }

    func testOrdersCheckTheBasket() {
        var progress = ProgressState.fresh
        let order = MarketCatalog.order(0)
        XCTAssertFalse(progress.canFulfil(order))
        for (kind, count) in order.needs {
            progress.flowers[kind] = count
        }
        XCTAssertTrue(progress.canFulfil(order))
    }

    func testProgressRoundTripsThroughJSON() throws {
        var progress = ProgressState.fresh
        progress.stars[3] = 2
        progress.flowers[.rose] = 4
        progress.garden.inventory[.pond] = 1
        progress.garden.plant(.lavender, at: GardenCell(1, 1))
        progress.gardenGoalsDone = [.restoreBeds]
        let data = try JSONEncoder().encode(progress)
        let decoded = try JSONDecoder().decode(ProgressState.self, from: data)
        XCTAssertEqual(decoded, progress)
    }

    func testVariantsUnlockWithBlooms() {
        var progress = ProgressState.fresh
        XCTAssertEqual(progress.variantsUnlocked(for: .tulip), 1)
        progress.bloomCounts[.tulip] = 40
        XCTAssertEqual(progress.variantsUnlocked(for: .tulip), 3)
        progress.variants[.tulip] = 5
        XCTAssertEqual(progress.variant(for: .tulip), 2)
    }

    func testNextLevelSkipsCompletedOnes() {
        var progress = ProgressState.fresh
        XCTAssertEqual(progress.nextLevelID, 1)
        progress.stars[1] = 1
        progress.stars[2] = 3
        XCTAssertEqual(progress.nextLevelID, 3)
        XCTAssertTrue(progress.isUnlocked(level: 3))
        XCTAssertFalse(progress.isUnlocked(level: 4))
    }
}
