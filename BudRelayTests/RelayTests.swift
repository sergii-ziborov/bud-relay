import XCTest
@testable import BudRelay

final class RelayTests: XCTestCase {
    private func bud(_ kind: FlowerKind, _ turns: Int) -> Plant {
        Plant(kind: kind, stage: .bud(turnsLeft: turns))
    }

    func testDaisyBloomsAloneAfterOneTurn() {
        var board = Board()
        board[Cell(2, 2)].plant = bud(.daisy, 1)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.chain, 1)
        XCTAssertEqual(report.waves.count, 1)
        XCTAssertEqual(report.finalBoard[Cell(2, 2)].plant?.stage, .bloom(stayLeft: 1))
    }

    func testRelayChainOfFourRunsInWaves() {
        var board = Board()
        board[Cell(2, 2)].plant = bud(.daisy, 1)
        board[Cell(2, 3)].plant = bud(.tulip, 2)
        board[Cell(2, 4)].plant = bud(.sunflower, 3)
        board[Cell(1, 4)].plant = bud(.rose, 2)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.chain, 4)
        XCTAssertEqual(report.waves.map(\.bloomed), [[Cell(2, 2)], [Cell(2, 3)], [Cell(2, 4)], [Cell(1, 4)]])
        XCTAssertEqual(report.bloomedKinds, [.daisy, .tulip, .sunflower, .rose])
        XCTAssertTrue(report.waves[0].pulses.contains(RelayPulse(from: Cell(2, 2), to: Cell(2, 3))))
    }

    func testTulipHandsTwoCarePoints() {
        var board = Board()
        board[Cell(0, 0)].plant = bud(.tulip, 1)
        board[Cell(0, 1)].plant = bud(.sunflower, 3)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        // Sunflower ticks to 2, tulip relays 2, sunflower blooms.
        XCTAssertEqual(report.chain, 2)
    }

    func testRelayPointsAccumulateWithoutBloomingEarly() {
        var board = Board()
        board[Cell(0, 0)].plant = bud(.daisy, 1)
        board[Cell(0, 1)].plant = bud(.rose, 3)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.chain, 1)
        XCTAssertEqual(report.finalBoard[Cell(0, 1)].plant?.stage, .bud(turnsLeft: 1))
    }

    func testBloomIsHarvestedOnTheNextTurn() {
        var board = Board()
        board[Cell(1, 1)].plant = Plant(kind: .daisy, stage: .bloom(stayLeft: 1), fertilized: true)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.harvested, [Harvest(cell: Cell(1, 1), kind: .daisy, yield: 2)])
        XCTAssertNil(report.finalBoard[Cell(1, 1)].plant)
    }

    func testMarigoldStaysTwoTurns() {
        var board = Board()
        board[Cell(1, 1)].plant = bud(.marigold, 1)
        let first = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(first.finalBoard[Cell(1, 1)].plant?.stage, .bloom(stayLeft: 2))
        let second = Relay.resolveTurn(board: first.finalBoard, weather: .mild)
        XCTAssertEqual(second.finalBoard[Cell(1, 1)].plant?.stage, .bloom(stayLeft: 1))
        XCTAssertTrue(second.harvested.isEmpty)
        let third = Relay.resolveTurn(board: second.finalBoard, weather: .mild)
        XCTAssertEqual(third.harvested.count, 1)
    }

    func testDryBudWaitsButStillReceivesRelay() {
        var board = Board()
        board[Cell(0, 0)].plant = bud(.daisy, 1)
        board[Cell(0, 1)].plant = bud(.daisy, 1)
        board[Cell(0, 1)].moisture = .dry
        board[Cell(3, 3)].plant = bud(.tulip, 2)
        board[Cell(3, 3)].moisture = .dry
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.thirsty, [Cell(0, 1), Cell(3, 3)])
        XCTAssertEqual(report.chain, 2, "the dry daisy blooms from its neighbour's care")
        XCTAssertEqual(report.finalBoard[Cell(3, 3)].plant?.stage, .bud(turnsLeft: 2))
    }

    func testHotDayDriesSoilExceptMulchAndMarigoldShade() {
        var board = Board()
        board[Cell(0, 0)].mulched = true
        board[Cell(2, 2)].plant = Plant(kind: .marigold, stage: .bloom(stayLeft: 2))
        let report = Relay.resolveTurn(board: board, weather: .hotDay)
        XCTAssertEqual(report.finalBoard[Cell(0, 0)].moisture, .normal)
        XCTAssertEqual(report.finalBoard[Cell(4, 4)].moisture, .dry)
        XCTAssertEqual(report.finalBoard[Cell(2, 3)].moisture, .normal)
        XCTAssertEqual(report.finalBoard[Cell(2, 2)].moisture, .normal)
    }

    func testRainSoaksEveryPlot() {
        var board = Board()
        board.setMoisture(.dry, at: Board.allCells)
        let report = Relay.resolveTurn(board: board, weather: .rain)
        XCTAssertTrue(Board.allCells.allSatisfy { report.finalBoard[$0].moisture == .wet })
    }

    func testLavenderWithDaisyBringsSeeds() {
        var board = Board()
        board[Cell(1, 1)].plant = bud(.lavender, 1)
        board[Cell(1, 2)].plant = bud(.daisy, 2)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.chain, 2)
        XCTAssertEqual(report.pollinatorSeeds, [.daisy])
    }

    func testLavenderWithTulipBringsNoSeeds() {
        var board = Board()
        board[Cell(1, 1)].plant = bud(.lavender, 1)
        board[Cell(1, 2)].plant = bud(.tulip, 2)
        let report = Relay.resolveTurn(board: board, weather: .mild)
        XCTAssertEqual(report.chain, 2)
        XCTAssertTrue(report.pollinatorSeeds.isEmpty)
    }

    func testCompostGivesHeadStart() {
        var board = Board()
        board[Cell(0, 0)].composted = true
        board.plant(.sunflower, at: Cell(0, 0))
        XCTAssertEqual(board[Cell(0, 0)].plant?.stage, .bud(turnsLeft: 3))
        XCTAssertFalse(board[Cell(0, 0)].composted)
        board.plant(.daisy, at: Cell(0, 1))
        XCTAssertEqual(board[Cell(0, 1)].plant?.stage, .bud(turnsLeft: 1))
    }
}
