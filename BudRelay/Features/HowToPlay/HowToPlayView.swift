import SwiftUI

struct HowToPlayView: View {
    @Environment(AppModel.self) private var model
    @State private var page = 0

    private let pageCount = 3

    var body: some View {
        VStack(spacing: 12) {
            ScreenHeader(title: "How to Play", subtitle: "\(page + 1)/\(pageCount)") { model.goHome() }
            TabView(selection: $page) {
                placePage.tag(0)
                relayPage.tag(1)
                gardenPage.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            PrimaryButton(title: page == pageCount - 1 ? "Let's Plant" : "Next", symbol: page == pageCount - 1 ? "leaf.fill" : "arrow.right") {
                if page == pageCount - 1 {
                    model.markTutorialSeen()
                    model.goHome()
                } else {
                    withAnimation { page += 1 }
                }
            }
            .accessibilityIdentifier("howto-next")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .contentColumn()
    }

    private var placePage: some View {
        let board: Board = {
            var board = Board()
            board[Cell(1, 1)].plant = Plant(kind: .tulip, stage: .bud(turnsLeft: 2))
            board[Cell(2, 3)].plant = Plant(kind: .sunflower, stage: .bud(turnsLeft: 3))
            return board
        }()
        return lesson(
            title: "Place a bud",
            board: board,
            highlighted: [Cell(1, 2), Cell(2, 2), Cell(1, 0), Cell(0, 1), Cell(2, 1)],
            ghost: .daisy,
            lines: [
                ("hand.tap.fill", "Tap a card, then tap an empty plot. That is one gardening turn."),
                ("clock.fill", "The number on a bud is the care cycles left until it blooms. Every turn counts down by one."),
                ("leaf.fill", "A daisy blooms the turn it is planted. Roses take five turns and wait for a big relay."),
            ]
        )
    }

    private var relayPage: some View {
        let board: Board = {
            var board = Board()
            board[Cell(2, 2)].plant = Plant(kind: .sunflower, stage: .bloom(stayLeft: 1))
            board[Cell(2, 1)].plant = Plant(kind: .tulip, stage: .bud(turnsLeft: 1))
            board[Cell(2, 3)].plant = Plant(kind: .daisy, stage: .bud(turnsLeft: 1))
            board[Cell(1, 2)].plant = Plant(kind: .rose, stage: .bud(turnsLeft: 2))
            board[Cell(3, 2)].plant = Plant(kind: .lavender, stage: .bud(turnsLeft: 2))
            return board
        }()
        return lesson(
            title: "Blooms help neighbours",
            board: board,
            glowing: [Cell(2, 2)],
            pulses: [Cell(2, 1), Cell(2, 3), Cell(1, 2), Cell(3, 2)].map { RelayPulse(from: Cell(2, 2), to: $0) },
            lines: [
                ("link", "When a flower blooms it hands one care point to each neighbouring bud. Tulips hand two."),
                ("sparkles", "A bud that reaches zero blooms too, and passes the momentum on. That wave is a relay."),
                ("star.fill", "Relays of ×3, ×5, and ×8 earn flowers. Small chain now, or one more turn for a big one?"),
            ]
        )
    }

    private var gardenPage: some View {
        let board: Board = {
            var board = Board()
            board[Cell(1, 1)].plant = Plant(kind: .rose, stage: .bloom(stayLeft: 1))
            board[Cell(1, 2)].plant = Plant(kind: .daisy, stage: .bloom(stayLeft: 1))
            board[Cell(3, 3)].mulched = true
            board[Cell(3, 1)].composted = true
            board[Cell(0, 4)].moisture = .dry
            board[Cell(0, 3)].moisture = .dry
            return board
        }()
        return lesson(
            title: "Harvest and grow",
            board: board,
            lines: [
                ("basket.fill", "A bloom stays one turn, then it is collected and the plot is free again. The bed keeps breathing."),
                ("drop.fill", "On hot days soil dries and dry buds wait. Water it, mulch it, or plant a marigold nearby."),
                ("storefront.fill", "Flowers fill bouquet orders at the market and decorate your own garden. That is why you plant."),
            ]
        )
    }

    private func lesson(title: String, board: Board, highlighted: Set<Cell> = [], ghost: FlowerKind? = nil, glowing: Set<Cell> = [], pulses: [RelayPulse] = [], lines: [(String, String)]) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                SignTitle(text: title, size: 24)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                            .overlay { RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 2) }
                    }
                BoardView(board: board, highlighted: highlighted, glowing: glowing, ghost: ghost, pulses: pulses, interactive: false)
                    .frame(width: 290, height: 290)
                PaperCard(padding: 12) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: line.0)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Palette.moss)
                                    .frame(width: 22)
                                Text(line.1)
                                    .font(Typography.caption)
                                    .foregroundStyle(Palette.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.bottom, 30)
        }
    }
}
