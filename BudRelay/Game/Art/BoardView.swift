import SwiftUI

/// A card carried by the in-game gesture. Keeping both its slot and kind makes
/// a stale drag harmless if the hand changes before the drop completes.
struct FlowerDragPayload: Codable, Sendable {
    let cardIndex: Int
    let kind: FlowerKind
}

/// Shared board geometry lets the hand gesture find and magnetise the plot
/// beneath the player's finger without invoking iOS's document drag system.
enum BoardLayout {
    static let frame: CGFloat = 16
    static let gap: CGFloat = 5

    static func cellSize(for side: CGFloat) -> CGFloat {
        let inner = side - frame * 2
        return (inner - gap * CGFloat(Board.size + 1)) / CGFloat(Board.size)
    }

    static func cell(at point: CGPoint, in rect: CGRect) -> Cell? {
        guard !rect.isEmpty else { return nil }
        let side = min(rect.width, rect.height)
        let boardOrigin = CGPoint(x: rect.midX - side / 2, y: rect.midY - side / 2)
        let local = CGPoint(x: point.x - boardOrigin.x, y: point.y - boardOrigin.y)
        guard local.x >= frame, local.y >= frame, local.x <= side - frame, local.y <= side - frame else { return nil }

        let size = cellSize(for: side)
        let step = size + gap
        let firstCenter = frame + gap + size / 2
        let col = Int(((local.x - firstCenter) / step).rounded())
        let row = Int(((local.y - firstCenter) / step).rounded())
        guard (0..<Board.size).contains(row), (0..<Board.size).contains(col) else { return nil }

        // Include the narrow wooden gaps so the target feels magnetic, but do
        // not select a distant plot when the finger is over the outer frame.
        let center = CGPoint(x: firstCenter + CGFloat(col) * step, y: firstCenter + CGFloat(row) * step)
        guard abs(local.x - center.x) <= step * 0.52, abs(local.y - center.y) <= step * 0.52 else { return nil }
        return Cell(row, col)
    }

    static func center(of cell: Cell, in rect: CGRect) -> CGPoint {
        let side = min(rect.width, rect.height)
        let size = cellSize(for: side)
        let step = size + gap
        let firstCenter = frame + gap + size / 2
        return CGPoint(
            x: rect.midX - side / 2 + firstCenter + CGFloat(cell.col) * step,
            y: rect.midY - side / 2 + firstCenter + CGFloat(cell.row) * step
        )
    }
}

/// The wooden raised bed with a 5×5 grid of plots and the relay pulses between them.
struct BoardView: View {
    let board: Board
    var variants: [FlowerKind: Int] = [:]
    var highlighted: Set<Cell> = []
    var hinted: Cell? = nil
    var glowing: Set<Cell> = []
    var thirsty: Set<Cell> = []
    var ghost: FlowerKind? = nil
    var dragTarget: Cell? = nil
    var pulses: [RelayPulse] = []
    var previewBlooms: Set<Cell> = []
    var previewPulses: [RelayPulse] = []
    var interactive = true
    var onTap: ((Cell) -> Void)? = nil

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let cell = BoardLayout.cellSize(for: side)
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                WoodGrain()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Palette.woodDark, lineWidth: 3)
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.33, green: 0.22, blue: 0.13), Color(red: 0.26, green: 0.17, blue: 0.10)], startPoint: .top, endPoint: .bottom))
                    .padding(BoardLayout.frame)
                Nails(inset: 8)
                VStack(spacing: BoardLayout.gap) {
                    ForEach(0..<Board.size, id: \.self) { row in
                        HStack(spacing: BoardLayout.gap) {
                            ForEach(0..<Board.size, id: \.self) { col in
                                let position = Cell(row, col)
                                plotButton(position, size: cell)
                            }
                        }
                    }
                }
                .padding(BoardLayout.frame + BoardLayout.gap)
                pulseLayer(cell: cell)
                    .padding(BoardLayout.frame + BoardLayout.gap)
                forecastLayer(cell: cell)
                    .padding(BoardLayout.frame + BoardLayout.gap)
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
            highlighted: highlighted.contains(position) || dragTarget == position,
            hinted: hinted == position,
            glowing: glowing.contains(position),
            thirsty: thirsty.contains(position),
            ghost: plot.isEmpty && (dragTarget.map { $0 == position } ?? highlighted.contains(position)) ? ghost : nil,
            dropFocused: dragTarget == position
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
                    x: CGFloat(c.col) * (cell + BoardLayout.gap) + cell / 2,
                    y: CGFloat(c.row) * (cell + BoardLayout.gap) + cell / 2
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

    private func forecastLayer(cell: CGFloat) -> some View {
        Canvas { context, _ in
            func center(_ position: Cell) -> CGPoint {
                CGPoint(x: CGFloat(position.col) * (cell + BoardLayout.gap) + cell / 2,
                        y: CGFloat(position.row) * (cell + BoardLayout.gap) + cell / 2)
            }
            for pulse in previewPulses {
                var path = Path()
                path.move(to: center(pulse.from))
                path.addLine(to: center(pulse.to))
                context.stroke(path, with: .color(Palette.leafLight.opacity(0.88)),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [3, 4]))
            }
            for position in previewBlooms {
                let point = center(position)
                let radius = cell * 0.38
                let circle = Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius,
                                                    width: radius * 2, height: radius * 2))
                context.stroke(circle, with: .color(Color.white.opacity(0.95)),
                               style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                context.stroke(circle, with: .color(Palette.leafLight.opacity(0.75)), lineWidth: 4)
            }
        }
        .allowsHitTesting(false)
    }
}
