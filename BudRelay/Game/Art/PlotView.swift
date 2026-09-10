import SwiftUI

/// One soil plot in the wooden bed: soil, mulch, compost, the plant, and its timer.
struct PlotView: View {
    let plot: Plot
    var variant: Int = 0
    var highlighted = false
    var hinted = false
    var glowing = false
    var thirsty = false
    var ghost: FlowerKind? = nil

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                if plot.blocked {
                    stone(side: side)
                } else {
                    soil(side: side)
                    if plot.mulched {
                        Circle()
                            .strokeBorder(Color(red: 0.78, green: 0.62, blue: 0.36), style: StrokeStyle(lineWidth: side * 0.06, dash: [side * 0.08, side * 0.05]))
                            .padding(side * 0.06)
                    }
                    if plot.composted {
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(Color(red: 0.30, green: 0.20, blue: 0.10))
                                .frame(width: side * 0.07, height: side * 0.07)
                                .offset(x: cos(CGFloat(index) * 1.26) * side * 0.22, y: sin(CGFloat(index) * 1.26) * side * 0.18 + side * 0.05)
                        }
                    }
                    if glowing {
                        Circle()
                            .fill(RadialGradient(colors: [Palette.glow.opacity(0.95), Palette.glow.opacity(0)], center: .center, startRadius: 0, endRadius: side * 0.62))
                            .scaleEffect(1.35)
                    }
                    if let plant = plot.plant {
                        FlowerView(kind: plant.kind, stage: plant.stage.isBloom ? .bloom : .bud, variant: variant)
                            .frame(width: side * 0.82, height: side * 0.82)
                            .offset(y: -side * 0.04)
                            .scaleEffect(glowing ? 1.12 : 1)
                            .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                        if plant.fertilized {
                            Image(systemName: "sparkles")
                                .font(.system(size: side * 0.16, weight: .bold))
                                .foregroundStyle(Palette.sun)
                                .offset(x: -side * 0.3, y: -side * 0.3)
                        }
                    } else if let ghost {
                        FlowerView(kind: ghost, stage: .bud, variant: variant)
                            .frame(width: side * 0.7, height: side * 0.7)
                            .opacity(0.35)
                    }
                    if thirsty {
                        Image(systemName: "drop.fill")
                            .font(.system(size: side * 0.16, weight: .bold))
                            .foregroundStyle(Palette.water)
                            .offset(x: side * 0.3, y: -side * 0.3)
                    }
                }
            }
            .frame(width: side, height: side)
            .overlay {
                if highlighted {
                    Circle()
                        .strokeBorder(Palette.leafLight, style: StrokeStyle(lineWidth: side * 0.05, dash: [side * 0.12, side * 0.08]))
                        .padding(side * 0.03)
                }
                if hinted {
                    Circle()
                        .strokeBorder(Palette.sun, lineWidth: side * 0.06)
                        .padding(side * 0.02)
                        .shadow(color: Palette.sun, radius: 4)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let turns = plot.plant?.stage.turnsLeft {
                    TimerBadge(value: turns, size: side * 0.32)
                        .offset(x: side * 0.03, y: side * 0.03)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func soil(side: CGFloat) -> some View {
        let base: Color
        switch plot.moisture {
        case .dry: base = Palette.soilDry
        case .normal: base = Palette.soil
        case .wet: base = Palette.soilWet
        }
        return Circle()
            .fill(RadialGradient(colors: [base.opacity(0.85), base], center: .top, startRadius: 0, endRadius: side * 0.6))
            .overlay {
                Circle().strokeBorder(Palette.woodDark.opacity(0.7), lineWidth: side * 0.035)
            }
            .overlay {
                if plot.moisture == .dry {
                    Canvas { context, size in
                        var crack = Path()
                        crack.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.35))
                        crack.addLine(to: CGPoint(x: size.width * 0.5, y: size.height * 0.55))
                        crack.addLine(to: CGPoint(x: size.width * 0.45, y: size.height * 0.75))
                        crack.move(to: CGPoint(x: size.width * 0.5, y: size.height * 0.55))
                        crack.addLine(to: CGPoint(x: size.width * 0.72, y: size.height * 0.5))
                        context.stroke(crack, with: .color(Palette.woodDark.opacity(0.5)), lineWidth: size.width * 0.03)
                    }
                    .clipShape(Circle())
                }
            }
            .shadow(color: .black.opacity(0.35), radius: side * 0.03, y: side * 0.02)
    }

    private func stone(side: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: side * 0.3, style: .continuous)
            .fill(LinearGradient(colors: [Palette.stone.opacity(0.9), Palette.stone.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                RoundedRectangle(cornerRadius: side * 0.3, style: .continuous)
                    .strokeBorder(Palette.woodDark.opacity(0.5), lineWidth: side * 0.03)
            }
            .padding(side * 0.08)
    }
}
