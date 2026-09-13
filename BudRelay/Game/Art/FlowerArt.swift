import SwiftUI

struct FlowerColors: Hashable {
    let petal: Color
    let petalDark: Color
    let petalLight: Color
    let center: Color
}

enum FlowerArt {
    static let stem = Color(red: 0.36, green: 0.60, blue: 0.27)
    static let stemDark = Color(red: 0.24, green: 0.44, blue: 0.19)
    static let leaf = Color(red: 0.46, green: 0.72, blue: 0.33)

    static func colors(_ kind: FlowerKind, variant: Int) -> FlowerColors {
        let table: [FlowerColors]
        switch kind {
        case .daisy:
            table = [
                FlowerColors(petal: Color(red: 1.0, green: 0.98, blue: 0.93), petalDark: Color(red: 0.86, green: 0.82, blue: 0.72), petalLight: .white, center: Color(red: 0.96, green: 0.76, blue: 0.22)),
                FlowerColors(petal: Color(red: 0.98, green: 0.72, blue: 0.80), petalDark: Color(red: 0.85, green: 0.52, blue: 0.64), petalLight: Color(red: 1.0, green: 0.86, blue: 0.90), center: Color(red: 0.96, green: 0.76, blue: 0.22)),
                FlowerColors(petal: Color(red: 0.99, green: 0.84, blue: 0.40), petalDark: Color(red: 0.86, green: 0.66, blue: 0.20), petalLight: Color(red: 1.0, green: 0.93, blue: 0.62), center: Color(red: 0.55, green: 0.35, blue: 0.14)),
                FlowerColors(petal: Color(red: 0.80, green: 0.74, blue: 0.94), petalDark: Color(red: 0.60, green: 0.52, blue: 0.80), petalLight: Color(red: 0.92, green: 0.89, blue: 1.0), center: Color(red: 0.96, green: 0.76, blue: 0.22)),
            ]
        case .tulip:
            table = [
                FlowerColors(petal: Color(red: 0.90, green: 0.26, blue: 0.36), petalDark: Color(red: 0.70, green: 0.14, blue: 0.24), petalLight: Color(red: 0.98, green: 0.50, blue: 0.56), center: Color(red: 0.60, green: 0.10, blue: 0.18)),
                FlowerColors(petal: Color(red: 0.98, green: 0.82, blue: 0.24), petalDark: Color(red: 0.86, green: 0.62, blue: 0.10), petalLight: Color(red: 1.0, green: 0.92, blue: 0.55), center: Color(red: 0.75, green: 0.52, blue: 0.08)),
                FlowerColors(petal: Color(red: 0.99, green: 0.97, blue: 0.92), petalDark: Color(red: 0.82, green: 0.78, blue: 0.70), petalLight: .white, center: Color(red: 0.70, green: 0.66, blue: 0.56)),
                FlowerColors(petal: Color(red: 0.56, green: 0.30, blue: 0.72), petalDark: Color(red: 0.38, green: 0.18, blue: 0.52), petalLight: Color(red: 0.74, green: 0.52, blue: 0.88), center: Color(red: 0.30, green: 0.12, blue: 0.42)),
            ]
        case .sunflower:
            table = [
                FlowerColors(petal: Color(red: 0.98, green: 0.74, blue: 0.16), petalDark: Color(red: 0.84, green: 0.56, blue: 0.08), petalLight: Color(red: 1.0, green: 0.86, blue: 0.40), center: Color(red: 0.36, green: 0.22, blue: 0.10)),
                FlowerColors(petal: Color(red: 0.98, green: 0.90, blue: 0.36), petalDark: Color(red: 0.84, green: 0.74, blue: 0.16), petalLight: Color(red: 1.0, green: 0.96, blue: 0.62), center: Color(red: 0.36, green: 0.22, blue: 0.10)),
                FlowerColors(petal: Color(red: 0.86, green: 0.46, blue: 0.14), petalDark: Color(red: 0.66, green: 0.30, blue: 0.08), petalLight: Color(red: 0.96, green: 0.64, blue: 0.30), center: Color(red: 0.30, green: 0.16, blue: 0.08)),
                FlowerColors(petal: Color(red: 0.99, green: 0.94, blue: 0.80), petalDark: Color(red: 0.86, green: 0.78, blue: 0.58), petalLight: .white, center: Color(red: 0.42, green: 0.28, blue: 0.14)),
            ]
        case .lavender:
            table = [
                FlowerColors(petal: Color(red: 0.60, green: 0.46, blue: 0.84), petalDark: Color(red: 0.42, green: 0.30, blue: 0.66), petalLight: Color(red: 0.78, green: 0.66, blue: 0.94), center: Color(red: 0.42, green: 0.30, blue: 0.66)),
                FlowerColors(petal: Color(red: 0.50, green: 0.30, blue: 0.72), petalDark: Color(red: 0.34, green: 0.18, blue: 0.54), petalLight: Color(red: 0.70, green: 0.50, blue: 0.88), center: Color(red: 0.34, green: 0.18, blue: 0.54)),
                FlowerColors(petal: Color(red: 0.42, green: 0.52, blue: 0.86), petalDark: Color(red: 0.28, green: 0.36, blue: 0.68), petalLight: Color(red: 0.64, green: 0.72, blue: 0.95), center: Color(red: 0.28, green: 0.36, blue: 0.68)),
                FlowerColors(petal: Color(red: 0.94, green: 0.92, blue: 0.98), petalDark: Color(red: 0.74, green: 0.72, blue: 0.82), petalLight: .white, center: Color(red: 0.74, green: 0.72, blue: 0.82)),
            ]
        case .rose:
            table = [
                FlowerColors(petal: Color(red: 0.95, green: 0.42, blue: 0.62), petalDark: Color(red: 0.80, green: 0.22, blue: 0.44), petalLight: Color(red: 0.99, green: 0.66, blue: 0.78), center: Color(red: 0.66, green: 0.14, blue: 0.34)),
                FlowerColors(petal: Color(red: 0.98, green: 0.66, blue: 0.50), petalDark: Color(red: 0.86, green: 0.46, blue: 0.30), petalLight: Color(red: 1.0, green: 0.82, blue: 0.70), center: Color(red: 0.72, green: 0.36, blue: 0.22)),
                FlowerColors(petal: Color(red: 0.78, green: 0.12, blue: 0.24), petalDark: Color(red: 0.56, green: 0.06, blue: 0.16), petalLight: Color(red: 0.92, green: 0.32, blue: 0.42), center: Color(red: 0.42, green: 0.04, blue: 0.12)),
                FlowerColors(petal: Color(red: 0.99, green: 0.96, blue: 0.88), petalDark: Color(red: 0.84, green: 0.78, blue: 0.66), petalLight: .white, center: Color(red: 0.74, green: 0.66, blue: 0.50)),
            ]
        case .marigold:
            table = [
                FlowerColors(petal: Color(red: 0.96, green: 0.56, blue: 0.14), petalDark: Color(red: 0.82, green: 0.36, blue: 0.06), petalLight: Color(red: 1.0, green: 0.76, blue: 0.30), center: Color(red: 0.56, green: 0.24, blue: 0.06)),
                FlowerColors(petal: Color(red: 0.98, green: 0.86, blue: 0.24), petalDark: Color(red: 0.86, green: 0.66, blue: 0.10), petalLight: Color(red: 1.0, green: 0.94, blue: 0.56), center: Color(red: 0.62, green: 0.40, blue: 0.06)),
                FlowerColors(petal: Color(red: 0.84, green: 0.26, blue: 0.16), petalDark: Color(red: 0.64, green: 0.14, blue: 0.08), petalLight: Color(red: 0.96, green: 0.48, blue: 0.32), center: Color(red: 0.44, green: 0.10, blue: 0.06)),
                FlowerColors(petal: Color(red: 0.99, green: 0.93, blue: 0.76), petalDark: Color(red: 0.88, green: 0.78, blue: 0.54), petalLight: .white, center: Color(red: 0.62, green: 0.46, blue: 0.20)),
            ]
        case .daffodil:
            table = [
                FlowerColors(petal: Color(red: 1.0, green: 0.86, blue: 0.22), petalDark: Color(red: 0.88, green: 0.66, blue: 0.08), petalLight: Color(red: 1.0, green: 0.95, blue: 0.54), center: Color(red: 0.96, green: 0.56, blue: 0.08)),
                FlowerColors(petal: Color(red: 1.0, green: 0.96, blue: 0.78), petalDark: Color(red: 0.88, green: 0.80, blue: 0.56), petalLight: .white, center: Color(red: 0.98, green: 0.76, blue: 0.14)),
                FlowerColors(petal: Color(red: 1.0, green: 0.92, blue: 0.72), petalDark: Color(red: 0.92, green: 0.70, blue: 0.46), petalLight: .white, center: Color(red: 0.98, green: 0.52, blue: 0.30)),
                FlowerColors(petal: Color(red: 0.99, green: 0.99, blue: 0.95), petalDark: Color(red: 0.82, green: 0.84, blue: 0.76), petalLight: .white, center: Color(red: 0.94, green: 0.82, blue: 0.34)),
            ]
        case .hydrangea:
            table = [
                FlowerColors(petal: Color(red: 0.48, green: 0.68, blue: 0.94), petalDark: Color(red: 0.30, green: 0.48, blue: 0.78), petalLight: Color(red: 0.70, green: 0.82, blue: 1.0), center: Color(red: 0.94, green: 0.82, blue: 0.30)),
                FlowerColors(petal: Color(red: 0.94, green: 0.58, blue: 0.76), petalDark: Color(red: 0.76, green: 0.38, blue: 0.60), petalLight: Color(red: 1.0, green: 0.78, blue: 0.88), center: Color(red: 0.94, green: 0.80, blue: 0.30)),
                FlowerColors(petal: Color(red: 0.66, green: 0.50, blue: 0.88), petalDark: Color(red: 0.46, green: 0.30, blue: 0.68), petalLight: Color(red: 0.82, green: 0.72, blue: 0.98), center: Color(red: 0.92, green: 0.78, blue: 0.30)),
                FlowerColors(petal: Color(red: 0.96, green: 0.98, blue: 0.94), petalDark: Color(red: 0.76, green: 0.82, blue: 0.72), petalLight: .white, center: Color(red: 0.82, green: 0.74, blue: 0.30)),
            ]
        case .aster:
            table = [
                FlowerColors(petal: Color(red: 0.54, green: 0.40, blue: 0.84), petalDark: Color(red: 0.36, green: 0.24, blue: 0.66), petalLight: Color(red: 0.74, green: 0.64, blue: 0.96), center: Color(red: 0.96, green: 0.74, blue: 0.16)),
                FlowerColors(petal: Color(red: 0.94, green: 0.52, blue: 0.72), petalDark: Color(red: 0.74, green: 0.32, blue: 0.54), petalLight: Color(red: 1.0, green: 0.72, blue: 0.84), center: Color(red: 0.96, green: 0.72, blue: 0.14)),
                FlowerColors(petal: Color(red: 0.40, green: 0.56, blue: 0.90), petalDark: Color(red: 0.24, green: 0.38, blue: 0.72), petalLight: Color(red: 0.64, green: 0.74, blue: 0.98), center: Color(red: 0.96, green: 0.76, blue: 0.18)),
                FlowerColors(petal: Color(red: 0.98, green: 0.97, blue: 0.94), petalDark: Color(red: 0.78, green: 0.78, blue: 0.72), petalLight: .white, center: Color(red: 0.96, green: 0.74, blue: 0.16)),
            ]
        case .peony:
            table = [
                FlowerColors(petal: Color(red: 0.97, green: 0.62, blue: 0.76), petalDark: Color(red: 0.78, green: 0.36, blue: 0.56), petalLight: Color(red: 1.0, green: 0.82, blue: 0.88), center: Color(red: 0.72, green: 0.24, blue: 0.44)),
                FlowerColors(petal: Color(red: 0.98, green: 0.58, blue: 0.48), petalDark: Color(red: 0.80, green: 0.36, blue: 0.28), petalLight: Color(red: 1.0, green: 0.78, blue: 0.68), center: Color(red: 0.68, green: 0.24, blue: 0.20)),
                FlowerColors(petal: Color(red: 0.76, green: 0.16, blue: 0.32), petalDark: Color(red: 0.54, green: 0.08, blue: 0.20), petalLight: Color(red: 0.92, green: 0.38, blue: 0.50), center: Color(red: 0.46, green: 0.06, blue: 0.16)),
                FlowerColors(petal: Color(red: 1.0, green: 0.96, blue: 0.88), petalDark: Color(red: 0.86, green: 0.76, blue: 0.66), petalLight: .white, center: Color(red: 0.74, green: 0.58, blue: 0.42)),
            ]
        case .poppy:
            table = [
                FlowerColors(petal: Color(red: 0.91, green: 0.20, blue: 0.20), petalDark: Color(red: 0.66, green: 0.06, blue: 0.09), petalLight: Color(red: 0.98, green: 0.40, blue: 0.35), center: Color(red: 0.16, green: 0.12, blue: 0.10)),
                FlowerColors(petal: Color(red: 0.98, green: 0.55, blue: 0.48), petalDark: Color(red: 0.82, green: 0.28, blue: 0.28), petalLight: Color(red: 1.0, green: 0.74, blue: 0.67), center: Color(red: 0.25, green: 0.16, blue: 0.12)),
                FlowerColors(petal: Color(red: 0.98, green: 0.94, blue: 0.82), petalDark: Color(red: 0.82, green: 0.76, blue: 0.62), petalLight: .white, center: Color(red: 0.24, green: 0.18, blue: 0.12)),
                FlowerColors(petal: Color(red: 0.55, green: 0.20, blue: 0.42), petalDark: Color(red: 0.34, green: 0.08, blue: 0.24), petalLight: Color(red: 0.76, green: 0.42, blue: 0.63), center: Color(red: 0.16, green: 0.08, blue: 0.12)),
            ]
        case .iris:
            table = [
                FlowerColors(petal: Color(red: 0.45, green: 0.52, blue: 0.88), petalDark: Color(red: 0.25, green: 0.28, blue: 0.66), petalLight: Color(red: 0.68, green: 0.72, blue: 0.98), center: Color(red: 0.98, green: 0.74, blue: 0.24)),
                FlowerColors(petal: Color(red: 0.93, green: 0.66, blue: 0.22), petalDark: Color(red: 0.70, green: 0.40, blue: 0.08), petalLight: Color(red: 1.0, green: 0.84, blue: 0.45), center: Color(red: 0.50, green: 0.28, blue: 0.06)),
                FlowerColors(petal: Color(red: 0.96, green: 0.96, blue: 0.92), petalDark: Color(red: 0.72, green: 0.74, blue: 0.78), petalLight: .white, center: Color(red: 0.96, green: 0.70, blue: 0.24)),
                FlowerColors(petal: Color(red: 0.58, green: 0.30, blue: 0.78), petalDark: Color(red: 0.36, green: 0.14, blue: 0.56), petalLight: Color(red: 0.78, green: 0.57, blue: 0.94), center: Color(red: 0.98, green: 0.72, blue: 0.22)),
            ]
        }
        return table[min(max(variant, 0), table.count - 1)]
    }

    // MARK: - Drawing

    static func draw(_ kind: FlowerKind, stage: FlowerView.Stage, colors: FlowerColors, in context: inout GraphicsContext, size: CGSize) {
        let s = min(size.width, size.height)
        let origin = CGPoint(x: (size.width - s) / 2, y: (size.height - s) / 2)
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: origin.x + x * s, y: origin.y + y * s)
        }
        func rect(_ cx: CGFloat, _ cy: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
            CGRect(x: origin.x + (cx - w / 2) * s, y: origin.y + (cy - h / 2) * s, width: w * s, height: h * s)
        }

        switch stage {
        case .bud:
            drawStem(&context, p: p, rect: rect, s: s, top: 0.58, leaves: true)
            drawBud(kind, colors: colors, in: &context, p: p, rect: rect, s: s)
        case .bloom:
            switch kind {
            case .lavender:
                drawLavender(colors: colors, in: &context, p: p, rect: rect, s: s)
            default:
                drawStem(&context, p: p, rect: rect, s: s, top: 0.52, leaves: true)
                switch kind {
                case .daisy: drawDaisy(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .tulip: drawTulip(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .sunflower: drawSunflower(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .rose: drawRose(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .marigold: drawMarigold(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .daffodil: drawDaffodil(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .hydrangea: drawHydrangea(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .aster: drawAster(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .peony: drawPeony(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .poppy: drawPoppy(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .iris: drawIris(colors: colors, in: &context, p: p, rect: rect, s: s)
                case .lavender: break
                }
            }
        }
    }

    private static func drawStem(_ context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat, top: CGFloat, leaves: Bool) {
        var stemPath = Path()
        stemPath.move(to: p(0.5, 0.96))
        stemPath.addQuadCurve(to: p(0.5, top), control: p(0.53, 0.75))
        context.stroke(stemPath, with: .color(stemDark), style: StrokeStyle(lineWidth: 0.07 * s, lineCap: .round))
        context.stroke(stemPath, with: .color(stem), style: StrokeStyle(lineWidth: 0.045 * s, lineCap: .round))
        guard leaves else { return }
        let left = Path(ellipseIn: rect(0.36, 0.80, 0.26, 0.12))
        let right = Path(ellipseIn: rect(0.64, 0.74, 0.26, 0.12))
        context.drawLayer { layer in
            layer.translateBy(x: p(0.36, 0.80).x, y: p(0.36, 0.80).y)
            layer.rotate(by: .degrees(-32))
            layer.translateBy(x: -p(0.36, 0.80).x, y: -p(0.36, 0.80).y)
            layer.fill(left, with: .color(leaf))
        }
        context.drawLayer { layer in
            layer.translateBy(x: p(0.64, 0.74).x, y: p(0.64, 0.74).y)
            layer.rotate(by: .degrees(30))
            layer.translateBy(x: -p(0.64, 0.74).x, y: -p(0.64, 0.74).y)
            layer.fill(right, with: .color(leaf))
        }
    }

    private static func drawBud(_ kind: FlowerKind, colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        let width: CGFloat = kind == .lavender ? 0.26 : 0.34
        let height: CGFloat = kind == .lavender ? 0.46 : 0.42
        let cy: CGFloat = 0.40
        var bud = Path()
        bud.move(to: p(0.5, cy - height / 2))
        bud.addCurve(to: p(0.5, cy + height / 2), control1: p(0.5 + width * 0.95, cy - height * 0.15), control2: p(0.5 + width * 0.75, cy + height * 0.45))
        bud.addCurve(to: p(0.5, cy - height / 2), control1: p(0.5 - width * 0.75, cy + height * 0.45), control2: p(0.5 - width * 0.95, cy - height * 0.15))
        context.fill(bud, with: .linearGradient(
            Gradient(colors: [colors.petalLight, colors.petal, colors.petalDark]),
            startPoint: p(0.35, cy - height / 2), endPoint: p(0.6, cy + height / 2)
        ))
        var seam = Path()
        seam.move(to: p(0.5, cy - height * 0.42))
        seam.addQuadCurve(to: p(0.5, cy + height * 0.4), control: p(0.56, cy))
        context.stroke(seam, with: .color(colors.petalDark.opacity(0.7)), style: StrokeStyle(lineWidth: 0.02 * s, lineCap: .round))
        // Sepals hug the base.
        for offset in [-0.12, 0.0, 0.12] as [CGFloat] {
            var sepal = Path()
            sepal.move(to: p(0.5 + offset * 0.6, cy + height * 0.05))
            sepal.addQuadCurve(to: p(0.5, cy + height * 0.5), control: p(0.5 + offset * 1.6, cy + height * 0.42))
            sepal.addQuadCurve(to: p(0.5 + offset * 0.6, cy + height * 0.05), control: p(0.5 + offset * 0.2, cy + height * 0.3))
            context.fill(sepal, with: .color(leaf))
        }
    }

    private static func petals(count: Int, cx: CGFloat, cy: CGFloat, radius: CGFloat, width: CGFloat, height: CGFloat, color: Color, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, s: CGFloat, phase: CGFloat = 0) {
        let center = p(cx, cy)
        for index in 0..<count {
            let angle = (CGFloat(index) / CGFloat(count)) * 2 * .pi + phase
            context.drawLayer { layer in
                layer.translateBy(x: center.x, y: center.y)
                layer.rotate(by: .radians(angle))
                let petal = Path(ellipseIn: CGRect(x: -width * s / 2, y: -(radius + height / 2) * s, width: width * s, height: height * s))
                layer.fill(petal, with: .color(color))
            }
        }
    }

    private static func drawDaisy(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        petals(count: 12, cx: 0.5, cy: 0.40, radius: 0.14, width: 0.13, height: 0.30, color: colors.petalDark.opacity(0.5), in: &context, p: p, s: s, phase: 0.13)
        petals(count: 12, cx: 0.5, cy: 0.40, radius: 0.13, width: 0.13, height: 0.30, color: colors.petal, in: &context, p: p, s: s)
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.24, 0.24)), with: .radialGradient(
            Gradient(colors: [colors.center, colors.center.opacity(0.75)]), center: p(0.48, 0.38), startRadius: 0, endRadius: 0.13 * s
        ))
    }

    private static func drawTulip(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        var cup = Path()
        cup.move(to: p(0.30, 0.22))
        cup.addQuadCurve(to: p(0.42, 0.32), control: p(0.36, 0.34))
        cup.addQuadCurve(to: p(0.50, 0.18), control: p(0.46, 0.26))
        cup.addQuadCurve(to: p(0.58, 0.32), control: p(0.54, 0.26))
        cup.addQuadCurve(to: p(0.70, 0.22), control: p(0.64, 0.34))
        cup.addCurve(to: p(0.5, 0.62), control1: p(0.74, 0.44), control2: p(0.66, 0.62))
        cup.addCurve(to: p(0.30, 0.22), control1: p(0.34, 0.62), control2: p(0.26, 0.44))
        context.fill(cup, with: .linearGradient(
            Gradient(colors: [colors.petalLight, colors.petal, colors.petalDark]),
            startPoint: p(0.3, 0.2), endPoint: p(0.7, 0.62)
        ))
        var inner = Path()
        inner.move(to: p(0.42, 0.32))
        inner.addQuadCurve(to: p(0.58, 0.32), control: p(0.5, 0.24))
        inner.addCurve(to: p(0.5, 0.60), control1: p(0.60, 0.44), control2: p(0.56, 0.58))
        inner.addCurve(to: p(0.42, 0.32), control1: p(0.44, 0.58), control2: p(0.40, 0.44))
        context.fill(inner, with: .color(colors.petalDark.opacity(0.55)))
    }

    private static func drawSunflower(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        petals(count: 16, cx: 0.5, cy: 0.40, radius: 0.15, width: 0.11, height: 0.30, color: colors.petalDark, in: &context, p: p, s: s, phase: 0.196)
        petals(count: 16, cx: 0.5, cy: 0.40, radius: 0.14, width: 0.11, height: 0.30, color: colors.petal, in: &context, p: p, s: s)
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.32, 0.32)), with: .color(colors.center))
        let center = p(0.5, 0.40)
        for ring in 1...3 {
            let count = ring * 6
            let radius = CGFloat(ring) * 0.045 * s
            for index in 0..<count {
                let angle = CGFloat(index) / CGFloat(count) * 2 * .pi + CGFloat(ring) * 0.4
                let dot = CGRect(x: center.x + cos(angle) * radius - 0.014 * s, y: center.y + sin(angle) * radius - 0.014 * s, width: 0.028 * s, height: 0.028 * s)
                context.fill(Path(ellipseIn: dot), with: .color(.black.opacity(0.28)))
            }
        }
    }

    private static func drawLavender(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        for (index, x) in [0.34, 0.5, 0.66].enumerated() {
            let cx = CGFloat(x)
            let top: CGFloat = index == 1 ? 0.14 : 0.24
            var stemPath = Path()
            stemPath.move(to: p(0.5, 0.96))
            stemPath.addQuadCurve(to: p(cx, top + 0.34), control: p((cx + 0.5) / 2, 0.75))
            context.stroke(stemPath, with: .color(stem), style: StrokeStyle(lineWidth: 0.035 * s, lineCap: .round))
            var y = top
            var row = 0
            while y < top + 0.36 {
                let side: CGFloat = row % 2 == 0 ? -1 : 1
                let bloom = rect(cx + side * 0.045, y, 0.11, 0.075)
                context.fill(Path(ellipseIn: bloom), with: .color(row % 3 == 0 ? colors.petalLight : colors.petal))
                context.fill(Path(ellipseIn: rect(cx - side * 0.02, y + 0.02, 0.08, 0.06)), with: .color(colors.petalDark.opacity(0.8)))
                y += 0.06
                row += 1
            }
        }
        let left = Path(ellipseIn: rect(0.36, 0.84, 0.22, 0.09))
        let right = Path(ellipseIn: rect(0.64, 0.80, 0.22, 0.09))
        context.fill(left, with: .color(leaf))
        context.fill(right, with: .color(leaf))
    }

    private static func drawRose(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        let center = p(0.5, 0.40)
        for index in 0..<8 {
            let angle = CGFloat(index) / 8 * 2 * .pi
            let r = 0.15 * s
            let petal = CGRect(x: center.x + cos(angle) * r - 0.13 * s, y: center.y + sin(angle) * r - 0.13 * s, width: 0.26 * s, height: 0.26 * s)
            context.fill(Path(ellipseIn: petal), with: .color(index % 2 == 0 ? colors.petal : colors.petalDark))
        }
        for index in 0..<5 {
            let angle = CGFloat(index) / 5 * 2 * .pi + 0.6
            let r = 0.085 * s
            let petal = CGRect(x: center.x + cos(angle) * r - 0.10 * s, y: center.y + sin(angle) * r - 0.10 * s, width: 0.20 * s, height: 0.20 * s)
            context.fill(Path(ellipseIn: petal), with: .color(colors.petalLight))
        }
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.16, 0.16)), with: .color(colors.petal))
        var swirl = Path()
        swirl.addArc(center: center, radius: 0.06 * s, startAngle: .degrees(20), endAngle: .degrees(300), clockwise: false)
        context.stroke(swirl, with: .color(colors.center), style: StrokeStyle(lineWidth: 0.025 * s, lineCap: .round))
        var swirl2 = Path()
        swirl2.addArc(center: center, radius: 0.025 * s, startAngle: .degrees(180), endAngle: .degrees(60), clockwise: false)
        context.stroke(swirl2, with: .color(colors.center), style: StrokeStyle(lineWidth: 0.02 * s, lineCap: .round))
    }

    private static func drawMarigold(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        petals(count: 12, cx: 0.5, cy: 0.40, radius: 0.14, width: 0.13, height: 0.20, color: colors.petalDark, in: &context, p: p, s: s)
        petals(count: 10, cx: 0.5, cy: 0.40, radius: 0.08, width: 0.12, height: 0.18, color: colors.petal, in: &context, p: p, s: s, phase: 0.3)
        petals(count: 8, cx: 0.5, cy: 0.40, radius: 0.03, width: 0.10, height: 0.14, color: colors.petalLight, in: &context, p: p, s: s, phase: 0.1)
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.09, 0.09)), with: .color(colors.center))
    }

    private static func drawDaffodil(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        petals(count: 6, cx: 0.5, cy: 0.40, radius: 0.13, width: 0.19, height: 0.34, color: colors.petalDark.opacity(0.55), in: &context, p: p, s: s, phase: 0.12)
        petals(count: 6, cx: 0.5, cy: 0.40, radius: 0.12, width: 0.18, height: 0.32, color: colors.petal, in: &context, p: p, s: s)
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.29, 0.29)), with: .color(colors.center))
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.18, 0.18)), with: .color(colors.petalDark.opacity(0.72)))
    }

    private static func drawHydrangea(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        let florets: [(CGFloat, CGFloat, CGFloat)] = [
            (0.35, 0.31, 0.15), (0.50, 0.26, 0.16), (0.65, 0.31, 0.15),
            (0.29, 0.44, 0.15), (0.43, 0.42, 0.17), (0.58, 0.42, 0.17), (0.72, 0.44, 0.15),
            (0.38, 0.56, 0.16), (0.52, 0.55, 0.17), (0.65, 0.55, 0.15),
        ]
        for (index, floret) in florets.enumerated() {
            let color = index.isMultiple(of: 3) ? colors.petalLight : (index.isMultiple(of: 2) ? colors.petalDark : colors.petal)
            petals(count: 4, cx: floret.0, cy: floret.1, radius: floret.2 * 0.20, width: floret.2 * 0.55, height: floret.2 * 0.70, color: color, in: &context, p: p, s: s, phase: .pi / 4)
            context.fill(Path(ellipseIn: rect(floret.0, floret.1, 0.025, 0.025)), with: .color(colors.center))
        }
    }

    private static func drawAster(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        petals(count: 22, cx: 0.5, cy: 0.40, radius: 0.16, width: 0.065, height: 0.33, color: colors.petalDark, in: &context, p: p, s: s, phase: 0.08)
        petals(count: 22, cx: 0.5, cy: 0.40, radius: 0.13, width: 0.06, height: 0.29, color: colors.petal, in: &context, p: p, s: s)
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.22, 0.22)), with: .radialGradient(
            Gradient(colors: [colors.center, colors.center.opacity(0.72)]), center: p(0.47, 0.37), startRadius: 0, endRadius: 0.12 * s
        ))
    }

    private static func drawPeony(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        let center = p(0.5, 0.40)
        for ring in 0..<3 {
            let count = 10 - ring * 2
            let radius = CGFloat(3 - ring) * 0.055 * s
            let diameter = CGFloat(3 - ring) * 0.075 * s + 0.14 * s
            for index in 0..<count {
                let angle = CGFloat(index) / CGFloat(count) * 2 * .pi + CGFloat(ring) * 0.35
                let petal = CGRect(x: center.x + cos(angle) * radius - diameter / 2, y: center.y + sin(angle) * radius - diameter / 2, width: diameter, height: diameter)
                let color = ring == 0 ? colors.petalDark : (ring == 1 ? colors.petal : colors.petalLight)
                context.fill(Path(ellipseIn: petal), with: .color(color))
            }
        }
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.12, 0.12)), with: .color(colors.petal))
    }

    private static func drawPoppy(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        let center = p(0.5, 0.40)
        for index in 0..<4 {
            let angle = CGFloat(index) / 4 * 2 * .pi + .pi / 4
            context.drawLayer { layer in
                layer.translateBy(x: center.x, y: center.y)
                layer.rotate(by: .radians(angle))
                let petal = Path(ellipseIn: CGRect(x: -0.17 * s, y: -0.34 * s, width: 0.34 * s, height: 0.38 * s))
                layer.fill(petal, with: .color(index.isMultiple(of: 2) ? colors.petal : colors.petalLight))
            }
        }
        context.fill(Path(ellipseIn: rect(0.5, 0.40, 0.22, 0.22)), with: .color(colors.center))
        for index in 0..<10 {
            let angle = CGFloat(index) / 10 * 2 * .pi
            let dot = CGRect(x: center.x + cos(angle) * 0.085 * s - 0.012 * s, y: center.y + sin(angle) * 0.085 * s - 0.012 * s, width: 0.024 * s, height: 0.024 * s)
            context.fill(Path(ellipseIn: dot), with: .color(colors.petalDark))
        }
    }

    private static func drawIris(colors: FlowerColors, in context: inout GraphicsContext, p: (CGFloat, CGFloat) -> CGPoint, rect: (CGFloat, CGFloat, CGFloat, CGFloat) -> CGRect, s: CGFloat) {
        let center = p(0.5, 0.41)
        for index in 0..<3 {
            let angle = CGFloat(index) / 3 * 2 * .pi
            context.drawLayer { layer in
                layer.translateBy(x: center.x, y: center.y)
                layer.rotate(by: .radians(angle))
                let standard = Path(ellipseIn: CGRect(x: -0.09 * s, y: -0.34 * s, width: 0.18 * s, height: 0.34 * s))
                layer.fill(standard, with: .color(colors.petalLight))
                let fall = Path(ellipseIn: CGRect(x: -0.13 * s, y: 0.01 * s, width: 0.26 * s, height: 0.30 * s))
                layer.fill(fall, with: .color(colors.petal))
                let beard = Path(ellipseIn: CGRect(x: -0.025 * s, y: 0.06 * s, width: 0.05 * s, height: 0.16 * s))
                layer.fill(beard, with: .color(colors.center))
            }
        }
        context.fill(Path(ellipseIn: rect(0.5, 0.41, 0.12, 0.12)), with: .color(colors.petalDark))
    }
}

struct FlowerView: View {
    enum Stage: Hashable {
        case bud
        case bloom
    }

    let kind: FlowerKind
    let stage: Stage
    var variant: Int = 0

    var body: some View {
        Canvas { context, size in
            FlowerArt.draw(kind, stage: stage, colors: FlowerArt.colors(kind, variant: variant), in: &context, size: size)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

/// A small bloom for lists and badges.
struct FlowerIcon: View {
    let kind: FlowerKind
    var size: CGFloat = 28
    var variant: Int = 0

    var body: some View {
        FlowerView(kind: kind, stage: .bloom, variant: variant)
            .frame(width: size, height: size)
    }
}
