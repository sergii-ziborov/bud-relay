import SwiftUI

struct GardenView: View {
    @Environment(AppModel.self) private var model
    @State private var category: DecorCategory? = nil
    @State private var selectedDecor: DecorID?
    @State private var selectedFlower: FlowerKind?
    @State private var showGoals = false

    var body: some View {
        VStack(spacing: 10) {
            HUDBar()
            ScreenHeader(title: "Our Garden", subtitle: "Brighter tomorrows") { model.goHome() }
            goalsCard
            GardenCanvas(garden: model.progress.garden, variants: model.progress.variants, placing: selectedDecor != nil || selectedFlower != nil) { cell in
                tap(cell)
            }
            hint
            inventory
            HubNav(selected: .garden)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .contentColumn()
        .sheet(isPresented: $showGoals) {
            GardenGoalsSheet()
                .presentationDetents([.medium, .large])
        }
    }

    private var goalsCard: some View {
        let goals = model.gardenGoals
        let done = goals.filter(\.done).count
        let next = goals.first { !$0.done }
        return Button {
            showGoals = true
        } label: {
            PaperCard(padding: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "checklist")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Palette.moss)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("Garden Goals")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            Spacer()
                            Text("\(done)/\(goals.count)")
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                                .monospacedDigit()
                        }
                        ProgressView(value: Double(done), total: Double(goals.count))
                            .tint(Palette.moss)
                        if let next {
                            Text("\(next.goal.title): \(next.goal.detail)")
                                .font(Typography.small)
                                .foregroundStyle(Palette.inkSoft)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        } else {
                            Text("Every goal is done. The garden is yours.")
                                .font(Typography.small)
                                .foregroundStyle(Palette.mossDark)
                        }
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.inkSoft)
                }
            }
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("garden-goals")
    }

    private var hint: some View {
        Text(hintText)
            .font(Typography.small)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background { RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Palette.paper.opacity(0.9)) }
    }

    private var hintText: String {
        if let decor = selectedDecor { return "Tap a free tile to place the \(decor.name.lowercased())." }
        if let kind = selectedFlower { return "Tap a free tile to plant \(kind.name.lowercased())." }
        return "Pick something below to place it. Tap a placed piece to pick it up again."
    }

    private var inventory: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                categoryTab(nil, title: "All", symbol: "square.grid.2x2.fill")
                ForEach(DecorCategory.allCases) { cat in
                    categoryTab(cat, title: cat.name, symbol: cat.symbol)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if items.isEmpty && flowers.isEmpty {
                        Text(category == .flowers ? "Earn flowers with relays of ×3 or more." : "Earn decor from levels, garden goals, and the market.")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.inkSoft)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(items, id: \.self) { decor in
                        inventoryCard(decor)
                    }
                    ForEach(flowers, id: \.self) { kind in
                        flowerCard(kind)
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 96)
        }
    }

    private var items: [DecorID] {
        guard category != .flowers else { return [] }
        return DecorID.allCases.filter { model.progress.garden.inventory[$0, default: 0] > 0 && (category == nil || $0.category == category) }
    }

    private var flowers: [FlowerKind] {
        guard category == nil || category == .flowers else { return [] }
        return FlowerKind.allCases.filter { model.progress.flowers[$0, default: 0] > 0 }
    }

    private func categoryTab(_ cat: DecorCategory?, title: String, symbol: String) -> some View {
        Button {
            category = cat
        } label: {
            VStack(spacing: 2) {
                Image(systemName: symbol)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(Typography.small)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(category == cat ? Palette.ink : Palette.cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(category == cat ? Palette.paper : Palette.wood)
                    .overlay { RoundedRectangle(cornerRadius: 9, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 1.5) }
            }
        }
        .buttonStyle(PressStyle())
    }

    private func inventoryCard(_ decor: DecorID) -> some View {
        Button {
            selectedFlower = nil
            selectedDecor = selectedDecor == decor ? nil : decor
        } label: {
            VStack(spacing: 3) {
                DecorTile(decor: decor)
                    .frame(width: 40, height: 40)
                Text(decor.name)
                    .font(Typography.small)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("×\(model.progress.garden.inventory[decor, default: 0])")
                    .font(Typography.small)
                    .foregroundStyle(Palette.inkSoft)
            }
            .frame(width: 84)
            .padding(.vertical, 6)
            .background(cardBackground(selected: selectedDecor == decor))
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("inventory-\(decor.rawValue)")
    }

    private func flowerCard(_ kind: FlowerKind) -> some View {
        Button {
            selectedDecor = nil
            selectedFlower = selectedFlower == kind ? nil : kind
        } label: {
            VStack(spacing: 3) {
                FlowerIcon(kind: kind, size: 40, variant: model.progress.variant(for: kind))
                Text(kind.name)
                    .font(Typography.small)
                    .foregroundStyle(Palette.ink)
                Text("×\(model.progress.flowers[kind, default: 0])")
                    .font(Typography.small)
                    .foregroundStyle(Palette.inkSoft)
            }
            .frame(width: 84)
            .padding(.vertical, 6)
            .background(cardBackground(selected: selectedFlower == kind))
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("basket-\(kind.rawValue)")
    }

    private func cardBackground(selected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Palette.paper)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(selected ? Palette.sun : Palette.woodDark.opacity(0.3), lineWidth: selected ? 3 : 1)
            }
            .shadow(color: selected ? Palette.sun.opacity(0.7) : .black.opacity(0.15), radius: selected ? 6 : 2, y: 2)
    }

    private func tap(_ cell: GardenCell) {
        let garden = model.progress.garden
        if let decor = selectedDecor {
            guard garden.isFree(cell) else {
                if model.progress.hapticsEnabled { Feedback.warn() }
                return
            }
            model.placeDecor(decor, at: cell)
            if model.progress.hapticsEnabled { Feedback.place() }
            if model.progress.garden.inventory[decor, default: 0] == 0 { selectedDecor = nil }
            return
        }
        if let kind = selectedFlower {
            guard garden.isFree(cell) else {
                if model.progress.hapticsEnabled { Feedback.warn() }
                return
            }
            model.plantFlower(kind, at: cell)
            if model.progress.hapticsEnabled { Feedback.place() }
            if model.progress.flowers[kind, default: 0] == 0 { selectedFlower = nil }
            return
        }
        if let placed = garden.decor(at: cell) {
            model.pickUpDecor(placed.id)
            if model.progress.hapticsEnabled { Feedback.tap() }
        } else if let flower = garden.flower(at: cell) {
            model.uprootFlower(flower.id)
            if model.progress.hapticsEnabled { Feedback.tap() }
        }
    }
}

private struct GardenGoalsSheet: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 10) {
                    SectionHeader(text: "Garden Goals")
                        .padding(.top, 16)
                    ForEach(model.gardenGoals, id: \.goal) { item in
                        PaperCard(padding: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(item.done ? Palette.mossDark : Palette.inkSoft)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.goal.title)
                                        .font(Typography.body)
                                        .foregroundStyle(Palette.ink)
                                    Text(item.goal.detail)
                                        .font(Typography.caption)
                                        .foregroundStyle(Palette.inkSoft)
                                }
                                Spacer()
                                Text("+\(item.goal.reward)")
                                    .font(Typography.caption)
                                    .foregroundStyle(Palette.gold)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Canvas

struct GardenCanvas: View {
    let garden: GardenState
    var variants: [FlowerKind: Int] = [:]
    var placing = false
    var onTap: ((GardenCell) -> Void)? = nil

    var body: some View {
        GeometryReader { proxy in
            let cols = CGFloat(GardenState.columns)
            let rows = CGFloat(GardenState.rows)
            let tile = min(proxy.size.width / cols, proxy.size.height / rows)
            let width = tile * cols
            let height = tile * rows
            ZStack(alignment: .topLeading) {
                grass(width: width, height: height, tile: tile)
                ForEach(GardenState.allCells, id: \.self) { cell in
                    tileContent(cell, tile: tile)
                        .frame(width: tile, height: tile)
                        .offset(x: CGFloat(cell.col) * tile, y: CGFloat(cell.row) * tile)
                }
                life(tile: tile)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Palette.woodDark, lineWidth: 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Palette.wood, lineWidth: 2)
                    .padding(3)
            }
            .shadow(color: .black.opacity(0.3), radius: 6, y: 4)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(CGFloat(GardenState.columns) / CGFloat(GardenState.rows), contentMode: .fit)
    }

    private func grass(width: CGFloat, height: CGFloat, tile: CGFloat) -> some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.55, green: 0.74, blue: 0.40), Color(red: 0.42, green: 0.64, blue: 0.32)], startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                for row in 0..<GardenState.rows {
                    for col in 0..<GardenState.columns {
                        let rect = CGRect(x: CGFloat(col) * tile, y: CGFloat(row) * tile, width: tile, height: tile)
                        if (row + col) % 2 == 0 {
                            context.fill(Path(rect), with: .color(.white.opacity(0.05)))
                        }
                        for blade in 0..<3 {
                            let x = rect.minX + tile * (0.2 + CGFloat((row * 7 + col * 3 + blade * 5) % 6) / 10)
                            let y = rect.minY + tile * (0.25 + CGFloat((row * 5 + col * 11 + blade * 7) % 6) / 10)
                            var path = Path()
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x + 2, y: y - tile * 0.12))
                            context.stroke(path, with: .color(Color(red: 0.30, green: 0.52, blue: 0.24).opacity(0.5)), lineWidth: 1.2)
                        }
                    }
                }
                _ = size
            }
        }
    }

    @ViewBuilder
    private func tileContent(_ cell: GardenCell, tile: CGFloat) -> some View {
        let decor = garden.decor(at: cell)
        let flower = garden.flower(at: cell)
        Button {
            onTap?(cell)
        } label: {
            ZStack {
                if placing, garden.isFree(cell) {
                    RoundedRectangle(cornerRadius: tile * 0.2, style: .continuous)
                        .strokeBorder(Palette.cream.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .padding(tile * 0.1)
                }
                if let decor {
                    DecorTile(decor: decor.decor)
                        .frame(width: tile * 0.82, height: tile * 0.82)
                } else if let flower {
                    ZStack {
                        Circle()
                            .fill(Palette.soil.opacity(0.75))
                            .frame(width: tile * 0.7, height: tile * 0.7)
                            .offset(y: tile * 0.12)
                        FlowerView(kind: flower.kind, stage: .bloom, variant: variants[flower.kind, default: 0])
                            .frame(width: tile * 0.8, height: tile * 0.8)
                    }
                }
            }
            .frame(width: tile, height: tile)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("garden-\(cell.row)-\(cell.col)")
    }

    /// Neighbours, bees, and birds show up as the garden fills in.
    @ViewBuilder
    private func life(tile: CGFloat) -> some View {
        let benches = garden.decor.filter { $0.decor == .communityBench }
        ForEach(Array(benches.prefix(garden.visitors).enumerated()), id: \.offset) { index, bench in
            Image(systemName: index % 2 == 0 ? "figure.seated.side.right" : "figure.seated.side.left")
                .font(.system(size: tile * 0.42, weight: .bold))
                .foregroundStyle(index % 2 == 0 ? Palette.coral : Palette.water)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
                .offset(x: CGFloat(bench.cell.col) * tile + tile * 0.5, y: CGFloat(bench.cell.row) * tile + tile * 0.18)
                .allowsHitTesting(false)
        }
        if garden.hasBees {
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ForEach(0..<3, id: \.self) { index in
                    let anchor = beeAnchor(index)
                    BeeView()
                        .frame(width: tile * 0.28, height: tile * 0.2)
                        .offset(
                            x: CGFloat(anchor.col) * tile + tile * 0.5 + CGFloat(sin(t * 1.4 + Double(index) * 2)) * tile * 0.5,
                            y: CGFloat(anchor.row) * tile + tile * 0.2 + CGFloat(cos(t * 2.1 + Double(index))) * tile * 0.25
                        )
                }
            }
            .allowsHitTesting(false)
        }
        if garden.hasBirds, let bath = garden.decor.first(where: { $0.decor == .birdbath || $0.decor == .birdhouse }) {
            Image(systemName: "bird.fill")
                .font(.system(size: tile * 0.3, weight: .bold))
                .foregroundStyle(Palette.woodDark)
                .offset(x: CGFloat(bath.cell.col) * tile + tile * 0.72, y: CGFloat(bath.cell.row) * tile + tile * 0.05)
                .allowsHitTesting(false)
        }
    }

    private func beeAnchor(_ index: Int) -> GardenCell {
        let targets = garden.flowers.filter { $0.kind == .lavender }.map(\.cell) + garden.decor.filter { $0.decor == .beeHotel }.map(\.cell)
        guard !targets.isEmpty else { return GardenCell(1, 1) }
        return targets[index % targets.count]
    }
}

struct BeeView: View {
    var body: some View {
        Canvas { context, size in
            let body = CGRect(x: size.width * 0.15, y: size.height * 0.3, width: size.width * 0.7, height: size.height * 0.6)
            context.fill(Path(ellipseIn: body), with: .color(Palette.sun))
            for index in 0..<3 {
                let x = body.minX + body.width * (0.3 + CGFloat(index) * 0.2)
                context.fill(Path(CGRect(x: x, y: body.minY, width: body.width * 0.1, height: body.height)), with: .color(Palette.ink))
            }
            let wingLeft = CGRect(x: size.width * 0.3, y: 0, width: size.width * 0.25, height: size.height * 0.45)
            let wingRight = CGRect(x: size.width * 0.5, y: 0, width: size.width * 0.25, height: size.height * 0.45)
            context.fill(Path(ellipseIn: wingLeft), with: .color(.white.opacity(0.8)))
            context.fill(Path(ellipseIn: wingRight), with: .color(.white.opacity(0.8)))
        }
    }
}

/// Small tile art for every decor piece.
struct DecorTile: View {
    let decor: DecorID

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            ZStack {
                base(side: side)
                Image(systemName: decor.symbol)
                    .font(.system(size: side * 0.42, weight: .bold))
                    .foregroundStyle(iconColor)
                    .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
            }
            .frame(width: side, height: side)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var tint: Color {
        switch decor {
        case .pathStone: Palette.stone
        case .planterBox, .communityBench, .pergola, .gardenArch, .beeHotel, .rainBarrel, .compostBin: Palette.wood
        case .lantern: Palette.sun
        case .birdbath, .sundial, .herbSpiral: Color(red: 0.72, green: 0.70, blue: 0.64)
        case .birdhouse: Palette.coral
        case .pond: Palette.water
        }
    }

    private var iconColor: Color {
        switch decor {
        case .pathStone: Color.white.opacity(0.35)
        case .lantern: Palette.woodDark
        case .pond: Color.white.opacity(0.85)
        case .birdbath: Palette.water
        case .compostBin: Palette.leafLight
        case .beeHotel: Palette.sun
        case .gardenArch: Palette.blush
        case .pergola: Palette.leafLight
        default: Palette.cream
        }
    }

    @ViewBuilder
    private func base(side: CGFloat) -> some View {
        switch decor {
        case .pathStone:
            Circle().fill(RadialGradient(colors: [Palette.stone.opacity(0.9), Palette.stone.opacity(0.6)], center: .topLeading, startRadius: 0, endRadius: side * 0.7))
                .padding(side * 0.1)
        case .pond:
            Ellipse().fill(RadialGradient(colors: [Palette.water.opacity(0.7), Palette.water], center: .center, startRadius: 0, endRadius: side * 0.6))
                .overlay { Ellipse().strokeBorder(Palette.woodDark.opacity(0.5), lineWidth: 2) }
        default:
            RoundedRectangle(cornerRadius: side * 0.22, style: .continuous)
                .fill(LinearGradient(colors: [tint.opacity(0.95), tint.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                .overlay { RoundedRectangle(cornerRadius: side * 0.22, style: .continuous).strokeBorder(Palette.woodDark.opacity(0.7), lineWidth: 2) }
                .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
        }
    }
}
