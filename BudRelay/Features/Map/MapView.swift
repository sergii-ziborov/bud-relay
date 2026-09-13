import SwiftUI

struct MapView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 7) {
                HUDBar()
                HStack(spacing: 8) {
                    BackButton(action: model.goHome)
                    LogoView(subtitle: nil, scale: 0.5)
                    Spacer()
                    ResourcePill(symbol: "star.fill", text: "\(model.progress.totalStars)", tint: Palette.sun)
                }
                route(in: CGSize(width: proxy.size.width - 20, height: max(300, proxy.size.height - 190)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                BottomNav(
                    items: [
                        NavItem(id: "map", title: "Map", symbol: "map.fill", screen: .map),
                        NavItem(id: "garden", title: "Garden", symbol: "leaf.fill", screen: .garden),
                        NavItem(id: "greenhouse", title: "Greenhouse", symbol: "building.2.fill", screen: .greenhouse),
                        NavItem(id: "market", title: "Market", symbol: "storefront.fill", screen: .market),
                    ],
                    selected: .map,
                    onSelect: model.go
                )
            }
            .padding(.horizontal, 10)
            .padding(.top, 6)
            .padding(.bottom, 8)
            .contentColumn()
        }
    }

    private var visibleLevels: [LevelDef] {
        let count = LevelCatalog.count
        let upper = min(count, max(12, model.progress.nextLevelID + 5))
        let lower = max(1, upper - 11)
        return (lower...upper).compactMap(LevelCatalog.level)
    }

    private func route(in size: CGSize) -> some View {
        let levels = visibleLevels
        return ZStack {
            Canvas { context, canvasSize in
                var route = Path()
                for index in levels.indices {
                    let position = routePoint(index: index, count: levels.count, in: canvasSize)
                    if index == levels.startIndex { route.move(to: position) } else { route.addLine(to: position) }
                }
                context.stroke(route, with: .color(Palette.paper.opacity(0.88)), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                context.stroke(route, with: .color(Palette.woodDark.opacity(0.35)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 8]))
            }
            .shadow(color: .black.opacity(0.2), radius: 4, y: 3)

            ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                MapRouteNode(level: level)
                    .position(routePoint(index: index, count: levels.count, in: size))
            }

            VStack {
                chapterSign(levels.last?.chapter ?? .communityGarden)
                Spacer()
                HStack {
                    chapterSign(levels.first?.chapter ?? .communityGarden)
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            .allowsHitTesting(false)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.cream.opacity(0.55), lineWidth: 1.5)
        }
    }

    private func chapterSign(_ chapter: ChapterID) -> some View {
        HStack(spacing: 5) {
            Image(systemName: chapter.symbol)
            Text(chapter.name)
        }
        .font(Typography.caption)
        .foregroundStyle(Palette.cream)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(Palette.wood.opacity(0.95))
                .overlay { RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 1.5) }
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
        }
    }

    private func routePoint(index: Int, count: Int, in size: CGSize) -> CGPoint {
        let t = count > 1 ? CGFloat(index) / CGFloat(count - 1) : 0
        let bend = sin(t * .pi * 3.2 + 0.45)
        return CGPoint(
            x: size.width * (0.52 + bend * 0.25),
            y: size.height * (0.90 - t * 0.78)
        )
    }
}

private struct MapRouteNode: View {
    @Environment(AppModel.self) private var model
    let level: LevelDef

    private var unlocked: Bool { model.progress.isUnlocked(level: level.id) }
    private var stars: Int { model.progress.stars(for: level.id) }
    private var current: Bool { level.id == model.progress.nextLevelID }

    var body: some View {
        Button {
            model.play(level: level.id)
        } label: {
            VStack(spacing: -2) {
                StarRow(stars: stars, size: 10)
                ZStack {
                    Ellipse()
                        .fill(LinearGradient(colors: current ? [Palette.sun, Palette.gold] : (stars > 0 ? [Palette.paper, Palette.paperDark] : [Palette.stone, Palette.wood]), startPoint: .top, endPoint: .bottom))
                        .overlay { Ellipse().strokeBorder(current ? Palette.glow : Palette.woodDark, lineWidth: current ? 4 : 2) }
                        .shadow(color: current ? Palette.sun.opacity(0.8) : .black.opacity(0.25), radius: current ? 8 : 3, y: 3)
                    if unlocked {
                        Text("\(level.id)")
                            .font(Typography.heading)
                            .foregroundStyle(current || stars > 0 ? Palette.ink : Palette.cream)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(Palette.cream)
                    }
                }
                .frame(width: current ? 56 : 48, height: current ? 43 : 37)
            }
        }
        .buttonStyle(PressStyle())
        .disabled(!unlocked)
        .accessibilityIdentifier("level-\(level.id)")
    }
}

private struct ChapterCard: View {
    @Environment(AppModel.self) private var model
    let chapter: ChapterID

    private var unlocked: Bool { model.progress.isUnlocked(chapter) }

    var body: some View {
        WoodPanel(cornerRadius: 18, padding: 12) {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: chapter.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Palette.cream)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Palette.woodDark.opacity(0.6)))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Chapter \(chapter.number) · \(chapter.name)")
                            .font(Typography.heading)
                            .foregroundStyle(Palette.cream)
                        Text(chapter.tagline)
                            .font(Typography.caption)
                            .foregroundStyle(Palette.cream.opacity(0.85))
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: unlocked ? "star.fill" : "lock.fill").foregroundStyle(Palette.sun)
                        Text(unlocked ? "\(model.progress.stars(in: chapter))/30" : "Locked")
                            .foregroundStyle(Palette.cream)
                            .monospacedDigit()
                    }
                    .font(Typography.caption)
                }
                PaperCard(padding: 10) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 10) {
                        ForEach(LevelCatalog.levels(in: chapter)) { level in
                            LevelNode(level: level)
                        }
                    }
                }
            }
        }
        .opacity(unlocked ? 1 : 0.7)
    }
}

private struct LevelNode: View {
    @Environment(AppModel.self) private var model
    let level: LevelDef

    private var unlocked: Bool { model.progress.isUnlocked(level: level.id) }
    private var stars: Int { model.progress.stars(for: level.id) }
    private var isNext: Bool { level.id == model.progress.nextLevelID }

    var body: some View {
        Button {
            model.play(level: level.id)
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: stars > 0 ? [Palette.leafLight, Palette.moss] : (unlocked ? [Palette.woodLight, Palette.wood] : [Palette.stone.opacity(0.7), Palette.stone]),
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .overlay { Circle().strokeBorder(isNext ? Palette.sun : Palette.woodDark, lineWidth: isNext ? 3 : 2) }
                        .shadow(color: isNext ? Palette.sun.opacity(0.8) : .black.opacity(0.2), radius: isNext ? 6 : 2, y: 2)
                    if unlocked {
                        Text("\(level.id)")
                            .font(Typography.heading)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.4), radius: 0, y: 1)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .frame(width: 46, height: 46)
                StarRow(stars: stars, size: 9)
                    .opacity(unlocked ? 1 : 0.3)
                Image(systemName: level.goals.first?.symbol ?? "leaf.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
        .buttonStyle(PressStyle())
        .disabled(!unlocked)
        .accessibilityIdentifier("level-\(level.id)")
    }
}
