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

final class ExpandedFlowerTests: XCTestCase {
    func testLongRelayEarnsGardenEchoOnlyAtFourOrMoreBlooms() {
        var board = Board()
        for col in 0..<4 {
            board[Cell(2, col)].plant = Plant(kind: .daisy, stage: .bud(turnsLeft: 1))
        }
        let report = Relay.resolveTurn(board: board, weather: .mild)
        var stats = LevelStats()
        stats.record(report)
        XCTAssertEqual(report.chain, 4)
        XCTAssertEqual(stats.gardenEcho, 1)

        var shortBoard = Board()
        for col in 0..<3 {
            shortBoard[Cell(2, col)].plant = Plant(kind: .daisy, stage: .bud(turnsLeft: 1))
        }
        var shortStats = LevelStats()
        shortStats.record(Relay.resolveTurn(board: shortBoard, weather: .mild))
        XCTAssertEqual(shortStats.gardenEcho, 0)
    }

    func testHydrangeaRelaysAcrossADiagonal() {
        var board = Board()
        board[Cell(2, 2)].plant = Plant(kind: .hydrangea, stage: .bud(turnsLeft: 1))
        board[Cell(1, 1)].plant = Plant(kind: .peony, stage: .bud(turnsLeft: 2))

        let report = Relay.resolveTurn(board: board, weather: .mild)

        XCTAssertTrue(report.waves.flatMap(\.pulses).contains(RelayPulse(from: Cell(2, 2), to: Cell(1, 1))))
        XCTAssertEqual(report.chain, 2)
        XCTAssertTrue(report.finalBoard[Cell(1, 1)].plant?.stage.isBloom == true)
    }

    func testPeonyHarvestsTwoFlowers() {
        var board = Board()
        board[Cell(2, 2)].plant = Plant(kind: .peony, stage: .bloom(stayLeft: 1))

        let report = Relay.resolveTurn(board: board, weather: .mild)

        XCTAssertEqual(report.harvested.first?.yield, 2)
    }

    func testEveryFlowerHasACompleteEncyclopediaEntry() {
        XCTAssertEqual(FlowerKind.allCases.count, 12)
        for kind in FlowerKind.allCases {
            XCTAssertFalse(kind.scientificName.isEmpty)
            XCTAssertFalse(kind.familyName.isEmpty)
            XCTAssertFalse(kind.bloomSeason.isEmpty)
            XCTAssertEqual(kind.journalEntries.count, 3)
            XCTAssertEqual(kind.variantNames.count, 4)
        }
    }
}

@MainActor
final class DragPlacementTests: XCTestCase {
    func testBoardGestureMapsEveryPlotCentre() {
        let frame = CGRect(x: 18, y: 210, width: 354, height: 354)
        for cell in Board.allCells {
            let point = BoardLayout.center(of: cell, in: frame)
            XCTAssertEqual(BoardLayout.cell(at: point, in: frame), cell)
        }
    }

    func testBoardGestureRejectsPointsOutsideTheBed() {
        let frame = CGRect(x: 18, y: 210, width: 354, height: 354)
        XCTAssertNil(BoardLayout.cell(at: CGPoint(x: frame.minX - 1, y: frame.midY), in: frame))
        XCTAssertNil(BoardLayout.cell(at: CGPoint(x: frame.midX, y: frame.maxY + 1), in: frame))
    }

    func testDragPayloadPlacesItsCard() {
        let level = LevelCatalog.level(1)!
        let session = PlaySession(level: level, seed: 11, ownedTools: [:], isDaily: false, hapticsEnabled: false)
        let kind = session.hand[1]

        XCTAssertTrue(session.drop(FlowerDragPayload(cardIndex: 1, kind: kind), at: Cell(2, 2)))
        XCTAssertEqual(session.board[Cell(2, 2)].plant?.kind, kind)
        XCTAssertEqual(session.turnsLeft, level.turns - 1)
    }

    func testStaleDragPayloadIsRejected() {
        let level = LevelCatalog.level(1)!
        let session = PlaySession(level: level, seed: 11, ownedTools: [:], isDaily: false, hapticsEnabled: false)
        let wrongKind: FlowerKind = session.hand[0] == .peony ? .daisy : .peony

        XCTAssertFalse(session.drop(FlowerDragPayload(cardIndex: 0, kind: wrongKind), at: Cell(2, 2)))
        XCTAssertTrue(session.board[Cell(2, 2)].isEmpty)
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

    func testHotDayMilestonesAreConsistentlyBeatable() {
        for id in [17, 20, 48] {
            guard let level = LevelCatalog.level(id) else {
                XCTFail("missing level \(id)")
                continue
            }
            let wins = (UInt64(1)...3).filter {
                Bot.play(level: level, seed: $0, ownedTools: [.water: 2]).won
            }.count
            XCTAssertGreaterThanOrEqual(wins, 2, "level \(id) won \(wins)/3")
        }
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

    func testOlderGardenSaveLoadsWithoutProductionTimers() throws {
        let data = Data(#"{"decor":[],"flowers":[],"inventory":{}}"#.utf8)
        let garden = try JSONDecoder().decode(GardenState.self, from: data)

        XCTAssertTrue(garden.itemPlacedAt.isEmpty)
        XCTAssertTrue(garden.itemLastCollectedAt.isEmpty)
        XCTAssertTrue(garden.regionCare.isEmpty)
        XCTAssertTrue(garden.regionLastTendedAt.isEmpty)
        XCTAssertTrue(garden.activityLastCompletedAt.isEmpty)
    }

    func testVariantsUnlockWithBlooms() {
        var progress = ProgressState.fresh
        XCTAssertEqual(progress.variantsUnlocked(for: .tulip), 1)
        progress.bloomCounts[.tulip] = 40
        XCTAssertEqual(progress.variantsUnlocked(for: .tulip), 3)
        progress.variants[.tulip] = 5
        XCTAssertEqual(progress.variant(for: .tulip), 2)
    }

    func testOlderSaveDiscoversNewFlowersFromCompletedLevels() {
        var progress = ProgressState.fresh
        progress.unlockedKinds = LevelCatalog.startingKinds
        for id in 1...54 { progress.stars[id] = 1 }

        progress.reconcileFlowerUnlocks()

        XCTAssertTrue([FlowerKind.poppy, .daffodil, .hydrangea, .iris, .aster, .peony].allSatisfy(progress.unlockedKinds.contains))
    }

    func testGardenCellsAreSplitAcrossFiveEstateRegions() {
        let regions = Set(GardenState.allCells.map(GardenRegion.region(for:)))
        XCTAssertEqual(regions, Set(GardenRegion.allCases))
        XCTAssertEqual(GardenRegion.region(for: GardenCell(6, 0)), .courtyard)
        XCTAssertEqual(GardenRegion.region(for: GardenCell(3, 1)), .meadow)
        XCTAssertEqual(GardenRegion.region(for: GardenCell(4, 4)), .orchard)
        XCTAssertEqual(GardenRegion.region(for: GardenCell(1, 1)), .waterside)
        XCTAssertEqual(GardenRegion.region(for: GardenCell(1, 4)), .greenhouseYard)
    }

    func testGardenRegionsExpandGraduallyWithPlayerLevel() {
        XCTAssertEqual(GardenRegion.courtyard.capacity(at: 1), 4)
        XCTAssertEqual(GardenRegion.courtyard.capacity(at: 3), 5)
        XCTAssertEqual(GardenRegion.meadow.capacity(at: 3), 0)
        XCTAssertEqual(GardenRegion.meadow.capacity(at: 4), 2)
        XCTAssertEqual(GardenRegion.orchard.capacity(at: 7), 0)
        XCTAssertEqual(GardenRegion.orchard.capacity(at: 8), 2)
        XCTAssertEqual(GardenRegion.waterside.capacity(at: 14), 0)
        XCTAssertGreaterThan(GardenRegion.waterside.capacity(at: 15), 0)
    }

    func testGardenPlacementMustMatchAuthoredTerrain() {
        let path = GardenCell(5, 0)
        let flowerBed = GardenCell(6, 2)
        let orchard = GardenCell(3, 4)
        let waterEdge = GardenCell(2, 2)

        XCTAssertTrue(GardenPlacementRules.canPlace(.pathStone, at: path))
        XCTAssertFalse(GardenPlacementRules.canPlace(.pathStone, at: flowerBed))
        XCTAssertTrue(GardenPlacementRules.canPlantFlower(at: flowerBed))
        XCTAssertFalse(GardenPlacementRules.canPlantFlower(at: path))
        XCTAssertTrue(GardenPlacementRules.canPlace(.appleTree, at: orchard))
        XCTAssertFalse(GardenPlacementRules.canPlace(.appleTree, at: waterEdge))
        XCTAssertTrue(GardenPlacementRules.canPlace(.pond, at: waterEdge))
    }

    func testGardenRestorationMovesFromPollutedToThriving() {
        var garden = GardenState()
        XCTAssertEqual(garden.restorationStage(in: .courtyard, playerLevel: 1), .neglected)
        XCTAssertEqual(garden.restorationStage(in: .waterside, playerLevel: 14), .shrouded)

        garden.flowers = GardenRegion.courtyard.cells.prefix(9).map { PlantedFlower(kind: .daisy, cell: $0) }
        XCTAssertEqual(garden.restorationStage(in: .courtyard, playerLevel: 20), .thriving)
    }

    func testGardenObjectsRestoreAreasWhilePlayerIsAway() {
        let placedAt = Date(timeIntervalSince1970: 10_000)
        var garden = GardenState(inventory: [.communityBench: 1])
        XCTAssertTrue(garden.place(.communityBench, at: GardenCell(5, 3), date: placedAt))

        XCTAssertEqual(garden.passiveRestoration(in: .courtyard, at: placedAt), 0)
        XCTAssertEqual(garden.passiveRestoration(in: .courtyard, at: placedAt.addingTimeInterval(12 * 3_600)), 4)
    }

    func testGardenProductionAndRegionTendingHaveCooldowns() {
        let now = Date(timeIntervalSince1970: 20_000)
        let id = UUID()
        var garden = GardenState()
        garden.itemLastCollectedAt[id] = now
        garden.regionLastTendedAt[.courtyard] = now

        XCTAssertFalse(garden.canCollect(from: id, cooldown: 4 * 3_600, at: now.addingTimeInterval(60)))
        XCTAssertTrue(garden.canCollect(from: id, cooldown: 4 * 3_600, at: now.addingTimeInterval(4 * 3_600)))
        XCTAssertFalse(garden.canTend(.courtyard, at: now.addingTimeInterval(20 * 60)))
        XCTAssertTrue(garden.canTend(.courtyard, at: now.addingTimeInterval(60 * 60)))
    }

    func testGardenActivitiesHaveIndependentCooldowns() {
        let now = Date(timeIntervalSince1970: 25_000)
        var garden = GardenState()
        garden.activityLastCompletedAt[.tidyLeaves] = now

        XCTAssertFalse(garden.canComplete(.tidyLeaves, at: now.addingTimeInterval(60)))
        XCTAssertTrue(garden.canComplete(.tidyLeaves, at: now.addingTimeInterval(2 * 3_600)))
        XCTAssertTrue(garden.canComplete(.communityBoard, at: now.addingTimeInterval(60)))
    }

    func testOldGridGardenMigratesWithoutLosingPieces() {
        var progress = ProgressState.fresh
        progress.garden.decor = [
            PlacedDecor(decor: .communityBench, cell: GardenCell(0, 0)),
            PlacedDecor(decor: .pathStone, cell: GardenCell(0, 1)),
        ]
        progress.garden.flowers = [
            PlantedFlower(kind: .daisy, cell: GardenCell(0, 2)),
            PlantedFlower(kind: .tulip, cell: GardenCell(0, 3)),
        ]

        progress.reconcileGardenLayout()

        XCTAssertEqual(progress.garden.decor.count + progress.garden.inventory.values.reduce(0, +), 2)
        XCTAssertEqual(progress.garden.flowers.count + progress.flowers.values.reduce(0, +), 2)
        for item in progress.garden.decor {
            XCTAssertTrue(GardenRegion.region(for: item.cell).isOpen(item.cell, at: progress.playerLevel))
            XCTAssertTrue(GardenPlacementRules.canPlace(item.decor, at: item.cell))
        }
        for flower in progress.garden.flowers {
            XCTAssertTrue(GardenRegion.region(for: flower.cell).isOpen(flower.cell, at: progress.playerLevel))
            XCTAssertTrue(GardenPlacementRules.canPlantFlower(at: flower.cell))
        }
    }

    func testGardenMigrationPreservesRestorationTimersAndCare() {
        let date = Date(timeIntervalSince1970: 30_000)
        let item = PlacedDecor(decor: .communityBench, cell: GardenCell(0, 0))
        var progress = ProgressState.fresh
        progress.garden.decor = [item]
        progress.garden.itemPlacedAt[item.id] = date.addingTimeInterval(-3_600)
        progress.garden.itemLastCollectedAt[item.id] = date
        progress.garden.regionCare[.courtyard] = 3
        progress.garden.activityLastCompletedAt[.tidyLeaves] = date.addingTimeInterval(-900)

        progress.reconcileGardenLayout(at: date)

        XCTAssertNotNil(progress.garden.decor.first { $0.id == item.id })
        XCTAssertEqual(progress.garden.itemPlacedAt[item.id], date.addingTimeInterval(-3_600))
        XCTAssertEqual(progress.garden.itemLastCollectedAt[item.id], date)
        XCTAssertEqual(progress.garden.regionCare[.courtyard], 3)
        XCTAssertEqual(progress.garden.activityLastCompletedAt[.tidyLeaves], date.addingTimeInterval(-900))
    }

    func testTreeCatalogAndOrchardGoal() {
        XCTAssertEqual(TreeKind.allCases.count, 6)
        for tree in TreeKind.allCases {
            XCTAssertFalse(tree.scientificName.isEmpty)
            XCTAssertEqual(tree.journalEntries.count, 3)
            XCTAssertEqual(tree.decor.treeKind, tree)
        }

        var garden = GardenState()
        garden.inventory = [.appleTree: 1, .pearTree: 1, .cherryTree: 1]
        XCTAssertTrue(garden.place(.appleTree, at: GardenCell(3, 3)))
        XCTAssertTrue(garden.place(.pearTree, at: GardenCell(3, 4)))
        XCTAssertTrue(garden.place(.cherryTree, at: GardenCell(4, 5)))
        XCTAssertTrue(GardenGoal.youngOrchard.isDone(in: garden))
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

@MainActor
final class AppModelTests: XCTestCase {
    func testCompletingGardenActivityAwardsAndRestoresOncePerCooldown() {
        let store = ProgressStore(filename: "test-\(UUID().uuidString).json")
        defer { store.wipe() }
        let model = AppModel(store: store)
        let now = Date(timeIntervalSince1970: 35_000)
        model.progress.gardenGoalsDone = GardenGoal.allCases
        let initialCoins = model.progress.coins

        model.collectGardenActivity(.communityBoard, at: now)
        XCTAssertEqual(model.progress.coins, initialCoins + 3)
        XCTAssertEqual(model.progress.garden.regionCare[.courtyard], 1)

        model.collectGardenActivity(.communityBoard, at: now.addingTimeInterval(60))
        XCTAssertEqual(model.progress.coins, initialCoins + 3)
        XCTAssertEqual(model.progress.garden.regionCare[.courtyard], 1)

        model.collectGardenActivity(.communityBoard, at: now.addingTimeInterval(4 * 3_600))
        XCTAssertEqual(model.progress.coins, initialCoins + 6)
        XCTAssertEqual(model.progress.garden.regionCare[.courtyard], 2)
    }

    func testCollectingAProductiveGardenObjectAwardsOncePerCooldown() {
        let store = ProgressStore(filename: "test-\(UUID().uuidString).json")
        defer { store.wipe() }
        let model = AppModel(store: store)
        let now = Date(timeIntervalSince1970: 40_000)
        model.progress.gardenGoalsDone = [.placeToSit]
        model.progress.garden.inventory[.communityBench] = 1
        XCTAssertTrue(model.progress.garden.place(.communityBench, at: GardenCell(5, 3), date: now))
        let item = try! XCTUnwrap(model.progress.garden.decor.first)
        let initialCoins = model.progress.coins

        model.collectGardenDecor(item.id, at: now)
        XCTAssertEqual(model.progress.coins, initialCoins + 4)
        XCTAssertEqual(model.progress.garden.regionCare[.courtyard], 1)

        model.collectGardenDecor(item.id, at: now.addingTimeInterval(60))
        XCTAssertEqual(model.progress.coins, initialCoins + 4)

        model.collectGardenDecor(item.id, at: now.addingTimeInterval(4 * 3_600))
        XCTAssertEqual(model.progress.coins, initialCoins + 8)
    }

    func testResetReallyReturnsToFirstLaunch() {
        let store = ProgressStore(filename: "test-\(UUID().uuidString).json")
        defer { store.wipe() }
        let model = AppModel(store: store)
        model.progress.coins = 999
        model.progress.tutorialSeen = true
        model.progress.seenScenes = [StoryCatalog.welcome.id]

        model.resetProgress()

        XCTAssertEqual(model.progress.coins, ProgressState.fresh.coins)
        XCTAssertTrue(model.progress.stars.isEmpty)
        XCTAssertFalse(model.progress.tutorialSeen)
        XCTAssertEqual(model.progress.seenScenes, [StoryCatalog.welcome.id])
        XCTAssertEqual(model.screen, .home)
        XCTAssertEqual(model.currentScene?.id, StoryCatalog.welcome.id)
        model.dismissScene()
        XCTAssertEqual(model.screen, .howToPlay)
    }

    func testInterruptedFirstLaunchStillShowsTutorial() {
        let store = ProgressStore(filename: "test-\(UUID().uuidString).json")
        defer { store.wipe() }
        var progress = ProgressState.fresh
        progress.seenScenes = [StoryCatalog.welcome.id]
        store.save(progress)
        let model = AppModel(store: store)

        model.showWelcomeIfNeeded()

        XCTAssertEqual(model.screen, .howToPlay)
    }
}
