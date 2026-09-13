import SwiftUI

struct GreenhouseView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: Tab = .flowers
    @State private var detail: FlowerKind?
    @State private var treeDetail: TreeKind?
    @State private var flowerFilter: FlowerFilter = .all

    enum FlowerFilter: String, CaseIterable, Identifiable {
        case all, discovered
        var id: String { rawValue }
        var title: String { self == .all ? "All \(FlowerKind.allCases.count)" : "Discovered" }
    }

    enum Tab: String, CaseIterable, Identifiable {
        case flowers, trees, seeds, decor, journal
        var id: String { rawValue }
        var title: String {
            switch self {
            case .flowers: "Flowers"
            case .trees: "Trees"
            case .seeds: "Seeds"
            case .decor: "Decor"
            case .journal: "Journal"
            }
        }
        var symbol: String {
            switch self {
            case .flowers: "camera.macro"
            case .trees: "tree.fill"
            case .seeds: "bag.fill"
            case .decor: "chair.lounge.fill"
            case .journal: "book.closed.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            HUDBar()
            HStack(spacing: 8) {
                BackButton(action: model.goHome)
                Spacer(minLength: 0)
                LogoView(subtitle: "Greenhouse", scale: 0.58)
                Spacer(minLength: 0)
                Color.clear.frame(width: 44, height: 44)
            }
            tabs
            ScrollView(showsIndicators: false) {
                switch tab {
                case .flowers: flowerGrid
                case .trees: treeGrid
                case .seeds: seedList
                case .decor: decorList
                case .journal: loreJournal
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
        .sheet(item: $treeDetail) { kind in
            TreeDetailSheet(kind: kind)
                .presentationDetents([.large])
        }
    }

    private var tabs: some View {
        HStack(spacing: 6) {
            ForEach(Tab.allCases) { item in
                Button {
                    tab = item
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 13, weight: .bold))
                        Text(item.title)
                            .font(Typography.small)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
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

    private var treeGrid: some View {
        VStack(spacing: 10) {
            PaperCard(padding: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "tree.fill")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(Palette.mossDark)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Neighbourhood Arboretum")
                            .font(Typography.heading)
                            .foregroundStyle(Palette.ink)
                        Text("Long-lived trees belong to the estate, not the relay bed. Learn them here, then plant your own orchard.")
                            .font(Typography.small)
                            .foregroundStyle(Palette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(TreeKind.allCases) { tree in
                    Button {
                        if model.progress.isUnlocked(tree) { treeDetail = tree }
                    } label: {
                        TreeCollectionCard(kind: tree)
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityIdentifier("tree-collection-\(tree.rawValue)")
                }
            }
        }
        .padding(.bottom, 8)
    }

    private var loreJournal: some View {
        VStack(spacing: 8) {
            PaperCard(padding: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Green Neighbors Journal", systemImage: "person.3.fill")
                        .font(Typography.heading)
                        .foregroundStyle(Palette.ink)
                    Text("People and places are recorded as the district opens. Story scenes are no longer the only place to remember them.")
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            ForEach(LoreCatalog.all) { entry in
                let unlocked = model.progress.nextLevelID >= entry.unlockLevel || model.progress.isCompleted(entry.unlockLevel)
                PaperCard(padding: 11) {
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: unlocked ? entry.symbol : "lock.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(unlocked ? Palette.moss : Palette.inkSoft)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(unlocked ? entry.title : "Journal entry")
                                .font(Typography.body)
                                .foregroundStyle(Palette.ink)
                            Text(unlocked ? entry.subtitle : "Continue to Level \(entry.unlockLevel)")
                                .font(Typography.small)
                                .foregroundStyle(Palette.mossDark)
                            if unlocked {
                                Text(entry.text)
                                    .font(Typography.caption)
                                    .foregroundStyle(Palette.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
                .opacity(unlocked ? 1 : 0.72)
            }
        }
        .padding(.bottom, 8)
    }

    private var flowerGrid: some View {
        VStack(spacing: 10) {
            journalSummary
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 6) {
                ForEach(visibleFlowers) { kind in
                    Button {
                        if model.progress.isUnlocked(kind) { detail = kind }
                    } label: {
                        FlowerCollectionCard(kind: kind)
                    }
                    .buttonStyle(PressStyle())
                    .accessibilityIdentifier("collection-\(kind.rawValue)")
                }
            }
        }
        .padding(.bottom, 8)
    }

    private var visibleFlowers: [FlowerKind] {
        switch flowerFilter {
        case .all: FlowerKind.allCases
        case .discovered: FlowerKind.allCases.filter { model.progress.isUnlocked($0) }
        }
    }

    private var journalSummary: some View {
        let discovered = FlowerKind.allCases.filter { model.progress.isUnlocked($0) }.count
        let blooms = model.progress.bloomCounts.values.reduce(0, +)
        return PaperCard(padding: 10) {
            HStack(spacing: 10) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Palette.moss)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Garden Encyclopedia")
                        .font(Typography.heading)
                        .foregroundStyle(Palette.ink)
                    Text("\(discovered) of \(FlowerKind.allCases.count) species discovered · \(blooms) blooms recorded")
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer(minLength: 0)
            }
        }
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
            ForEach(DecorID.allCases.filter { $0.treeKind == nil }) { decor in
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

private struct TreeCollectionCard: View {
    @Environment(AppModel.self) private var model
    let kind: TreeKind

    private var unlocked: Bool { model.progress.isUnlocked(kind) }
    private var owned: Int {
        model.progress.garden.inventory[kind.decor, default: 0] + model.progress.garden.count(of: kind.decor)
    }

    var body: some View {
        PaperCard(cornerRadius: 10, padding: 7) {
            VStack(spacing: 5) {
                Text(kind.name)
                    .font(Typography.body)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.sky.opacity(0.7), Palette.leafLight.opacity(0.45)], startPoint: .top, endPoint: .bottom))
                    if unlocked {
                        GardenTreeView(kind: kind)
                            .padding(5)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
                .frame(height: 105)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(unlocked ? kind.scientificName : "Discover at Level \(kind.unlockLevel)")
                    .font(Typography.small)
                    .italic()
                    .foregroundStyle(Palette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if unlocked {
                    HStack {
                        Label("×\(owned)", systemImage: "tree.fill")
                        Spacer()
                        Text(kind.gardenRole)
                            .lineLimit(1)
                    }
                    .font(Typography.small)
                    .foregroundStyle(Palette.mossDark)
                }
            }
        }
        .opacity(unlocked ? 1 : 0.78)
    }
}

private struct TreeDetailSheet: View {
    @Environment(AppModel.self) private var model
    let kind: TreeKind

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 14) {
                    Text(kind.name)
                        .font(Typography.title)
                        .foregroundStyle(Palette.ink)
                        .padding(.top, 20)
                    VStack(spacing: 2) {
                        Text(kind.scientificName)
                            .font(Typography.body)
                            .italic()
                            .foregroundStyle(Palette.ink)
                        Text(kind.familyName)
                            .font(Typography.small)
                            .foregroundStyle(Palette.inkSoft)
                    }
                    GardenTreeView(kind: kind)
                        .frame(width: 190, height: 190)
                    PaperCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 9) {
                            Label("Estate Profile", systemImage: "map.fill")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            treeRow("Opens", "Level \(kind.unlockLevel)")
                            treeRow("Season", kind.season)
                            Divider()
                            Text(kind.gardenRole)
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(kind.careNote)
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    PaperCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Arboretum Notes", systemImage: "book.closed.fill")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            ForEach(Array(kind.journalEntries.enumerated()), id: \.offset) { index, entry in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1)")
                                        .font(Typography.small)
                                        .foregroundStyle(Palette.cream)
                                        .frame(width: 20, height: 20)
                                        .background(Circle().fill(Palette.moss))
                                    Text(entry)
                                        .font(Typography.caption)
                                        .foregroundStyle(Palette.inkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
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

    private func treeRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.inkSoft)
            Spacer()
            Text(value)
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.trailing)
        }
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
        PaperCard(cornerRadius: 9, padding: 5) {
            VStack(spacing: 3) {
                Text(kind.name)
                    .font(Typography.small)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(LinearGradient(colors: [Palette.leafLight.opacity(0.5), Palette.moss.opacity(0.35)], startPoint: .top, endPoint: .bottom))
                    if unlocked {
                        FlowerView(kind: kind, stage: .bloom, variant: model.progress.variant(for: kind))
                            .padding(4)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Palette.inkSoft)
                    }
                }
                .frame(height: 58)
                if unlocked {
                    VStack(spacing: 2) {
                        ProgressView(value: Double(min(blooms, nextThreshold ?? blooms)), total: Double(nextThreshold ?? max(blooms, 1)))
                            .tint(Palette.moss)
                        Text(nextThreshold.map { "\(blooms)/\($0)" } ?? "\(blooms) blooms")
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
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)
                    }
                } else {
                    Text(unlockNote)
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .frame(height: 34)
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
        case .daffodil: "sparkles"
        case .hydrangea: "circle.grid.3x3.fill"
        case .aster: "ant.fill"
        case .peony: "basket.fill"
        case .poppy: "wind"
        case .iris: "link"
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
                    VStack(spacing: 2) {
                        Text(kind.scientificName)
                            .font(Typography.body)
                            .italic()
                            .foregroundStyle(Palette.ink)
                        Text(kind.familyName)
                            .font(Typography.small)
                            .foregroundStyle(Palette.inkSoft)
                    }
                    FlowerView(kind: kind, stage: .bloom, variant: model.progress.variant(for: kind))
                        .frame(height: 150)
                    PaperCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("In Bud Relay", systemImage: "gamecontroller.fill")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            stat("Care cycles to bloom", "\(kind.growTurns)")
                            stat("Relay power", "\(kind.relayPower) care point\(kind.relayPower == 1 ? "" : "s")")
                            stat("Relay reach", kind == .hydrangea ? "8 surrounding plots" : "4 adjacent plots")
                            stat("Bloom stays", "\(kind.bloomStay) turn\(kind.bloomStay == 1 ? "" : "s")")
                            stat("Harvest", "\(kind.harvestYield) flower\(kind.harvestYield == 1 ? "" : "s")")
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
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Garden Profile", systemImage: "leaf.fill")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            stat("Main bloom season", kind.bloomSeason)
                            Divider()
                            profileRow("Home range", kind.nativeNote)
                            profileRow("Garden role", kind.gardenRole)
                            profileRow("Care note", kind.careNote)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    PaperCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Field Notes", systemImage: "book.closed.fill")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            ForEach(Array(kind.journalEntries.enumerated()), id: \.offset) { index, entry in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\(index + 1)")
                                        .font(Typography.small)
                                        .foregroundStyle(Palette.cream)
                                        .frame(width: 20, height: 20)
                                        .background(Circle().fill(Palette.moss))
                                    Text(entry)
                                        .font(Typography.caption)
                                        .foregroundStyle(Palette.inkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
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

    private func profileRow(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(Typography.small)
                .foregroundStyle(Palette.mossDark)
            Text(text)
                .font(Typography.caption)
                .foregroundStyle(Palette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
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
