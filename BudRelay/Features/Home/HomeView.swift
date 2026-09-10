import SwiftUI

struct LogoView: View {
    var subtitle: String? = "Plant now. Bloom later."
    var scale: CGFloat = 1

    var body: some View {
        VStack(spacing: -8 * scale) {
            HStack(spacing: 6 * scale) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 22 * scale, weight: .bold))
                    .foregroundStyle(Palette.leafLight)
                    .rotationEffect(.degrees(-20))
                Text("Bud")
                    .foregroundStyle(Palette.cream)
                    + Text(" Relay")
                    .foregroundStyle(Palette.leafLight)
                FlowerIcon(kind: .daisy, size: 30 * scale)
            }
            .font(Typography.display(38 * scale))
            .shadow(color: Palette.woodDark, radius: 0, y: 2)
            .padding(.vertical, 8 * scale)
            .padding(.horizontal, 20 * scale)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                    WoodGrain().clipShape(RoundedRectangle(cornerRadius: 16 * scale, style: .continuous))
                    RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                        .strokeBorder(Palette.woodDark, lineWidth: 3)
                }
                .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
            }
            .zIndex(1)
            if let subtitle {
                Text(subtitle)
                    .font(Typography.body)
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 12 * scale)
                    .padding(.bottom, 6 * scale)
                    .padding(.horizontal, 18 * scale)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Palette.paper)
                            .overlay { RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Palette.woodDark.opacity(0.35), lineWidth: 1.5) }
                            .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
                    }
            }
        }
    }
}

struct HomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 12) {
            HUDBar()
            LogoView()
                .padding(.top, 2)
            chapterSign
            BoardView(board: previewBoard, variants: model.progress.variants, interactive: false)
                .padding(.horizontal, 6)
            PrimaryButton(title: "Play", action: model.playNext)
                .accessibilityIdentifier("play-button")
            HStack(spacing: 10) {
                WoodButton(title: "Map", symbol: "map.fill") { model.go(.map) }
                    .accessibilityIdentifier("map-button")
                WoodButton(title: "How to Play", symbol: "questionmark.circle.fill") { model.go(.howToPlay) }
                    .accessibilityIdentifier("howto-button")
            }
            Spacer(minLength: 0)
            BottomNav(items: HomeView.navItems(model: model), selected: .home) { model.go($0) }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .contentColumn()
    }

    private var chapterSign: some View {
        let level = LevelCatalog.level(model.progress.nextLevelID)
        let chapter = level?.chapter ?? .communityGarden
        return HStack(spacing: 10) {
            Image(systemName: chapter.symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Palette.cream)
            VStack(alignment: .leading, spacing: 1) {
                Text(chapter.name)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.cream)
                Text(model.progress.isCompleted(LevelCatalog.count) ? "Every bed is blooming" : "Next: Level \(model.progress.nextLevelID)")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.cream.opacity(0.85))
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundStyle(Palette.sun)
                Text("\(model.progress.totalStars)")
                    .foregroundStyle(Palette.cream)
                    .monospacedDigit()
            }
            .font(Typography.body)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                .overlay { RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 2) }
                .shadow(color: .black.opacity(0.2), radius: 3, y: 3)
        }
    }

    /// A dressed-up look at the next level's bed.
    private var previewBoard: Board {
        guard let level = LevelCatalog.level(model.progress.nextLevelID) else { return Board() }
        var board = level.initialBoard()
        let sample: [(Cell, FlowerKind, Int)] = [
            (Cell(0, 1), .tulip, 2), (Cell(1, 3), .daisy, 1), (Cell(2, 1), .sunflower, 3),
            (Cell(3, 3), .tulip, 1), (Cell(4, 1), .lavender, 2), (Cell(1, 0), .rose, 3), (Cell(3, 0), .marigold, 2),
        ]
        var placed = 0
        for (cell, kind, turns) in sample where board.canPlant(at: cell) && level.kinds.contains(kind) && placed < 5 {
            board[cell].plant = Plant(kind: kind, stage: .bud(turnsLeft: turns))
            placed += 1
        }
        if board.canPlant(at: Cell(2, 3)) {
            board[Cell(2, 3)].plant = Plant(kind: level.kinds.first ?? .daisy, stage: .bloom(stayLeft: 1))
        }
        return board
    }

    static func navItems(model: AppModel) -> [NavItem] {
        let playedToday = model.progress.dailyRecord(for: DailyBloom.dayNumber()) != nil
        return [
            NavItem(id: "daily", title: "Daily Bloom", symbol: "calendar", screen: .daily, badge: !playedToday),
            NavItem(id: "garden", title: "Garden", symbol: "leaf.fill", screen: .garden),
            NavItem(id: "greenhouse", title: "Greenhouse", symbol: "building.2.fill", screen: .greenhouse),
            NavItem(id: "market", title: "Market", symbol: "storefront.fill", screen: .market),
        ]
    }
}

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            BackButton(action: onBack)
            Spacer()
            VStack(spacing: 2) {
                SignTitle(text: title, size: 24)
                if let subtitle {
                    Text(subtitle)
                        .font(Typography.caption)
                        .foregroundStyle(Palette.cream.opacity(0.9))
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 18)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                    .overlay { RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 2) }
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 3)
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
    }
}

/// The bottom navigation used by every hub screen.
struct HubNav: View {
    @Environment(AppModel.self) private var model
    let selected: Screen

    var body: some View {
        BottomNav(items: [NavItem(id: "home", title: "Home", symbol: "house.fill", screen: .home)] + HomeView.navItems(model: model), selected: selected) {
            model.go($0)
        }
    }
}
