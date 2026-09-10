import SwiftUI

struct GreenhouseView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: Tab = .flowers
    @State private var detail: FlowerKind?

    enum Tab: String, CaseIterable, Identifiable {
        case flowers, seeds, decor
        var id: String { rawValue }
        var title: String {
            switch self {
            case .flowers: "Flowers"
            case .seeds: "Seeds"
            case .decor: "Decor"
            }
        }
        var symbol: String {
            switch self {
            case .flowers: "camera.macro"
            case .seeds: "bag.fill"
            case .decor: "chair.lounge.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HUDBar()
            ScreenHeader(title: "Greenhouse", subtitle: "Collect and grow") { model.goHome() }
            tabs
            ScrollView(showsIndicators: false) {
                switch tab {
                case .flowers: flowerGrid
                case .seeds: seedList
                case .decor: decorList
                }
            }
            HubNav(selected: .greenhouse)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .contentColumn()
        .sheet(item: $detail) { kind in
            FlowerDetailSheet(kind: kind)
                .presentationDetents([.large])
        }
    }

    private var tabs: some View {
        HStack(spacing: 6) {
            ForEach(Tab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    Label(item.title, systemImage: item.symbol)
                        .font(Typography.caption)
                        .foregroundStyle(tab == item ? Palette.ink : Palette.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(tab == item ? Palette.paper : Palette.wood)
                                .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 1.5) }
                        }
                }
                .buttonStyle(PressStyle())
                .accessibilityIdentifier("greenhouse-tab-\(item.rawValue)")
            }
        }
    }

    private var flowerGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            ForEach(FlowerKind.allCases) { kind in
                Button {
                    if model.progress.isUnlocked(kind) { detail = kind }
                } label: {
                    FlowerCollectionCard(kind: kind)
                }
                .buttonStyle(PressStyle())
                .accessibilityIdentifier("collection-\(kind.rawValue)")
            }
        }
        .padding(.bottom, 8)
    }

    private var seedList: some View {
        VStack(spacing: 8) {
            PaperCard(padding: 10) {
                Text("Seed packets swap a card in your hand during a level. Bees leave them behind after a lavender relay, and the market sells the common kinds.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ForEach(FlowerKind.allCases.filter { model.progress.isUnlocked($0) }) { kind in
                PaperCard(padding: 10) {
                    HStack(spacing: 12) {
                        FlowerIcon(kind: kind, size: 36, variant: model.progress.variant(for: kind))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(kind.name) Seeds")
                                .font(Typography.body)
                                .foregroundStyle(Palette.ink)
                            Text("\(kind.growTurns) turn\(kind.growTurns == 1 ? "" : "s") to bloom · relay \(kind.relayPower)")
                                .font(Typography.small)
                                .foregroundStyle(Palette.inkSoft)
                        }
                        Spacer()
                        Text("×\(model.progress.seeds[kind, default: 0])")
                            .font(Typography.heading)
                            .foregroundStyle(Palette.ink)
                            .monospacedDigit()
                    }
                }
            }
        }
        .padding(.bottom, 8)
    }

    private var decorList: some View {
        VStack(spacing: 8) {
            ForEach(DecorID.allCases) { decor in
                let owned = model.progress.garden.inventory[decor, default: 0]
                let placed = model.progress.garden.count(of: decor)
                PaperCard(padding: 10) {
                    HStack(spacing: 12) {
                        DecorTile(decor: decor)
                            .frame(width: 40, height: 40)
                            .opacity(owned + placed > 0 ? 1 : 0.4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(decor.name)
                                .font(Typography.body)
                                .foregroundStyle(Palette.ink)
                            Text(decor.blurb)
                                .font(Typography.small)
                                .foregroundStyle(Palette.inkSoft)
                                .lineLimit(2)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 1) {
                            if owned + placed > 0 {
                                Text("\(placed) placed")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.mossDark)
                                Text("\(owned) spare")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.inkSoft)
                            } else if let level = decor.earnedAtLevel {
                                Text("Level \(level)")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.inkSoft)
                            } else if let price = decor.price {
                                Text("\(price) coins")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.inkSoft)
                            } else {
                                Text("Order reward")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.inkSoft)
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom, 8)
    }
}

private struct FlowerCollectionCard: View {
    @Environment(AppModel.self) private var model
    let kind: FlowerKind

    private var unlocked: Bool { model.progress.isUnlocked(kind) }
    private var blooms: Int { model.progress.bloomCounts[kind, default: 0] }
    private var nextThreshold: Int? {
        FlowerKind.variantThresholds.first { $0 > blooms }
    }

    var body: some View {
        PaperCard(padding: 10) {
            VStack(spacing: 6) {
                Text(kind.name)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.ink)
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.leafLight.opacity(0.5), Palette.moss.opacity(0.35)], startPoint: .top, endPoint: .bottom))
                    if unlocked {
                        FlowerView(kind: kind, stage: .bloom, variant: model.progress.variant(for: kind))
                            .padding(6)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
                .frame(height: 96)
                if unlocked {
                    VStack(spacing: 2) {
                        ProgressView(value: Double(min(blooms, nextThreshold ?? blooms)), total: Double(nextThreshold ?? max(blooms, 1)))
                            .tint(Palette.moss)
                        Text(nextThreshold.map { "\(blooms)/\($0) blooms" } ?? "\(blooms) blooms · all variants")
                            .font(Typography.small)
                            .foregroundStyle(Palette.inkSoft)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: traitSymbol)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Palette.moss)
                        Text(kind.trait)
                            .font(Typography.small)
                            .foregroundStyle(Palette.ink)
                    }
                    Text(kind.motto)
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                } else {
                    Text(unlockNote)
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                        .frame(height: 58)
                }
            }
        }
        .opacity(unlocked ? 1 : 0.85)
    }

    private var traitSymbol: String {
        switch kind {
        case .daisy: "bolt.fill"
        case .tulip: "link"
        case .sunflower: "sun.max.fill"
        case .lavender: "ant.fill"
        case .rose: "heart.fill"
        case .marigold: "shield.fill"
        }
    }

    private var unlockNote: String {
        if let level = LevelCatalog.all.first(where: { LevelCatalog.unlock(afterCompleting: $0.id) == kind }) {
            return "Clear Level \(level.id) to grow it."
        }
        return "Coming soon."
    }
}

private struct FlowerDetailSheet: View {
    @Environment(AppModel.self) private var model
    let kind: FlowerKind

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text(kind.name)
                        .font(Typography.title)
                        .foregroundStyle(Palette.ink)
                        .padding(.top, 20)
                    FlowerView(kind: kind, stage: .bloom, variant: model.progress.variant(for: kind))
                        .frame(height: 150)
                    PaperCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            stat("Care cycles to bloom", "\(kind.growTurns)")
                            stat("Relay power", "\(kind.relayPower) care point\(kind.relayPower == 1 ? "" : "s")")
                            stat("Bloom stays", "\(kind.bloomStay) turn\(kind.bloomStay == 1 ? "" : "s")")
                            stat("Market value", "\(kind.value) coins")
                            stat("Pollinators", kind.pollinatorFriendly ? "Loved by bees" : "Not a bee favourite")
                            Divider()
                            Text(kind.trait)
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            Text(kind.traitDetail)
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    variantPicker
                    PaperCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Garden Journal", systemImage: "book.fill")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            Text(kind.journalFact)
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .contentColumn()
            }
        }
    }

    private func stat(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.inkSoft)
            Spacer()
            Text(value)
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
        }
    }

    private var variantPicker: some View {
        let unlocked = model.progress.variantsUnlocked(for: kind)
        let selected = model.progress.variant(for: kind)
        return PaperCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Varieties")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.ink)
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { index in
                        let open = index < unlocked
                        Button {
                            model.selectVariant(index, for: kind)
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(Palette.leafLight.opacity(0.4))
                                    if open {
                                        FlowerView(kind: kind, stage: .bloom, variant: index)
                                            .padding(4)
                                    } else {
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(Palette.inkSoft)
                                    }
                                }
                                .frame(width: 56, height: 56)
                                .overlay { Circle().strokeBorder(selected == index ? Palette.sun : Palette.woodDark.opacity(0.3), lineWidth: selected == index ? 3 : 1) }
                                Text(open ? kind.variantNames[index] : "\(FlowerKind.variantThresholds[index]) blooms")
                                    .font(Typography.small)
                                    .foregroundStyle(Palette.inkSoft)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PressStyle())
                        .disabled(!open)
                    }
                }
            }
        }
    }
}
