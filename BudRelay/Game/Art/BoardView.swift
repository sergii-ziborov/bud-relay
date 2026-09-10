import SwiftUI

/// The wooden raised bed with a 5×5 grid of plots and the relay pulses between them.
struct BoardView: View {
    let board: Board
    var variants: [FlowerKind: Int] = [:]
    var highlighted: Set<Cell> = []
    var hinted: Cell? = nil
    var glowing: Set<Cell> = []
    var thirsty: Set<Cell> = []
    var ghost: FlowerKind? = nil
    var pulses: [RelayPulse] = []
    var interactive = true
    var onTap: ((Cell) -> Void)? = nil

    private let frame: CGFloat = 16
    private let gap: CGFloat = 5

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let inner = side - frame * 2
            let cell = (inner - gap * CGFloat(Board.size + 1)) / CGFloat(Board.size)
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                WoodGrain()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Palette.woodDark, lineWidth: 3)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.33, green: 0.22, blue: 0.13), Color(red: 0.26, green: 0.17, blue: 0.10)], startPoint: .top, endPoint: .bottom))
                    .padding(frame)
                Nails(inset: 8)
                VStack(spacing: gap) {
                    ForEach(0..<Board.size, id: \.self) { row in
                        HStack(spacing: gap) {
                            ForEach(0..<Board.size, id: \.self) { col in
                                let position = Cell(row, col)
                                plotButton(position, size: cell)
                            }
                        }
                    }
                }
                .padding(frame + gap)
                pulseLayer(cell: cell)
                    .padding(frame + gap)
            }
            .frame(width: side, height: side)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .shadow(color: .black.opacity(0.3), radius: 8, y: 6)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func plotButton(_ position: Cell, size: CGFloat) -> some View {
        let plot = board[position]
        let content = PlotView(
            plot: plot,
            variant: variants[plot.plant?.kind ?? .daisy, default: 0],
            highlighted: highlighted.contains(position),
            hinted: hinted == position,
            glowing: glowing.contains(position),
            thirsty: thirsty.contains(position),
            ghost: highlighted.contains(position) && plot.isEmpty ? ghost : nil
        )
        .frame(width: size, height: size)
        if interactive, let onTap {
            Button {
                onTap(position)
            } label: {
                content
            }
            .buttonStyle(.plain)
            .disabled(plot.blocked)
            .accessibilityIdentifier("plot-\(position.row)-\(position.col)")
            .accessibilityLabel(accessibilityText(for: plot))
            .accessibilityValue(hinted == position ? "hinted" : "")
        } else {
            content
        }
    }

    private func accessibilityText(for plot: Plot) -> String {
        if plot.blocked { return "Stone" }
        guard let plant = plot.plant else { return "Empty plot" }
        switch plant.stage {
        case let .bud(turnsLeft): return "\(plant.kind.name) bud, \(turnsLeft) to bloom"
        case .bloom: return "\(plant.kind.name) in bloom"
        }
    }

    private func pulseLayer(cell: CGFloat) -> some View {
        Canvas { context, _ in
            func center(_ c: Cell) -> CGPoint {
                CGPoint(
                    x: CGFloat(c.col) * (cell + gap) + cell / 2,
                    y: CGFloat(c.row) * (cell + gap) + cell / 2
                )
            }
            for pulse in pulses {
                var path = Path()
                path.move(to: center(pulse.from))
                path.addLine(to: center(pulse.to))
                context.stroke(path, with: .color(Palette.glow.opacity(0.55)), style: StrokeStyle(lineWidth: cell * 0.22, lineCap: .round))
                context.stroke(path, with: .color(Palette.sun), style: StrokeStyle(lineWidth: cell * 0.08, lineCap: .round))
                let tip = center(pulse.to)
                let dot = CGRect(x: tip.x - cell * 0.09, y: tip.y - cell * 0.09, width: cell * 0.18, height: cell * 0.18)
                context.fill(Path(ellipseIn: dot), with: .color(Palette.glow))
            }
        }
        .allowsHitTesting(false)
        .blendMode(.plusLighter)
    }
}
