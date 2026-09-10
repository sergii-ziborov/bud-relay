import SwiftUI

// MARK: - Panels

struct WoodPanel<Content: View>: View {
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 14
    var nails = true
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                    WoodGrain()
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Palette.woodDark.opacity(0.9), lineWidth: 2.5)
                    if nails {
                        Nails(inset: 9)
                    }
                }
                .shadow(color: .black.opacity(0.25), radius: 6, y: 4)
            }
    }
}

struct WoodGrain: View {
    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 6
            var index = 0
            while y < size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                let wobble = CGFloat(index % 3) * 3
                path.addCurve(
                    to: CGPoint(x: size.width, y: y + wobble),
                    control1: CGPoint(x: size.width * 0.3, y: y - 4),
                    control2: CGPoint(x: size.width * 0.7, y: y + 5)
                )
                context.stroke(path, with: .color(Palette.woodDark.opacity(0.12)), lineWidth: 1.2)
                y += 9 + CGFloat(index % 4) * 3
                index += 1
            }
        }
        .allowsHitTesting(false)
    }
}

struct Nails: View {
    var inset: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let points = [
                CGPoint(x: inset, y: inset),
                CGPoint(x: proxy.size.width - inset, y: inset),
                CGPoint(x: inset, y: proxy.size.height - inset),
                CGPoint(x: proxy.size.width - inset, y: proxy.size.height - inset),
            ]
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(RadialGradient(colors: [Color.gray.opacity(0.9), Palette.woodDark], center: .topLeading, startRadius: 0, endRadius: 6))
                    .frame(width: 7, height: 7)
                    .position(points[index])
            }
        }
        .allowsHitTesting(false)
    }
}

struct PaperCard<Content: View>: View {
    var cornerRadius: CGFloat = 12
    var padding: CGFloat = 12
    var tilt: Double = 0
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.paper, Palette.paperDark.opacity(0.85)], startPoint: .top, endPoint: .bottom))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Palette.woodDark.opacity(0.18), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.14), radius: 3, y: 2)
            }
            .rotationEffect(.degrees(tilt))
    }
}

struct SignTitle: View {
    let text: String
    var size: CGFloat = 26

    var body: some View {
        Text(text)
            .font(Typography.display(size))
            .foregroundStyle(Palette.cream)
            .shadow(color: Palette.woodDark.opacity(0.8), radius: 0, y: 2)
    }
}

// MARK: - Buttons

struct PrimaryButton: View {
    let title: String
    var symbol: String? = "leaf.fill"
    var compact = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: compact ? 16 : 22, weight: .bold))
                }
                Text(title)
                    .font(Typography.display(compact ? 20 : 30))
            }
            .foregroundStyle(.white)
            .shadow(color: Palette.mossDark.opacity(0.8), radius: 0, y: 2)
            .padding(.vertical, compact ? 10 : 16)
            .padding(.horizontal, compact ? 22 : 40)
            .frame(maxWidth: compact ? nil : .infinity)
            .background {
                Capsule()
                    .fill(LinearGradient(colors: [Palette.leaf, Palette.moss, Palette.mossDark], startPoint: .top, endPoint: .bottom))
                    .overlay {
                        Capsule()
                            .strokeBorder(Palette.mossDark, lineWidth: 3)
                    }
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(.white.opacity(0.28))
                            .frame(height: compact ? 10 : 16)
                            .padding(.horizontal, compact ? 18 : 30)
                            .padding(.top, 5)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 6, y: 5)
            }
        }
        .buttonStyle(PressStyle())
    }
}

struct WoodButton: View {
    let title: String
    var symbol: String?
    var tint: Color = Palette.cream
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(Typography.heading)
            }
            .foregroundStyle(tint)
            .shadow(color: Palette.woodDark.opacity(0.7), radius: 0, y: 1)
            .padding(.vertical, 11)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Palette.woodDark, lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
            }
        }
        .buttonStyle(PressStyle())
    }
}

struct IconButton: View {
    let symbol: String
    var size: CGFloat = 44
    var accessibilityID: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size * 0.42, weight: .bold))
                .foregroundStyle(Palette.cream)
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                        .overlay { Circle().strokeBorder(Palette.woodDark, lineWidth: 2) }
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                }
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier(accessibilityID ?? symbol)
    }
}

struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(duration: 0.2, bounce: 0.4), value: configuration.isPressed)
    }
}

// MARK: - Navigation

struct NavItem: Identifiable {
    let id: String
    let title: String
    let symbol: String
    let screen: Screen
    var badge = false
}

struct BottomNav: View {
    let items: [NavItem]
    let selected: Screen
    let onSelect: (Screen) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                Button {
                    onSelect(item.screen)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 22, weight: .bold))
                            .frame(height: 26)
                        Text(item.title)
                            .font(Typography.small)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Palette.cream)
                    .shadow(color: Palette.woodDark.opacity(0.7), radius: 0, y: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: item.screen == selected
                                        ? [Palette.leaf, Palette.mossDark]
                                        : [Palette.woodLight, Palette.wood],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(item.screen == selected ? Palette.mossDark : Palette.woodDark, lineWidth: 2)
                            }
                            .shadow(color: .black.opacity(0.25), radius: 3, y: 3)
                    }
                    .overlay(alignment: .topTrailing) {
                        if item.badge {
                            Circle()
                                .fill(Palette.coral)
                                .frame(width: 16, height: 16)
                                .overlay {
                                    Text("!")
                                        .font(Typography.small)
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 4, y: -5)
                        }
                    }
                }
                .buttonStyle(PressStyle())
                .accessibilityIdentifier("nav-\(item.id)")
            }
        }
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        IconButton(symbol: "chevron.left", accessibilityID: "back-button", action: action)
    }
}

// MARK: - HUD

struct ResourcePill: View {
    let symbol: String
    let text: String
    var tint: Color = Palette.gold
    var accessibilityID: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tint)
            Text(text)
                .font(Typography.caption)
                .foregroundStyle(Palette.cream)
                .monospacedDigit()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background {
            Capsule()
                .fill(Palette.woodDark.opacity(0.85))
                .overlay { Capsule().strokeBorder(Palette.woodLight.opacity(0.6), lineWidth: 1.5) }
        }
        .accessibilityIdentifier(accessibilityID ?? "pill-\(symbol)")
    }
}

struct HUDBar: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Palette.leafLight, Palette.moss], startPoint: .top, endPoint: .bottom))
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 38, height: 38)
                .overlay { Circle().strokeBorder(Palette.woodDark, lineWidth: 2) }
                Text("Lv \(model.progress.playerLevel)")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.cream)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Capsule().fill(Palette.woodDark.opacity(0.85)))
            }
            Spacer(minLength: 4)
            ResourcePill(symbol: "dollarsign.circle.fill", text: "\(model.progress.coins)", accessibilityID: "coins")
            ResourcePill(symbol: "camera.macro", text: "\(model.progress.flowerCount)", tint: Palette.blush, accessibilityID: "flowers")
            IconButton(symbol: "gearshape.fill", size: 38, accessibilityID: "settings-button") {
                model.go(.settings)
            }
        }
    }
}

struct TimerBadge: View {
    let value: Int
    var size: CGFloat = 22

    var body: some View {
        Text("\(value)")
            .font(.system(size: size * 0.6, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(Palette.ink)
                    .overlay { Circle().strokeBorder(Palette.cream, lineWidth: 1.5) }
                    .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
            }
    }
}

struct StarRow: View {
    let stars: Int
    var size: CGFloat = 22
    var total = 3

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < stars ? Palette.sun : Palette.woodDark.opacity(0.35))
                    .shadow(color: index < stars ? Palette.gold.opacity(0.8) : .clear, radius: 2)
            }
        }
    }
}

struct SectionHeader: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Typography.heading)
            .foregroundStyle(Palette.ink)
    }
}

// MARK: - Overlays

struct NoticeBanner: View {
    let text: String

    var body: some View {
        VStack {
            Text(text)
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background {
                    Capsule()
                        .fill(Palette.paper)
                        .overlay { Capsule().strokeBorder(Palette.woodDark.opacity(0.4), lineWidth: 1.5) }
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 4)
                }
                .padding(.top, 60)
            Spacer()
        }
        .allowsHitTesting(false)
    }
}

struct StoryOverlay: View {
    @Environment(AppModel.self) private var model
    let scene: StoryScene
    @State private var lineIndex = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: advance)
            VStack(spacing: 14) {
                Spacer()
                WoodPanel(cornerRadius: 22, padding: 16) {
                    VStack(spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: scene.symbol)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Palette.cream)
                            SignTitle(text: scene.title, size: 22)
                        }
                        PaperCard(padding: 14) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle().fill(LinearGradient(colors: [Palette.leafLight, Palette.moss], startPoint: .top, endPoint: .bottom))
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                    .frame(width: 40, height: 40)
                                    .overlay { Circle().strokeBorder(Palette.woodDark, lineWidth: 2) }
                                    Text(line.speaker)
                                        .font(Typography.heading)
                                        .foregroundStyle(Palette.ink)
                                    Spacer()
                                    Text("\(lineIndex + 1)/\(scene.lines.count)")
                                        .font(Typography.caption)
                                        .foregroundStyle(Palette.inkSoft)
                                }
                                Text(line.text)
                                    .font(Typography.body)
                                    .foregroundStyle(Palette.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .id(lineIndex)
                                    .transition(.opacity)
                            }
                        }
                        PrimaryButton(title: isLast ? "Continue" : "Next", symbol: nil, compact: true, action: advance)
                            .accessibilityIdentifier("story-next")
                    }
                }
                .contentColumn()
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: lineIndex)
    }

    private var line: StoryLine {
        scene.lines[min(lineIndex, scene.lines.count - 1)]
    }

    private var isLast: Bool {
        lineIndex >= scene.lines.count - 1
    }

    private func advance() {
        if isLast {
            model.dismissScene()
        } else {
            lineIndex += 1
        }
    }
}
