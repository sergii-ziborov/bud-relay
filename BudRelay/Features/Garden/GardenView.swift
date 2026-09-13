import SwiftUI

struct GardenView: View {
    @Environment(AppModel.self) private var model
    @State private var category: DecorCategory? = nil
    @State private var selectedDecor: DecorID?
    @State private var selectedFlower: FlowerKind?
    @State private var inspectedRegion: GardenRegion?
    @State private var inspectedItem: GardenItemSelection?
    @State private var showGoals = false
    @State private var cameraScale: CGFloat = 1.28
    @State private var cameraOffset: CGSize = .zero
    @GestureState private var liveMagnification: CGFloat = 1
    @GestureState private var liveDrag: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                GardenCanvas(
                    garden: model.progress.garden,
                    variants: model.progress.variants,
                    playerLevel: model.progress.playerLevel,
                    placingDecor: selectedDecor,
                    placingFlower: selectedFlower,
                    selectedRegion: inspectedRegion,
                    onRegionTap: { selectRegion($0, in: proxy.size) },
                    onActivityTap: { model.collectGardenActivity($0) },
                    onTap: tap
                )
                .scaleEffect(displayedCameraScale)
                .offset(displayedCameraOffset)
                .simultaneousGesture(zoomGesture)
                .simultaneousGesture(panGesture(in: proxy.size))

                cameraControls(in: proxy.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 151)

                if let region = inspectedRegion, selectedDecor == nil, selectedFlower == nil {
                    regionInspector(region)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 215)
                        .transition(.opacity)
                }

                VStack(spacing: 7) {
                    HUDBar()
                    HStack(alignment: .top, spacing: 7) {
                        BackButton(action: model.goHome)
                        LogoView(subtitle: nil, scale: 0.48)
                        Spacer(minLength: 0)
                        goalsCard
                    }
                    Spacer(minLength: 0)
                    if selectedDecor != nil || selectedFlower != nil {
                        hint
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    inventory
                }
            }
            .onAppear {
                if cameraOffset == .zero {
                    cameraOffset = homeCameraOffset(in: proxy.size)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .contentColumn()
        .animation(.easeInOut(duration: 0.2), value: selectedDecor)
        .animation(.easeInOut(duration: 0.2), value: selectedFlower)
        .animation(.easeInOut(duration: 0.2), value: inspectedRegion)
        .sheet(isPresented: $showGoals) {
            GardenGoalsSheet()
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $inspectedItem) { item in
            GardenItemSheet(item: item)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var displayedCameraScale: CGFloat {
        min(2.15, max(1, cameraScale * liveMagnification))
    }

    private var displayedCameraOffset: CGSize {
        CGSize(width: cameraOffset.width + liveDrag.width, height: cameraOffset.height + liveDrag.height)
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($liveMagnification) { value, state, _ in
                state = value
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    cameraScale = min(2.15, max(1, cameraScale * value))
                }
            }
    }

    private func panGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .updating($liveDrag) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    let xLimit = size.width * 0.38 * cameraScale
                    let yLimit = size.height * 0.27 * cameraScale
                    cameraOffset = CGSize(
                        width: min(xLimit, max(-xLimit, cameraOffset.width + value.translation.width)),
                        height: min(yLimit, max(-yLimit, cameraOffset.height + value.translation.height))
                    )
                }
            }
    }

    private func homeCameraOffset(in size: CGSize) -> CGSize {
        CGSize(width: 0, height: -size.height * 0.18)
    }

    private func cameraControls(in size: CGSize) -> some View {
        HStack(spacing: 3) {
            cameraButton(symbol: "plus", identifier: "garden-zoom-in") {
                cameraScale = min(2.15, cameraScale + 0.22)
            }
            Text("\(Int(displayedCameraScale * 100))%")
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(Palette.ink)
                .monospacedDigit()
                .frame(width: 36, height: 17)
                .background(Capsule().fill(Palette.paper.opacity(0.92)))
            cameraButton(symbol: "minus", identifier: "garden-zoom-out") {
                cameraScale = max(1, cameraScale - 0.22)
            }
            cameraButton(symbol: "scope", identifier: "garden-camera-reset") {
                cameraScale = 1.28
                cameraOffset = homeCameraOffset(in: size)
                inspectedRegion = nil
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 13).fill(Palette.wood.opacity(0.92)))
        .overlay { RoundedRectangle(cornerRadius: 13).strokeBorder(Palette.cream.opacity(0.7), lineWidth: 1) }
        .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
    }

    private func cameraButton(symbol: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.30, dampingFraction: 0.78), action)
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Palette.woodDark)
                .frame(width: 34, height: 30)
                .background(RoundedRectangle(cornerRadius: 9).fill(Palette.paper))
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier(identifier)
    }

    private var goalsCard: some View {
        let goals = model.gardenGoals
        let done = goals.filter(\.done).count
        let next = goals.first { !$0.done }
        return Button {
            showGoals = true
        } label: {
            PaperCard(cornerRadius: 10, padding: 7) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "checklist")
                            .foregroundStyle(Palette.moss)
                        Text("Goals")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.ink)
                        Spacer(minLength: 2)
                        Text("\(done)/\(goals.count)")
                            .font(Typography.small)
                            .foregroundStyle(Palette.inkSoft)
                            .monospacedDigit()
                    }
                    ProgressView(value: Double(done), total: Double(goals.count))
                        .tint(Palette.moss)
                    Text(next?.goal.title ?? "Garden restored")
                        .font(Typography.small)
                        .foregroundStyle(next == nil ? Palette.mossDark : Palette.inkSoft)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("\(unlockedAreaCount)/\(GardenRegion.allCases.count) garden areas open")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.mossDark)
                }
                .frame(width: 116)
            }
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("garden-goals")
    }

    private var unlockedAreaCount: Int {
        GardenRegion.allCases.filter { $0.isUnlocked(playerLevel: model.progress.playerLevel) }.count
    }

    private var hint: some View {
        Text(hintText)
            .font(Typography.small)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background { Capsule().fill(Palette.paper.opacity(0.94)) }
            .overlay { Capsule().strokeBorder(Palette.woodDark.opacity(0.3), lineWidth: 1) }
    }

    private var hintText: String {
        if let decor = selectedDecor { return "Highlighted terrain fits the \(decor.name.lowercased())." }
        if let kind = selectedFlower { return "Choose a highlighted soil bed for \(kind.name.lowercased())." }
        return ""
    }

    private func regionInspector(_ region: GardenRegion) -> some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            let open = region.isUnlocked(playerLevel: model.progress.playerLevel)
            let stage = model.progress.garden.restorationStage(in: region, playerLevel: model.progress.playerLevel, at: timeline.date)
            let progress = model.progress.garden.restorationProgress(in: region, at: timeline.date)
            let remaining = model.progress.garden.remainingTendTime(in: region, at: timeline.date)
            PaperCard(cornerRadius: 13, padding: 9) {
                HStack(spacing: 9) {
                    Image(systemName: stage.symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(stage == .shrouded ? Palette.inkSoft : Palette.mossDark)
                        .frame(width: 30)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 5) {
                            Text(region.name)
                                .font(Typography.caption)
                                .foregroundStyle(Palette.ink)
                                .lineLimit(1)
                            Text(stage.name)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(Palette.mossDark)
                        }
                        ProgressView(value: open ? progress : 0)
                            .tint(Palette.moss)
                        Text(open ? region.tagline : "Hidden by clouds until Level \(region.requiredPlayerLevel)")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(Palette.inkSoft)
                            .lineLimit(1)
                    }
                    Button {
                        model.tendGardenRegion(region, at: timeline.date)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: open && remaining <= 0 ? "sparkles" : "clock.fill")
                            Text(!open ? "Lv \(region.requiredPlayerLevel)" : remaining <= 0 ? "Restore +2" : GardenClock.short(remaining))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 72, height: 43)
                        .background(RoundedRectangle(cornerRadius: 10).fill(open && remaining <= 0 ? Palette.moss : Palette.inkSoft))
                    }
                    .buttonStyle(PressStyle())
                    .disabled(!open || remaining > 0)
                    .accessibilityIdentifier("garden-tend-region")
                }
            }
        }
    }

    private var inventory: some View {
        VStack(spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    categoryTab(nil, title: "All", symbol: "square.grid.2x2.fill")
                    ForEach(DecorCategory.allCases) { cat in
                        categoryTab(cat, title: cat.name, symbol: cat.symbol)
                    }
                }
                .padding(.horizontal, 1)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { decor in
                        inventoryCard(decor)
                    }
                    ForEach(flowers, id: \.self) { kind in
                        flowerCard(kind)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 2)
            }
            .frame(height: 112)
        }
        .padding(7)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(colors: [Palette.woodLight.opacity(0.98), Palette.wood.opacity(0.98)], startPoint: .top, endPoint: .bottom))
                .overlay { WoodGrain().clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) }
                .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 2.5) }
                .shadow(color: .black.opacity(0.3), radius: 7, y: 4)
        }
    }

    private var items: [DecorID] {
        guard category != .flowers else { return [] }
        return DecorID.allCases
            .filter { category == nil || $0.category == category }
            .sorted {
                let lhsOwned = model.progress.garden.inventory[$0, default: 0] > 0
                let rhsOwned = model.progress.garden.inventory[$1, default: 0] > 0
                return lhsOwned != rhsOwned ? lhsOwned : $0.name < $1.name
            }
    }

    private var flowers: [FlowerKind] {
        guard category == nil || category == .flowers else { return [] }
        return FlowerKind.allCases.sorted {
            let lhsOwned = model.progress.flowers[$0, default: 0] > 0
            let rhsOwned = model.progress.flowers[$1, default: 0] > 0
            return lhsOwned != rhsOwned ? lhsOwned : $0.name < $1.name
        }
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
            .frame(width: 67)
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
        let owned = model.progress.garden.inventory[decor, default: 0]
        return Button {
            guard owned > 0 else { return }
            inspectedRegion = nil
            selectedFlower = nil
            selectedDecor = selectedDecor == decor ? nil : decor
        } label: {
            VStack(spacing: 4) {
                GardenScenePiece(decor: decor)
                    .frame(width: 50, height: 48)
                    .opacity(owned > 0 ? 1 : 0.55)
                Text(decor.name)
                    .font(Typography.small)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                inventoryAction(owned: owned, lockedText: unlockText(for: decor))
            }
            .frame(width: 104)
            .padding(.vertical, 5)
            .background(cardBackground(selected: selectedDecor == decor))
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("inventory-\(decor.rawValue)")
    }

    private func unlockText(for decor: DecorID) -> String {
        if let tree = decor.treeKind, !model.progress.isUnlocked(tree) {
            return "Level \(tree.unlockLevel)"
        }
        return decor.earnedAtLevel.map { "Level \($0)" } ?? "Market"
    }

    private func flowerCard(_ kind: FlowerKind) -> some View {
        let owned = model.progress.flowers[kind, default: 0]
        return Button {
            guard owned > 0 else { return }
            inspectedRegion = nil
            selectedDecor = nil
            selectedFlower = selectedFlower == kind ? nil : kind
        } label: {
            VStack(spacing: 4) {
                FlowerIcon(kind: kind, size: 48, variant: model.progress.variant(for: kind))
                    .opacity(owned > 0 ? 1 : 0.45)
                Text(kind.name)
                    .font(Typography.small)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                inventoryAction(owned: owned, lockedText: model.progress.isUnlocked(kind) ? "Earn in relays" : "Locked")
            }
            .frame(width: 104)
            .padding(.vertical, 5)
            .background(cardBackground(selected: selectedFlower == kind))
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("basket-\(kind.rawValue)")
    }

    private func inventoryAction(owned: Int, lockedText: String) -> some View {
        Text(owned > 0 ? "Place · ×\(owned)" : lockedText)
            .font(Typography.small)
            .foregroundStyle(owned > 0 ? .white : Palette.inkSoft)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(maxWidth: 90)
            .background(Capsule().fill(owned > 0 ? Palette.moss : Palette.paperDark))
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
        let region = GardenRegion.region(for: cell)
        if (selectedDecor != nil || selectedFlower != nil), !region.isOpen(cell, at: model.progress.playerLevel) {
            let capacity = region.capacity(at: model.progress.playerLevel)
            model.show(notice: region.isUnlocked(playerLevel: model.progress.playerLevel) ? "Keep growing to expand \(region.name) beyond \(capacity) sites" : "\(region.name) emerges from the fog at Level \(region.requiredPlayerLevel)")
            if model.progress.hapticsEnabled { Feedback.warn() }
            return
        }
        if let decor = selectedDecor {
            guard GardenPlacementRules.canPlace(decor, at: cell) else {
                model.show(notice: "That landscape does not suit the \(decor.name.lowercased())")
                if model.progress.hapticsEnabled { Feedback.warn() }
                return
            }
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
            guard GardenPlacementRules.canPlantFlower(at: cell) else {
                model.show(notice: "Flowers need one of the restored soil beds")
                if model.progress.hapticsEnabled { Feedback.warn() }
                return
            }
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
            inspectedRegion = region
            inspectedItem = .decor(placed)
            if model.progress.hapticsEnabled { Feedback.tap() }
        } else if let flower = garden.flower(at: cell) {
            inspectedRegion = region
            inspectedItem = .flower(flower)
            if model.progress.hapticsEnabled { Feedback.tap() }
        }
    }

    private func selectRegion(_ region: GardenRegion, in size: CGSize) {
        selectedDecor = nil
        selectedFlower = nil
        let shouldFocus = inspectedRegion != region
        withAnimation(.spring(response: 0.46, dampingFraction: 0.82)) {
            inspectedRegion = shouldFocus ? region : nil
            cameraScale = shouldFocus ? max(cameraScale, 1.60) : 1.28
            cameraOffset = shouldFocus ? focusOffset(for: region, in: size) : homeCameraOffset(in: size)
        }
        if model.progress.hapticsEnabled { Feedback.tap() }
    }

    private func focusOffset(for region: GardenRegion, in size: CGSize) -> CGSize {
        switch region {
        case .waterside: CGSize(width: size.width * 0.22, height: size.height * 0.14)
        case .greenhouseYard: CGSize(width: -size.width * 0.22, height: size.height * 0.14)
        case .meadow: CGSize(width: size.width * 0.21, height: 0)
        case .orchard: CGSize(width: -size.width * 0.21, height: 0)
        case .courtyard: CGSize(width: 0, height: -size.height * 0.15)
        }
    }
}

private enum GardenItemSelection: Identifiable {
    case decor(PlacedDecor)
    case flower(PlantedFlower)

    var id: UUID {
        switch self {
        case .decor(let item): item.id
        case .flower(let flower): flower.id
        }
    }
}

private struct GardenItemSheet: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let item: GardenItemSelection

    var body: some View {
        ZStack {
            Palette.cream.ignoresSafeArea()
            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                VStack(spacing: 14) {
                    switch item {
                    case .decor(let placed):
                        decorContent(placed, at: timeline.date)
                    case .flower(let flower):
                        flowerContent(flower, at: timeline.date)
                    }
                }
                .padding(20)
            }
        }
    }

    @ViewBuilder
    private func decorContent(_ placed: PlacedDecor, at date: Date) -> some View {
        let decor = placed.decor
        let region = GardenRegion.region(for: placed.cell)
        HStack(spacing: 16) {
            GardenScenePiece(decor: decor)
                .frame(width: 92, height: 92)
            VStack(alignment: .leading, spacing: 4) {
                Text(decor.name)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.ink)
                Label(region.name, systemImage: region.symbol)
                    .font(Typography.small)
                    .foregroundStyle(Palette.mossDark)
                Text(decor.blurb)
                    .font(Typography.caption)
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        PaperCard(cornerRadius: 12, padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.arrow.triangle.circlepath")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Palette.moss)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Restores this area while you are away")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.ink)
                    Text("+\(decor.restorationRate) restoration every 6 hours")
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer()
            }
        }

        if let production = decor.gardenProduction {
            let remaining = model.progress.garden.remainingCollectionTime(for: placed.id, cooldown: production.cooldown, at: date)
            Label(productionSummary(production), systemImage: production.reward.symbol)
                .font(Typography.caption)
                .foregroundStyle(Palette.mossDark)
            harvestButton(
                title: remaining <= 0 ? production.action : "Ready in \(GardenClock.short(remaining))",
                symbol: production.reward.symbol,
                enabled: remaining <= 0
            ) {
                model.collectGardenDecor(placed.id, at: date)
            }
        } else {
            Text("Paths connect the estate and steadily improve restoration.")
                .font(Typography.caption)
                .foregroundStyle(Palette.inkSoft)
        }

        putAwayButton(title: "Put Away") {
            model.pickUpDecor(placed.id)
            dismiss()
        }
    }

    @ViewBuilder
    private func flowerContent(_ flower: PlantedFlower, at date: Date) -> some View {
        let region = GardenRegion.region(for: flower.cell)
        let remaining = model.progress.garden.remainingCollectionTime(for: flower.id, cooldown: GardenState.flowerHarvestCooldown, at: date)
        HStack(spacing: 16) {
            FlowerIcon(kind: flower.kind, size: 92, variant: model.progress.variant(for: flower.kind))
            VStack(alignment: .leading, spacing: 4) {
                Text(flower.kind.name)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.ink)
                Label(region.name, systemImage: region.symbol)
                    .font(Typography.small)
                    .foregroundStyle(Palette.mossDark)
                Text("A living border that restores the area and grows harvestable blooms.")
                    .font(Typography.caption)
                    .foregroundStyle(Palette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        PaperCard(cornerRadius: 12, padding: 12) {
            HStack(spacing: 10) {
                Image(systemName: "camera.macro")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Palette.coral)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Produces one \(flower.kind.name.lowercased()) bloom")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.ink)
                    Text("Also restores the area every 12 hours")
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer()
            }
        }

        harvestButton(
            title: remaining <= 0 ? "Gather Bloom" : "Another bloom in \(GardenClock.short(remaining))",
            symbol: "camera.macro",
            enabled: remaining <= 0
        ) {
            model.collectGardenFlower(flower.id, at: date)
        }

        putAwayButton(title: "Uproot") {
            model.uprootFlower(flower.id)
            dismiss()
        }
    }

    private func harvestButton(title: String, symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(Typography.heading)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Capsule().fill(enabled ? Palette.moss : Palette.inkSoft))
        }
        .buttonStyle(PressStyle())
        .disabled(!enabled)
        .accessibilityIdentifier("garden-collect-item")
    }

    private func putAwayButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(Palette.woodDark)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
        }
        .buttonStyle(PressStyle())
        .accessibilityIdentifier("garden-put-away")
    }

    private func productionSummary(_ production: GardenProduction) -> String {
        let reward: String
        switch production.reward {
        case .coins: reward = "\(production.amount) coins"
        case .flower: reward = "\(production.amount) garden bloom"
        case .seed: reward = "\(production.amount) seed packet"
        case .tool(let tool): reward = "\(production.amount) \(tool.shortName.lowercased())"
        }
        return "+\(reward) every \(GardenClock.short(production.cooldown))"
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

/// A progressive estate made of authored terrain zones. The old cell IDs remain
/// persistence keys, but players see only real soil beds, lawns, paths, orchard
/// clearings, water edges, and service corners that belong to the illustration.
struct GardenCanvas: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let garden: GardenState
    var variants: [FlowerKind: Int] = [:]
    var playerLevel = 1
    var placingDecor: DecorID?
    var placingFlower: FlowerKind?
    var selectedRegion: GardenRegion?
    var onRegionTap: ((GardenRegion) -> Void)? = nil
    var onActivityTap: ((GardenActivityID) -> Void)? = nil
    var onTap: ((GardenCell) -> Void)? = nil

    private var isPlacing: Bool { placingDecor != nil || placingFlower != nil }

    var body: some View {
        GeometryReader { proxy in
            let base = min(proxy.size.width / 8.8, proxy.size.height / 10.2)
            ZStack {
                GardenTerrain(garden: garden, playerLevel: playerLevel)
                    .zIndex(0)
                ForEach(GardenRegion.allCases) { region in
                    regionAtmosphere(region, in: proxy.size)
                        .zIndex(region.restorationLayer)
                }
                ForEach(GardenRegion.allCases) { region in
                    regionInteraction(region, in: proxy.size)
                        .zIndex(15)
                }
                ForEach(GardenState.allCells, id: \.self) { cell in
                    if shouldRender(cell) {
                        sceneCell(cell, in: proxy.size, base: base)
                            .position(point(for: cell, in: proxy.size))
                            .zIndex(Double(20 + cell.row * 10 + cell.col))
                    }
                }
                if !isPlacing {
                    ForEach(GardenActivityID.allCases) { activity in
                        if activity.region.isUnlocked(playerLevel: playerLevel) {
                            activityMarker(activity, base: base)
                                .position(x: proxy.size.width * activity.x, y: proxy.size.height * activity.y)
                                .opacity(selectedRegion == nil || selectedRegion == activity.region ? 1 : 0.18)
                                .allowsHitTesting(selectedRegion == nil || selectedRegion == activity.region)
                                .zIndex(78)
                        }
                    }
                }
                life(in: proxy.size, base: base)
                    .zIndex(75)
                ForEach(GardenRegion.allCases) { region in
                    regionBadge(region)
                        .position(regionLabelPoint(region, in: proxy.size))
                        .opacity(selectedRegion == nil || selectedRegion == region ? 1 : 0)
                        .allowsHitTesting(selectedRegion == nil || selectedRegion == region)
                        .zIndex(90)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private func activityMarker(_ activity: GardenActivityID, base: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1 / 20, paused: reduceMotion)) { timeline in
            let remaining = garden.remainingActivityTime(for: activity, at: timeline.date)
            let ready = remaining <= 0
            let phase = timeline.date.timeIntervalSinceReferenceDate * 2.2 + Double(GardenActivityID.allCases.firstIndex(of: activity) ?? 0)
            let pulse = reduceMotion ? 0 : (sin(phase) + 1) / 2
            Button {
                onActivityTap?(activity)
            } label: {
                ZStack {
                    Ellipse()
                        .fill(Color.black.opacity(0.22))
                        .frame(width: base * 0.62, height: base * 0.16)
                        .offset(y: base * 0.25)
                    if ready {
                        RoundedRectangle(cornerRadius: base * 0.14)
                            .stroke(Palette.leafLight.opacity(0.42 - pulse * 0.18), lineWidth: 3)
                            .frame(width: base * (0.68 + pulse * 0.14), height: base * (0.58 + pulse * 0.14))
                    }
                    RoundedRectangle(cornerRadius: base * 0.13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: ready ? [Palette.paper, Palette.woodLight] : [Palette.paperDark, Palette.stone],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: base * 0.62, height: base * 0.52)
                        .overlay { RoundedRectangle(cornerRadius: base * 0.13).strokeBorder(Palette.woodDark.opacity(0.72), lineWidth: 1.5) }
                        .rotationEffect(.degrees(Double((GardenActivityID.allCases.firstIndex(of: activity) ?? 0) % 3) * 2 - 2))
                        .shadow(color: ready ? Palette.leaf.opacity(0.48) : .black.opacity(0.22), radius: ready ? 5 : 3, y: 2)
                    Image(systemName: ready ? activity.definition.symbol : "clock.fill")
                        .font(.system(size: base * 0.28, weight: .black))
                        .foregroundStyle(ready ? Palette.mossDark : Palette.inkSoft)
                        .contentTransition(.symbolEffect(.replace))
                    if ready {
                        Image(systemName: "plus")
                            .font(.system(size: base * 0.13, weight: .black))
                            .foregroundStyle(.white)
                            .frame(width: base * 0.27, height: base * 0.27)
                            .background(Circle().fill(Palette.moss))
                            .overlay { Circle().strokeBorder(Color.white, lineWidth: 1.2) }
                            .offset(x: base * 0.31, y: -base * 0.25)
                            .rotationEffect(.degrees(pulse * 12))
                    }
                }
                .frame(width: base * 1.08, height: base * 1.02)
                .offset(y: reduceMotion ? 0 : CGFloat(sin(phase)) * 1.2)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("garden-activity-\(activity.rawValue)")
            .accessibilityLabel(activity.definition.name)
            .accessibilityValue(ready ? "Ready" : "Ready in \(GardenClock.short(remaining))")
            .accessibilityHint(activity.definition.detail)
        }
    }

    private func shouldRender(_ cell: GardenCell) -> Bool {
        garden.decor(at: cell) != nil || garden.flower(at: cell) != nil || GardenRegion.region(for: cell).isOpen(cell, at: playerLevel)
    }

    @ViewBuilder
    private func sceneCell(_ cell: GardenCell, in size: CGSize, base: CGFloat) -> some View {
        let decor = garden.decor(at: cell)
        let flower = garden.flower(at: cell)
        let region = GardenRegion.region(for: cell)
        let open = region.isOpen(cell, at: playerLevel)
        let eligible = isEligible(cell)
        let point = point(for: cell, in: size)
        let depth = 0.70 + point.y / max(1, size.height) * 0.48
        Button {
            onTap?(cell)
        } label: {
            ZStack(alignment: .bottom) {
                if isPlacing, open, eligible, garden.isFree(cell) {
                    targetMarker(GardenPlacementRules.spotKind(at: cell), base: base, depth: depth)
                        .transition(.scale.combined(with: .opacity))
                }
                if let decor {
                    placedDecor(decor.decor, base: base, depth: depth)
                    if !isPlacing {
                        collectionMarker(for: decor, base: base, depth: depth)
                    }
                } else if let flower {
                    placedFlower(flower.kind, base: base, depth: depth)
                    if !isPlacing {
                        collectionMarker(for: flower, base: base, depth: depth)
                    }
                }
            }
            // Keep touch zones local to their anchors. Oversized invisible
            // frames made neighbouring props select one another when zoomed.
            .frame(width: base * 1.10, height: base * 1.18)
            .contentShape(Ellipse())
        }
        .buttonStyle(.plain)
        .disabled(decor == nil && flower == nil && (!isPlacing || !open || !eligible))
        .allowsHitTesting(decor != nil || flower != nil || isPlacing)
        .accessibilityIdentifier("garden-\(cell.row)-\(cell.col)")
        .accessibilityLabel(cellLabel(cell: cell, decor: decor?.decor, flower: flower?.kind, open: open))
    }

    @ViewBuilder
    private func collectionMarker(for item: PlacedDecor, base: CGFloat, depth: CGFloat) -> some View {
        if let production = item.decor.gardenProduction {
            TimelineView(.periodic(from: .now, by: 30)) { timeline in
                if garden.canCollect(from: item.id, cooldown: production.cooldown, at: timeline.date) {
                    readyBadge(symbol: production.reward.symbol, base: base, depth: depth)
                }
            }
        }
    }

    @ViewBuilder
    private func collectionMarker(for flower: PlantedFlower, base: CGFloat, depth: CGFloat) -> some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            if garden.canCollect(from: flower.id, cooldown: GardenState.flowerHarvestCooldown, at: timeline.date) {
                readyBadge(symbol: "camera.macro", base: base, depth: depth)
            }
        }
    }

    private func readyBadge(symbol: String, base: CGFloat, depth: CGFloat) -> some View {
        Image(systemName: symbol)
            .font(.system(size: base * 0.21, weight: .black))
            .foregroundStyle(.white)
            .frame(width: base * 0.48, height: base * 0.48)
            .background(Circle().fill(Palette.moss))
            .overlay { Circle().strokeBorder(Color.white, lineWidth: 2) }
            .shadow(color: Palette.leaf.opacity(0.9), radius: 7)
            .offset(x: base * 0.48 * depth, y: -base * 0.60 * depth)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func targetMarker(_ kind: GardenSpotKind, base: CGFloat, depth: CGFloat) -> some View {
        let width = base * (kind == .path ? 0.82 : 1.22) * depth
        let height = base * (kind == .flowerBed ? 0.50 : 0.42) * depth
        ZStack {
            switch kind {
            case .flowerBed:
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Palette.soil.opacity(0.78))
                    .overlay { RoundedRectangle(cornerRadius: 5).strokeBorder(Palette.cream, style: StrokeStyle(lineWidth: 2, dash: [5, 3])) }
            case .path:
                Ellipse()
                    .fill(Color.white.opacity(0.38))
                    .overlay { Ellipse().strokeBorder(Palette.cream, style: StrokeStyle(lineWidth: 2, dash: [5, 3])) }
            case .waterside:
                Ellipse()
                    .fill(Palette.water.opacity(0.38))
                    .overlay { Ellipse().strokeBorder(Color.white.opacity(0.92), style: StrokeStyle(lineWidth: 2, dash: [5, 3])) }
            case .orchard, .lawn, .service:
                Ellipse()
                    .fill(Palette.leafLight.opacity(0.30))
                    .overlay { Ellipse().strokeBorder(Palette.cream, style: StrokeStyle(lineWidth: 2, dash: [5, 3])) }
            }
            Image(systemName: markerSymbol(for: kind))
                .font(.system(size: base * 0.25, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.95))
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(kind == .flowerBed ? -4 : 0))
        .shadow(color: Palette.mossDark.opacity(0.45), radius: 5, y: 2)
        .allowsHitTesting(false)
    }

    private func markerSymbol(for kind: GardenSpotKind) -> String {
        switch kind {
        case .flowerBed: "camera.macro"
        case .lawn: "leaf.fill"
        case .orchard: "tree.fill"
        case .path: "circle.grid.2x2.fill"
        case .waterside: "water.waves"
        case .service: "wrench.and.screwdriver.fill"
        }
    }

    @ViewBuilder
    private func placedFlower(_ kind: FlowerKind, base: CGFloat, depth: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1 / 18, paused: reduceMotion)) { timeline in
            let kindSeed = Double(FlowerKind.allCases.firstIndex(of: kind) ?? 0)
            let sway = reduceMotion ? 0 : sin(timeline.date.timeIntervalSinceReferenceDate * 1.15 + kindSeed) * 1.8
            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(Color.black.opacity(0.22))
                    .frame(width: base * 0.92 * depth, height: base * 0.18 * depth)
                HStack(alignment: .bottom, spacing: -base * 0.20) {
                    FlowerView(kind: kind, stage: .bloom, variant: (variants[kind, default: 0] + 1) % 4)
                        .frame(width: base * 0.54 * depth, height: base * 0.68 * depth)
                        .rotationEffect(.degrees(-7))
                    FlowerView(kind: kind, stage: .bloom, variant: variants[kind, default: 0])
                        .frame(width: base * 0.68 * depth, height: base * 0.82 * depth)
                        .zIndex(1)
                    FlowerView(kind: kind, stage: .bloom, variant: (variants[kind, default: 0] + 2) % 4)
                        .frame(width: base * 0.50 * depth, height: base * 0.62 * depth)
                        .rotationEffect(.degrees(8))
                }
                .offset(y: -base * 0.03)
                .rotationEffect(.degrees(sway), anchor: .bottom)
                .shadow(color: .black.opacity(0.24), radius: 2, y: 3)
            }
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func placedDecor(_ decor: DecorID, base: CGFloat, depth: CGFloat) -> some View {
        let tree = decor.treeKind != nil
        let pond = decor == .pond
        let tall = decor == .lantern || decor == .birdhouse || decor == .beeHotel
        let wide = decor == .communityBench || decor == .planterBox || decor == .pergola
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(tree ? 0.20 : 0.16))
                .frame(width: base * (tree ? 1.10 : (wide ? 0.96 : 0.64)) * depth, height: base * 0.20 * depth)
            GardenScenePiece(decor: decor)
                .frame(
                    width: base * (tree ? 1.48 : (pond ? 1.42 : (wide ? 1.30 : (tall ? 0.94 : 1.02)))) * depth,
                    height: base * (tree ? 1.72 : (pond ? 0.76 : (tall ? 1.42 : 1.02))) * depth
                )
                .offset(y: tree ? -base * 0.07 : 0)
        }
        .allowsHitTesting(false)
    }

    private func isEligible(_ cell: GardenCell) -> Bool {
        if let placingDecor { return GardenPlacementRules.canPlace(placingDecor, at: cell) }
        if placingFlower != nil { return GardenPlacementRules.canPlantFlower(at: cell) }
        return false
    }

    private func point(for cell: GardenCell, in size: CGSize) -> CGPoint {
        GardenMapLayout.point(for: cell, in: size)
    }

    private func regionLabelPoint(_ region: GardenRegion, in size: CGSize) -> CGPoint {
        let normalized: CGPoint
        switch region {
        case .waterside: normalized = CGPoint(x: 0.28, y: 0.10)
        case .greenhouseYard: normalized = CGPoint(x: 0.72, y: 0.18)
        case .meadow: normalized = CGPoint(x: 0.25, y: 0.47)
        case .orchard: normalized = CGPoint(x: 0.75, y: 0.47)
        case .courtyard: normalized = CGPoint(x: 0.50, y: 0.63)
        }
        return CGPoint(x: size.width * normalized.x, y: size.height * normalized.y)
    }

    private func regionBadge(_ region: GardenRegion) -> some View {
        let stage = garden.restorationStage(in: region, playerLevel: playerLevel)
        let capacity = region.capacity(at: playerLevel)
        return Button {
            onRegionTap?(region)
        } label: {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: stage.symbol)
                    Text(shortRegionName(region))
                        .lineLimit(1)
                }
                Text(stage == .shrouded ? "Fog · Level \(region.requiredPlayerLevel)" : "\(stage.name) · \(capacity)/\(region.cells.count) sites")
                    .font(.system(size: 7, weight: .semibold, design: .rounded))
                    .opacity(0.92)
            }
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(stage == .shrouded || stage == .neglected ? Palette.cream : Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Capsule().fill(badgeColor(for: stage).opacity(0.92)))
            .overlay { Capsule().strokeBorder(selectedRegion == region ? Palette.leafLight : Color.white.opacity(0.52), lineWidth: selectedRegion == region ? 2.5 : 1) }
            .shadow(color: selectedRegion == region ? Palette.leaf.opacity(0.75) : .black.opacity(0.28), radius: selectedRegion == region ? 8 : 3, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("garden-region-\(region.rawValue)")
        .accessibilityLabel(region.name)
    }

    private func shortRegionName(_ region: GardenRegion) -> String {
        switch region {
        case .courtyard: "Courtyard"
        case .meadow: "Meadow"
        case .orchard: "Orchard"
        case .waterside: "Pond Garden"
        case .greenhouseYard: "Greenhouse"
        }
    }

    private func regionInteraction(_ region: GardenRegion, in size: CGSize) -> some View {
        ZStack {
            GardenRegionShape(region: region)
                .fill(Color.white.opacity(0.001))
            if selectedRegion == region {
                TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1 / 20, paused: reduceMotion)) { timeline in
                    let phase = reduceMotion ? 0.5 : (sin(timeline.date.timeIntervalSinceReferenceDate * 2.1) + 1) / 2
                    GardenRegionShape(region: region)
                        .fill(Palette.leafLight.opacity(0.06 + phase * 0.045))
                    GardenRegionShape(region: region)
                        .stroke(Palette.leaf.opacity(0.34 + phase * 0.16), lineWidth: 13)
                        .blur(radius: 11 + phase * 3)
                }
            } else if selectedRegion != nil {
                GardenRegionShape(region: region)
                    .fill(Color.black.opacity(0.08))
                    .blur(radius: 3)
            }
        }
        .frame(width: size.width, height: size.height)
        .contentShape(GardenRegionShape(region: region))
        .onTapGesture { onRegionTap?(region) }
        .allowsHitTesting(selectedRegion == nil)
        .accessibilityHidden(true)
    }

    private func badgeColor(for stage: GardenRestorationStage) -> Color {
        switch stage {
        case .shrouded: Color(red: 0.29, green: 0.31, blue: 0.30)
        case .neglected: Color(red: 0.40, green: 0.31, blue: 0.20)
        case .recovering: Palette.woodDark
        case .thriving: Palette.mossDark
        }
    }

    @ViewBuilder
    private func regionAtmosphere(_ region: GardenRegion, in size: CGSize) -> some View {
        let stage = garden.restorationStage(in: region, playerLevel: playerLevel)
        let progress = garden.restorationProgress(in: region)
        ZStack {
            switch stage {
            case .shrouded:
                LinearGradient(colors: [Color.white.opacity(0.26), Color(red: 0.30, green: 0.37, blue: 0.34).opacity(0.32)], startPoint: .top, endPoint: .bottom)
                    .mask(softRegionMask(region, blur: 22))
                Color(red: 0.18, green: 0.23, blue: 0.22).opacity(0.13)
                    .mask(softRegionMask(region, blur: 18))
                FogTexture(region: region)
                    .mask(softRegionMask(region, blur: 24))
            case .neglected:
                Color(red: 0.25, green: 0.20, blue: 0.14).opacity(0.38)
                    .mask(softRegionMask(region, blur: 7))
                NeglectTexture(region: region, density: 1)
                    .mask(softRegionMask(region, blur: 6))
            case .recovering:
                Color(red: 0.30, green: 0.24, blue: 0.15).opacity(max(0.08, 0.24 - progress * 0.20))
                    .mask(softRegionMask(region, blur: 5))
                NeglectTexture(region: region, density: 0.42)
                    .mask(softRegionMask(region, blur: 5))
            case .thriving:
                GardenRegionShape(region: region)
                    .fill(Palette.leafLight.opacity(0.035))
            }
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
    }

    private func softRegionMask(_ region: GardenRegion, blur: CGFloat) -> some View {
        GardenRegionShape(region: region)
            .fill(Color.white)
            .blur(radius: blur)
    }

    private func cellLabel(cell: GardenCell, decor: DecorID?, flower: FlowerKind?, open: Bool) -> String {
        if let decor { return decor.name }
        if let flower { return flower.name }
        if !open { return "Future expansion" }
        return "Open \(GardenPlacementRules.spotKind(at: cell).rawValue) site"
    }

    /// Neighbours, bees, and birds make restored areas feel inhabited.
    @ViewBuilder
    private func life(in size: CGSize, base: CGFloat) -> some View {
        if garden.hasBees {
            TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                ForEach(0..<3, id: \.self) { index in
                    let anchor = point(for: beeAnchor(index), in: size)
                    BeeView()
                        .frame(width: base * 0.30, height: base * 0.22)
                        .position(
                            x: anchor.x + CGFloat(sin(time * 1.4 + Double(index) * 2)) * base * 0.7,
                            y: anchor.y - base * 0.5 + CGFloat(cos(time * 2.1 + Double(index))) * base * 0.35
                        )
                }
            }
            .allowsHitTesting(false)
        }
        if garden.hasBirds, let bath = garden.decor.first(where: { $0.decor == .birdbath || $0.decor == .birdhouse }) {
            let anchor = point(for: bath.cell, in: size)
            Image(systemName: "bird.fill")
                .font(.system(size: base * 0.34, weight: .bold))
                .foregroundStyle(Palette.woodDark)
                .shadow(color: .white.opacity(0.5), radius: 1)
                .position(x: anchor.x + base * 0.32, y: anchor.y - base * 0.48)
                .allowsHitTesting(false)
        }
        if garden.restorationStage(in: .meadow, playerLevel: playerLevel) == .thriving {
            TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1 / 20, paused: reduceMotion)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                ForEach(0..<3, id: \.self) { index in
                    let anchor = CGPoint(x: size.width * (0.16 + CGFloat(index) * 0.11),
                                         y: size.height * (0.43 + CGFloat(index % 2) * 0.08))
                    Image(systemName: "butterfly.fill")
                        .font(.system(size: base * 0.29, weight: .regular))
                        .foregroundStyle(index == 1 ? Palette.sun : Palette.blush)
                        .shadow(color: Palette.woodDark.opacity(0.45), radius: 2, y: 2)
                        .scaleEffect(x: reduceMotion ? 1 : 0.78 + 0.22 * abs(sin(time * 7 + Double(index))), y: 1)
                        .position(x: anchor.x + CGFloat(sin(time * 0.8 + Double(index) * 2)) * base * 0.5,
                                  y: anchor.y + CGFloat(cos(time * 1.3 + Double(index))) * base * 0.34)
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func beeAnchor(_ index: Int) -> GardenCell {
        let targets = garden.flowers.filter { $0.kind == .lavender }.map(\.cell) + garden.decor.filter { $0.decor == .beeHotel }.map(\.cell)
        guard !targets.isEmpty else { return GardenCell(4, 1) }
        return targets[index % targets.count]
    }
}

private enum GardenMapLayout {
    static func point(for cell: GardenCell, in size: CGSize) -> CGPoint {
        let region = GardenRegion.region(for: cell)
        let normalized: CGPoint
        switch region {
        case .waterside:
            normalized = CGPoint(x: [0.10, 0.24, 0.38][cell.col], y: [0.11, 0.20, 0.28][cell.row])
        case .greenhouseYard:
            normalized = CGPoint(x: [0.62, 0.76, 0.90][cell.col - 3], y: [0.09, 0.17, 0.25][cell.row])
        case .meadow:
            normalized = CGPoint(x: [0.11, 0.25, 0.39][cell.col], y: cell.row == 3 ? 0.40 : 0.51)
        case .orchard:
            normalized = CGPoint(x: [0.61, 0.75, 0.89][cell.col - 3], y: cell.row == 3 ? 0.40 : 0.51)
        case .courtyard:
            let authored: [GardenCell: CGPoint] = [
                GardenCell(5, 0): CGPoint(x: 0.50, y: 0.69),
                GardenCell(5, 1): CGPoint(x: 0.20, y: 0.72),
                GardenCell(5, 2): CGPoint(x: 0.37, y: 0.72),
                GardenCell(5, 3): CGPoint(x: 0.63, y: 0.72),
                GardenCell(5, 4): CGPoint(x: 0.80, y: 0.72),
                GardenCell(5, 5): CGPoint(x: 0.50, y: 0.79),
                GardenCell(6, 0): CGPoint(x: 0.10, y: 0.87),
                GardenCell(6, 1): CGPoint(x: 0.22, y: 0.86),
                GardenCell(6, 2): CGPoint(x: 0.37, y: 0.86),
                GardenCell(6, 3): CGPoint(x: 0.63, y: 0.86),
                GardenCell(6, 4): CGPoint(x: 0.78, y: 0.86),
                GardenCell(6, 5): CGPoint(x: 0.90, y: 0.87),
            ]
            normalized = authored[cell, default: CGPoint(x: 0.50, y: 0.79)]
        }
        return CGPoint(x: size.width * normalized.x, y: size.height * normalized.y)
    }
}

/// All map art is drawn in the same local coordinates as the placed pieces.
/// Consequently a camera pan or zoom can never separate the scenery from its
/// flowers, soil beds, paths, activities, or unlock masks.
private struct GardenTerrain: View {
    let garden: GardenState
    let playerLevel: Int

    private let grass = Color(red: 0.36, green: 0.57, blue: 0.29)
    private let grassLight = Color(red: 0.50, green: 0.69, blue: 0.37)
    private let grassDark = Color(red: 0.24, green: 0.43, blue: 0.23)
    private let pathLight = Color(red: 0.90, green: 0.80, blue: 0.59)
    private let pathDark = Color(red: 0.54, green: 0.43, blue: 0.29)
    private let soil = Color(red: 0.38, green: 0.25, blue: 0.16)
    private let water = Color(red: 0.22, green: 0.55, blue: 0.63)

    var body: some View {
        Canvas(opaque: true) { context, size in
            drawGround(context, in: size)
            drawWater(context, in: size)
            drawPaths(context, in: size)
            drawBuiltLandscape(context, in: size)
            drawGroundTexture(context, in: size)
            for cell in GardenState.allCells {
                if GardenRegion.region(for: cell).isOpen(cell, at: playerLevel)
                    || garden.decor(at: cell) != nil || garden.flower(at: cell) != nil {
                    drawSite(cell, context: context, in: size)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func p(_ x: CGFloat, _ y: CGFloat, _ size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }

    private func ellipse(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, in size: CGSize) -> Path {
        Path(ellipseIn: CGRect(x: (x - width / 2) * size.width, y: (y - height / 2) * size.height,
                            width: width * size.width, height: height * size.height))
    }

    private func drawGround(_ context: GraphicsContext, in size: CGSize) {
        let full = Path(CGRect(origin: .zero, size: size))
        context.fill(full, with: .linearGradient(
            Gradient(colors: [Color(red: 0.52, green: 0.71, blue: 0.41), grass, grassDark]),
            startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)
        ))
        // Large overlapping tonal islands, not a tiled checkerboard.
        context.fill(ellipse(0.23, 0.47, 0.57, 0.55, in: size), with: .color(grassLight.opacity(0.37)))
        context.fill(ellipse(0.80, 0.47, 0.51, 0.46, in: size), with: .color(Color(red: 0.46, green: 0.60, blue: 0.29).opacity(0.55)))
        context.fill(ellipse(0.52, 0.87, 0.96, 0.53, in: size), with: .color(Color(red: 0.50, green: 0.67, blue: 0.35).opacity(0.38)))
        context.fill(ellipse(0.76, 0.14, 0.53, 0.36, in: size), with: .color(Color(red: 0.70, green: 0.67, blue: 0.41).opacity(0.34)))
    }

    private func drawWater(_ context: GraphicsContext, in size: CGSize) {
        var bank = Path()
        bank.move(to: p(-0.05, -0.04, size))
        bank.addLine(to: p(0.35, -0.04, size))
        bank.addCurve(to: p(0.42, 0.12, size), control1: p(0.41, 0.00, size), control2: p(0.47, 0.06, size))
        bank.addCurve(to: p(0.32, 0.31, size), control1: p(0.37, 0.19, size), control2: p(0.43, 0.27, size))
        bank.addCurve(to: p(-0.05, 0.35, size), control1: p(0.20, 0.34, size), control2: p(0.06, 0.30, size))
        bank.closeSubpath()
        context.fill(bank, with: .color(Color(red: 0.67, green: 0.65, blue: 0.41)))
        context.stroke(bank, with: .color(grassDark.opacity(0.55)), lineWidth: 6)

        var pond = Path()
        pond.move(to: p(-0.05, -0.04, size))
        pond.addLine(to: p(0.31, -0.04, size))
        pond.addCurve(to: p(0.39, 0.12, size), control1: p(0.40, 0.01, size), control2: p(0.43, 0.06, size))
        pond.addCurve(to: p(0.29, 0.28, size), control1: p(0.35, 0.19, size), control2: p(0.39, 0.25, size))
        pond.addCurve(to: p(-0.05, 0.31, size), control1: p(0.19, 0.30, size), control2: p(0.05, 0.27, size))
        pond.closeSubpath()
        context.fill(pond, with: .linearGradient(
            Gradient(colors: [Color(red: 0.39, green: 0.71, blue: 0.74), water, Color(red: 0.15, green: 0.42, blue: 0.48)]),
            startPoint: p(0.20, 0, size), endPoint: p(0.09, 0.31, size)
        ))
        context.stroke(pond, with: .color(Color(red: 0.87, green: 0.80, blue: 0.57)), lineWidth: 5)
        for index in 0..<24 {
            let x = CGFloat((index * 47 + 9) % 35) / 100
            let y = CGFloat((index * 29 + 5) % 25) / 100
            let length = CGFloat(8 + index % 4 * 5)
            var ripple = Path()
            ripple.move(to: p(x, y, size))
            ripple.addQuadCurve(to: CGPoint(x: x * size.width + length, y: y * size.height),
                                control: CGPoint(x: x * size.width + length / 2, y: y * size.height - 3))
            context.stroke(ripple, with: .color(.white.opacity(index % 3 == 0 ? 0.46 : 0.22)), lineWidth: 1.2)
        }
        for index in 0..<11 {
            let x = CGFloat((index * 31 + 8) % 36) / 100
            let y = 0.27 + CGFloat(index % 3) * 0.014
            let start = p(x, y, size)
            var reed = Path()
            reed.move(to: start)
            reed.addQuadCurve(to: CGPoint(x: start.x + CGFloat(index % 3 - 1) * 6, y: start.y - 15),
                              control: CGPoint(x: start.x + 4, y: start.y - 9))
            context.stroke(reed, with: .color(grassDark), lineWidth: 2)
        }
    }

    private func drawPaths(_ context: GraphicsContext, in size: CGSize) {
        let width = max(25, size.width * 0.115)
        var spine = Path()
        spine.move(to: p(0.48, -0.05, size))
        spine.addCurve(to: p(0.50, 0.34, size), control1: p(0.53, 0.09, size), control2: p(0.45, 0.23, size))
        spine.addCurve(to: p(0.49, 0.68, size), control1: p(0.56, 0.48, size), control2: p(0.44, 0.55, size))
        spine.addCurve(to: p(0.49, 1.05, size), control1: p(0.55, 0.83, size), control2: p(0.45, 0.94, size))
        strokePath(spine, context: context, width: width)

        for coords in [
            [CGPoint(x: 0.49, y: 0.36), CGPoint(x: 0.29, y: 0.37), CGPoint(x: 0.08, y: 0.44)],
            [CGPoint(x: 0.50, y: 0.40), CGPoint(x: 0.71, y: 0.43), CGPoint(x: 1.02, y: 0.52)],
            [CGPoint(x: 0.49, y: 0.68), CGPoint(x: 0.27, y: 0.69), CGPoint(x: -0.04, y: 0.80)],
            [CGPoint(x: 0.50, y: 0.69), CGPoint(x: 0.73, y: 0.72), CGPoint(x: 1.04, y: 0.81)],
        ] {
            var branch = Path()
            branch.move(to: p(coords[0].x, coords[0].y, size))
            branch.addQuadCurve(to: p(coords[2].x, coords[2].y, size), control: p(coords[1].x, coords[1].y, size))
            strokePath(branch, context: context, width: width * 0.55)
        }
        // The courtyard is built into the path network instead of floating on it.
        context.fill(ellipse(0.50, 0.79, 0.31, 0.18, in: size), with: .color(pathDark.opacity(0.45)))
        context.fill(ellipse(0.50, 0.78, 0.28, 0.16, in: size), with: .color(pathLight))
        context.stroke(ellipse(0.50, 0.78, 0.27, 0.15, in: size), with: .color(Color.white.opacity(0.38)), lineWidth: 2)
        for index in 0..<38 {
            let y = CGFloat(index) / 38
            let x = 0.49 + 0.026 * sin(y * 15)
            let step = ellipse(x + CGFloat(index % 3 - 1) * 0.023, y, 0.027, 0.011, in: size)
            context.fill(step, with: .color((index % 4 == 0 ? .white : pathDark).opacity(0.20)))
        }
    }

    private func strokePath(_ path: Path, context: GraphicsContext, width: CGFloat) {
        context.stroke(path, with: .color(grassDark.opacity(0.40)), style: StrokeStyle(lineWidth: width + 13, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(pathDark), style: StrokeStyle(lineWidth: width + 5, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(pathLight), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(Color.white.opacity(0.28)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    private func drawBuiltLandscape(_ context: GraphicsContext, in size: CGSize) {
        // Greenhouse glazing, brick apron, and raised cold frames are part of the world.
        let apron = CGRect(x: size.width * 0.55, y: -size.height * 0.03, width: size.width * 0.47, height: size.height * 0.34)
        context.fill(Path(roundedRect: apron, cornerRadius: 16), with: .color(Color(red: 0.65, green: 0.58, blue: 0.43).opacity(0.62)))
        let house = CGRect(x: size.width * 0.64, y: -size.height * 0.15, width: size.width * 0.42, height: size.height * 0.24)
        context.fill(Path(roundedRect: house, cornerRadius: 7), with: .color(Color(red: 0.70, green: 0.86, blue: 0.80).opacity(0.72)))
        context.stroke(Path(roundedRect: house, cornerRadius: 7), with: .color(Color(red: 0.93, green: 0.91, blue: 0.75)), lineWidth: 6)
        for index in 0..<5 {
            let x = size.width * (0.65 + CGFloat(index) * 0.098)
            var bar = Path()
            bar.move(to: CGPoint(x: x, y: 0))
            bar.addLine(to: CGPoint(x: x, y: size.height * 0.08))
            context.stroke(bar, with: .color(.white.opacity(0.62)), lineWidth: 2)
        }
        // A hedge and fruit-tree canopy frame the orchard, leaving its buildable
        // grass clearings open. Everything is behind the interactive pieces.
        for (x, y, scale) in [(0.88, 0.34, 0.13), (1.01, 0.42, 0.17), (0.92, 0.59, 0.11), (0.06, 0.62, 0.12), (-0.02, 0.44, 0.13)] {
            drawShrub(x: x, y: y, scale: scale, context: context, size: size)
        }
        let meadowFull = garden.restorationStage(in: .meadow, playerLevel: playerLevel) == .thriving
        let courtyardFull = garden.restorationStage(in: .courtyard, playerLevel: playerLevel) == .thriving
        for (x, y, density) in [
            (0.05, 0.36, 8), (0.32, 0.32, 9), (0.06, 0.55, 12), (0.29, 0.59, 10),
            (0.86, 0.33, 8), (0.96, 0.54, 10), (0.69, 0.57, 8),
            (0.08, 0.67, 10), (0.91, 0.67, 10), (0.06, 0.94, 10), (0.91, 0.94, 11),
        ] {
            let lively = y < 0.62 ? meadowFull : courtyardFull
            drawFlowerBorder(x: x, y: y, count: lively ? density : max(3, density / 3), context: context, size: size)
        }
        for index in 0..<9 {
            let x = CGFloat(index) / 8
            let top = ellipse(x, 0.015, 0.16, 0.10, in: size)
            context.fill(top, with: .color(grassDark.opacity(0.48)))
        }
        // Timber border of the community beds.
        for (x0, y0, x1, y1) in [(-0.05, 0.61, 0.31, 0.61), (0.71, 0.61, 1.05, 0.61),
                                  (-0.05, 0.97, 0.33, 0.97), (0.67, 0.97, 1.05, 0.97)] {
            var fence = Path()
            fence.move(to: p(x0, y0, size))
            fence.addLine(to: p(x1, y1, size))
            context.stroke(fence, with: .color(pathDark.opacity(0.75)), lineWidth: 4)
            context.stroke(fence, with: .color(pathLight.opacity(0.8)), lineWidth: 1.4)
        }
    }

    private func drawShrub(x: CGFloat, y: CGFloat, scale: CGFloat, context: GraphicsContext, size: CGSize) {
        context.fill(ellipse(x, y + 0.014, scale * 1.3, scale * 0.35, in: size), with: .color(.black.opacity(0.19)))
        for index in 0..<5 {
            let ox = CGFloat(index - 2) * scale * 0.16
            let oy = CGFloat(index % 2) * scale * 0.055
            context.fill(ellipse(x + ox, y - oy, scale * 0.38, scale * 0.26, in: size),
                         with: .color(index.isMultiple(of: 2) ? grassDark : grassLight))
        }
    }

    private func drawFlowerBorder(x: CGFloat, y: CGFloat, count: Int, context: GraphicsContext, size: CGSize) {
        context.fill(ellipse(x, y + 0.012, 0.14, 0.065, in: size), with: .color(grassDark.opacity(0.70)))
        for index in 0..<count {
            let dx = CGFloat((index * 47 + 13) % 100) / 100 * 0.12 - 0.06
            let dy = CGFloat((index * 29 + 7) % 100) / 100 * 0.05 - 0.025
            let cx = x + dx
            let cy = y + dy
            let tint: Color = switch index % 5 {
            case 0: Color.white
            case 1: Palette.blush
            case 2: Palette.sun
            case 3: Palette.lavender
            default: Palette.cream
            }
            let center = p(cx, cy, size)
            for petal in 0..<5 {
                let angle = Double(petal) * .pi * 2 / 5
                let px = center.x + cos(angle) * 3.1
                let py = center.y + sin(angle) * 3.1
                context.fill(Path(ellipseIn: CGRect(x: px - 2.3, y: py - 2.3, width: 4.6, height: 4.6)),
                             with: .color(tint.opacity(0.9)))
            }
            context.fill(Path(ellipseIn: CGRect(x: center.x - 1.8, y: center.y - 1.8, width: 3.6, height: 3.6)),
                         with: .color(Palette.gold))
        }
    }

    private func drawGroundTexture(_ context: GraphicsContext, in size: CGSize) {
        for index in 0..<520 {
            let x = CGFloat((index * 137 + index * index * 17 + 19) % 1000) / 1000
            let y = CGFloat((index * 239 + index * index * 7 + 41) % 1000) / 1000
            if x > 0.43 && x < 0.57 && index % 4 != 0 { continue }
            let center = p(x, y, size)
            if index % 8 == 0 {
                let color: Color = [Color.white, Color(red: 1, green: 0.82, blue: 0.41),
                                    Color(red: 0.96, green: 0.58, blue: 0.65), Color(red: 0.76, green: 0.70, blue: 0.96)][index % 4]
                context.fill(Path(ellipseIn: CGRect(x: center.x - 2.2, y: center.y - 1.6, width: 4.4, height: 3.2)), with: .color(color.opacity(0.85)))
            } else {
                var tuft = Path()
                tuft.move(to: center)
                tuft.addLine(to: CGPoint(x: center.x + CGFloat(index % 3 - 1) * 2, y: center.y - CGFloat(2 + index % 4)))
                context.stroke(tuft, with: .color((index % 3 == 0 ? grassDark : grassLight).opacity(0.53)), lineWidth: 1)
            }
        }
    }

    private func drawSite(_ cell: GardenCell, context: GraphicsContext, in size: CGSize) {
        let center = GardenMapLayout.point(for: cell, in: size)
        let unit = min(size.width / 8.8, size.height / 10.2)
        let depth = 0.70 + center.y / max(1, size.height) * 0.48
        let width = unit * depth
        let spot = GardenPlacementRules.spotKind(at: cell)
        switch spot {
        case .flowerBed:
            let bed = CGRect(x: center.x - width * 0.53, y: center.y - width * 0.23,
                             width: width * 1.06, height: width * 0.48)
            context.fill(Path(ellipseIn: bed.offsetBy(dx: 1, dy: 3)), with: .color(.black.opacity(0.26)))
            context.fill(Path(ellipseIn: bed), with: .color(Color(red: 0.64, green: 0.45, blue: 0.28)))
            context.fill(Path(ellipseIn: bed.insetBy(dx: 2, dy: 2)), with: .color(soil))
            for index in 0..<8 {
                let dx = CGFloat((index * 23) % 70) / 100 - 0.35
                let dy = CGFloat((index * 13) % 30) / 100 - 0.15
                let pebble = CGRect(x: center.x + dx * width, y: center.y + dy * width,
                                    width: 1.2 + CGFloat(index % 2), height: 1.1)
                context.fill(Path(ellipseIn: pebble), with: .color(pathLight.opacity(0.48)))
            }
        case .path:
            for index in 0..<3 {
                let dx = CGFloat(index - 1) * width * 0.22
                let stone = CGRect(x: center.x + dx - width * 0.12, y: center.y - width * 0.08 + CGFloat(index % 2) * 2,
                                   width: width * 0.24, height: width * 0.17)
                context.fill(Path(ellipseIn: stone), with: .color(pathDark.opacity(0.45)))
                context.fill(Path(ellipseIn: stone.insetBy(dx: 1, dy: 1)), with: .color(pathLight))
            }
        case .waterside:
            context.fill(Path(ellipseIn: CGRect(x: center.x - width * 0.39, y: center.y - width * 0.13,
                                               width: width * 0.78, height: width * 0.30)),
                         with: .color(Color(red: 0.78, green: 0.71, blue: 0.48).opacity(0.68)))
        case .service:
            let pad = CGRect(x: center.x - width * 0.36, y: center.y - width * 0.13,
                             width: width * 0.72, height: width * 0.27)
            context.fill(Path(roundedRect: pad, cornerRadius: 4), with: .color(pathDark.opacity(0.45)))
        case .orchard, .lawn:
            // Clear grass is intentionally unmarked until the player picks a
            // suitable object. There are no disconnected empty square slots.
            break
        }
    }
}

private extension GardenRegion {
    var restorationLayer: Double {
        switch self {
        case .waterside, .greenhouseYard: 10
        case .meadow, .orchard: 11
        case .courtyard: 12
        }
    }
}

private struct GardenRegionShape: Shape {
    let region: GardenRegion

    func path(in rect: CGRect) -> Path {
        let points: [CGPoint]
        switch region {
        case .waterside:
            points = [CGPoint(x: 0, y: 0), CGPoint(x: 0.49, y: 0), CGPoint(x: 0.46, y: 0.27), CGPoint(x: 0.42, y: 0.33), CGPoint(x: 0, y: 0.33)]
        case .greenhouseYard:
            points = [CGPoint(x: 0.51, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 0.33), CGPoint(x: 0.58, y: 0.33), CGPoint(x: 0.54, y: 0.27)]
        case .meadow:
            points = [CGPoint(x: 0, y: 0.33), CGPoint(x: 0.50, y: 0.33), CGPoint(x: 0.50, y: 0.62), CGPoint(x: 0, y: 0.66)]
        case .orchard:
            points = [CGPoint(x: 0.50, y: 0.33), CGPoint(x: 1, y: 0.33), CGPoint(x: 1, y: 0.66), CGPoint(x: 0.50, y: 0.62)]
        case .courtyard:
            points = [CGPoint(x: 0, y: 0.66), CGPoint(x: 0.50, y: 0.62), CGPoint(x: 1, y: 0.66), CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1)]
        }
        return Path { path in
            guard let first = points.first else { return }
            path.move(to: CGPoint(x: rect.width * first.x, y: rect.height * first.y))
            for point in points.dropFirst() {
                path.addLine(to: CGPoint(x: rect.width * point.x, y: rect.height * point.y))
            }
            path.closeSubpath()
        }
    }
}

private struct FogTexture: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let region: GardenRegion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1 / 15, paused: reduceMotion)) { timeline in
            GeometryReader { proxy in
                let time = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                let regionSeed = (GardenRegion.allCases.firstIndex(of: region) ?? 0) * 17
                ZStack {
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color(red: 0.82, green: 0.88, blue: 0.86).opacity(0.22), Color.white.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    ForEach(0..<8, id: \.self) { index in
                        let seed = index + regionSeed
                        let width = proxy.size.width * (0.24 + CGFloat(seed % 4) * 0.055)
                        let height = width * (0.34 + CGFloat(seed % 3) * 0.035)
                        let travel = proxy.size.width + width * 1.3
                        let origin = proxy.size.width * CGFloat((seed * 37) % 100) / 100
                        let speed = proxy.size.width * (0.0018 + CGFloat(seed % 3) * 0.00045)
                        let drift = reduceMotion ? 0 : time * speed
                        let x = (origin + drift).truncatingRemainder(dividingBy: travel) - width * 0.15
                        let y = proxy.size.height * (0.08 + CGFloat((seed * 29) % 82) / 100)
                        FogCloud(bright: index.isMultiple(of: 3))
                            .frame(width: width, height: height)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

private struct FogCloud: View {
    let bright: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.white.opacity(bright ? 0.72 : 0.52))
                    .frame(width: width, height: height * 0.52)
                Circle()
                    .fill(Color.white.opacity(bright ? 0.78 : 0.58))
                    .frame(width: height * 0.88, height: height * 0.88)
                    .offset(x: -width * 0.23, y: -height * 0.13)
                Circle()
                    .fill(Color.white.opacity(bright ? 0.84 : 0.62))
                    .frame(width: height * 1.18, height: height * 1.18)
                    .offset(x: width * 0.03, y: -height * 0.18)
                Circle()
                    .fill(Color.white.opacity(bright ? 0.74 : 0.54))
                    .frame(width: height * 0.76, height: height * 0.76)
                    .offset(x: width * 0.28, y: -height * 0.08)
            }
            .frame(width: width, height: height)
            .blur(radius: 4)
            .shadow(color: Color(red: 0.62, green: 0.71, blue: 0.69).opacity(0.28), radius: 10, y: 4)
        }
        .accessibilityHidden(true)
    }
}

private struct NeglectTexture: View {
    let region: GardenRegion
    let density: Double

    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                let regionSeed = (GardenRegion.allCases.firstIndex(of: region) ?? 0) * 19
                let count = max(3, Int(18 * density))
                for index in 0..<count {
                    let seed = index + regionSeed
                    let x = size.width * (0.04 + CGFloat((seed * 41) % 92) / 100)
                    let y = size.height * (0.04 + CGFloat((seed * 29) % 92) / 100)
                    let width = size.width * (0.018 + CGFloat(seed % 4) * 0.008)
                    let patch = CGRect(x: x, y: y, width: width * 2.4, height: width)
                    context.fill(Path(ellipseIn: patch), with: .color(index.isMultiple(of: 3) ? Palette.soil.opacity(0.46) : Palette.stone.opacity(0.34)))
                }
            }
            Image(systemName: "trash.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Palette.ink.opacity(0.55 * density))
                .position(x: proxy.size.width * 0.27, y: proxy.size.height * 0.53)
            Image(systemName: "leaf.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Palette.soil.opacity(0.62 * density))
                .rotationEffect(.degrees(78))
                .position(x: proxy.size.width * 0.72, y: proxy.size.height * 0.38)
        }
        .opacity(density)
    }
}

/// Larger scene art used both on the garden itself and in the placement tray.
struct GardenScenePiece: View {
    let decor: DecorID

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack {
                switch decor {
                case .pathStone:
                    Ellipse()
                        .fill(RadialGradient(colors: [Color.white.opacity(0.75), Palette.stone], center: .topLeading, startRadius: 0, endRadius: width * 0.65))
                        .frame(width: width * 0.86, height: height * 0.48)
                        .overlay { Ellipse().strokeBorder(Palette.woodDark.opacity(0.35), lineWidth: 1.5) }
                case .communityBench:
                    Image("DecorCommunityBench")
                        .resizable()
                        .scaledToFit()
                case .birdbath, .sundial:
                    VStack(spacing: 0) {
                        Ellipse().fill(stoneGradient).frame(width: width * 0.75, height: height * 0.25)
                            .overlay { Ellipse().strokeBorder(Palette.woodDark.opacity(0.35), lineWidth: 1) }
                        Trapezoid().fill(stoneGradient).frame(width: width * 0.24, height: height * 0.45)
                        Ellipse().fill(stoneGradient).frame(width: width * 0.58, height: height * 0.17)
                    }
                case .beeHotel:
                    VStack(spacing: 0) {
                        Image(systemName: "roof.fill").foregroundStyle(Palette.woodDark).font(.system(size: width * 0.52))
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                            ForEach(0..<9, id: \.self) { _ in
                                Circle().fill(Palette.soil).overlay { Circle().strokeBorder(Palette.sun, lineWidth: 1) }
                            }
                        }
                        .padding(5)
                        .frame(width: width * 0.64, height: height * 0.54)
                        .background(RoundedRectangle(cornerRadius: 3).fill(woodGradient))
                    }
                case .rainBarrel, .compostBin:
                    ZStack {
                        RoundedRectangle(cornerRadius: width * 0.2)
                            .fill(decor == .rainBarrel ? LinearGradient(colors: [Palette.woodLight, Palette.woodDark], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Palette.wood, Palette.woodDark], startPoint: .top, endPoint: .bottom))
                            .frame(width: width * 0.68, height: height * 0.78)
                        VStack { Rectangle(); Spacer(); Rectangle() }
                            .foregroundStyle(Color.black.opacity(0.35))
                            .frame(width: width * 0.7, height: height * 0.5)
                        Image(systemName: decor == .rainBarrel ? "drop.fill" : "leaf.fill")
                            .foregroundStyle(decor == .rainBarrel ? Palette.water : Palette.leafLight)
                    }
                case .pond:
                    Ellipse()
                        .fill(RadialGradient(colors: [Color.white.opacity(0.6), Palette.water, Palette.mossDark], center: .center, startRadius: 0, endRadius: width * 0.7))
                        .overlay { Ellipse().strokeBorder(Palette.stone, lineWidth: 4) }
                        .frame(width: width, height: height * 0.62)
                case .planterBox:
                    Image("DecorPlanterBox")
                        .resizable()
                        .scaledToFit()
                case .lantern:
                    Image("DecorLantern")
                        .resizable()
                        .scaledToFit()
                case .birdhouse:
                    Image("DecorBirdhouse")
                        .resizable()
                        .scaledToFit()
                case .appleTree, .pearTree, .cherryTree, .lemonTree, .mapleTree, .willowTree:
                    if decor == .appleTree {
                        Image("TreeApple")
                            .resizable()
                            .scaledToFit()
                    } else if let tree = decor.treeKind {
                        GardenTreeView(kind: tree)
                    }
                default:
                    Image(systemName: decor.symbol)
                        .font(.system(size: min(width, height) * 0.62, weight: .bold))
                        .foregroundStyle(iconColor)
                        .padding(min(width, height) * 0.14)
                        .background(Circle().fill(Palette.paper.opacity(0.88)))
                        .overlay { Circle().strokeBorder(Palette.woodDark.opacity(0.45), lineWidth: 1.5) }
                }
            }
            .frame(width: width, height: height)
            .shadow(color: .black.opacity(0.34), radius: 3, y: 3)
        }
    }

    private var woodGradient: LinearGradient {
        LinearGradient(colors: [Palette.woodLight, Palette.wood, Palette.woodDark], startPoint: .top, endPoint: .bottom)
    }

    private var stoneGradient: LinearGradient {
        LinearGradient(colors: [Color.white.opacity(0.82), Palette.stone], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var iconColor: Color {
        switch decor {
        case .lantern: Palette.sun
        case .birdhouse: Palette.coral
        case .gardenArch, .pergola, .herbSpiral: Palette.mossDark
        default: Palette.woodDark
        }
    }
}

struct GardenTreeView: View {
    let kind: TreeKind

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(Color.black.opacity(0.18))
                    .frame(width: w * 0.72, height: h * 0.15)
                    .offset(y: h * 0.02)
                RoundedRectangle(cornerRadius: w * 0.08)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.woodDark], startPoint: .leading, endPoint: .trailing))
                    .frame(width: w * (kind == .willow ? 0.16 : 0.19), height: h * 0.56)
                    .offset(y: -h * 0.08)
                canopy(width: w, height: h)
                    .offset(y: -h * 0.33)
                if kind == .apple || kind == .pear || kind == .cherry || kind == .lemon {
                    fruit(width: w, height: h)
                        .offset(y: -h * 0.38)
                }
            }
            .frame(width: w, height: h)
        }
        .accessibilityLabel(kind.name)
    }

    private func canopy(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            if kind == .willow {
                ForEach(0..<7, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? Palette.leaf : Palette.moss)
                        .frame(width: width * 0.20, height: height * (0.48 + CGFloat(index % 3) * 0.05))
                        .rotationEffect(.degrees(Double(index - 3) * 9))
                        .offset(x: CGFloat(index - 3) * width * 0.085, y: CGFloat(abs(index - 3)) * height * 0.025)
                }
            } else {
                ForEach(0..<7, id: \.self) { index in
                    Circle()
                        .fill(canopyColor(index))
                        .frame(width: width * (0.45 + CGFloat(index % 2) * 0.08))
                        .offset(
                            x: CGFloat((index % 3) - 1) * width * 0.20,
                            y: CGFloat(index / 3) * height * 0.10
                        )
                }
                if kind == .cherry {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(index.isMultiple(of: 2) ? Color.white : Palette.blush)
                            .frame(width: width * 0.09)
                            .offset(x: CGFloat((index * 37) % 90) / 100 * width - width * 0.44, y: CGFloat((index * 23) % 48) / 100 * height - height * 0.20)
                    }
                }
            }
        }
    }

    private func fruit(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(fruitColor)
                    .frame(width: width * (kind == .cherry ? 0.065 : 0.09))
                    .overlay { Circle().strokeBorder(Color.white.opacity(0.35), lineWidth: 1) }
                    .offset(
                        x: CGFloat((index * 41) % 86) / 100 * width - width * 0.42,
                        y: CGFloat((index * 29) % 46) / 100 * height - height * 0.20
                    )
            }
        }
    }

    private func canopyColor(_ index: Int) -> Color {
        if kind == .maple {
            return index.isMultiple(of: 2) ? Color(red: 0.92, green: 0.58, blue: 0.16) : Palette.sun
        }
        if kind == .lemon {
            return index.isMultiple(of: 2) ? Palette.mossDark : Palette.leaf
        }
        return index.isMultiple(of: 2) ? Palette.leaf : Palette.moss
    }

    private var fruitColor: Color {
        switch kind {
        case .apple: Palette.coral
        case .pear: Palette.leafLight
        case .cherry: Color(red: 0.62, green: 0.06, blue: 0.12)
        case .lemon: Palette.sun
        case .maple, .willow: .clear
        }
    }
}

private struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.25, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.25, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct LegacyGardenCanvas: View {
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
        case .appleTree, .pearTree, .cherryTree, .lemonTree, .mapleTree, .willowTree: Palette.moss
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
