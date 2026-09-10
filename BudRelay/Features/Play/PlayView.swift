import SwiftUI

struct PlayView: View {
    @Environment(AppModel.self) private var model
    @State private var paused = false

    var body: some View {
        if let session = model.session {
            PlayContent(session: session, paused: $paused)
        } else {
            Color.clear.onAppear { model.goHome() }
        }
    }
}

private struct PlayContent: View {
    @Environment(AppModel.self) private var model
    @Bindable var session: PlaySession
    @Binding var paused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                topBar
                GoalsPanel(session: session)
                board
                HandView(session: session)
                ToolsBar(session: session)
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 10)
            .contentColumn()
            .disabled(paused)
            .blur(radius: paused ? 3 : 0)

            if paused {
                PauseMenu(paused: $paused)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: paused)
    }

    private var topBar: some View {
        HStack(spacing: 8) {
            IconButton(symbol: "pause.fill", size: 40, accessibilityID: "pause-button") {
                paused = true
            }
            Spacer(minLength: 0)
            VStack(spacing: 1) {
                Text(session.isDaily ? "Daily Bloom" : session.level.title)
                    .font(Typography.heading)
                    .foregroundStyle(Palette.cream)
                    .shadow(color: Palette.woodDark, radius: 0, y: 1)
                Text(session.isDaily ? DailyBloom.title(for: DailyBloom.dayNumber()) : session.level.chapter.name)
                    .font(Typography.small)
                    .foregroundStyle(Palette.cream.opacity(0.85))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                    .overlay { RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 2) }
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 3)
            }
            Spacer(minLength: 0)
            ResourcePill(symbol: "clock.fill", text: "\(session.turnsLeft)", tint: session.turnsLeft <= 3 ? Palette.coral : Palette.cream, accessibilityID: "turns-left")
            Button {
                session.requestHint()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(session.hintsLeft > 0 ? Palette.sun : Palette.cream.opacity(0.4))
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                                .overlay { Circle().strokeBorder(Palette.woodDark, lineWidth: 2) }
                        }
                    Text("\(session.hintsLeft)")
                        .font(Typography.small)
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Circle().fill(Palette.ink))
                }
            }
            .buttonStyle(PressStyle())
            .disabled(session.hintsLeft == 0 || session.phase != .planning)
            .accessibilityIdentifier("hint-button")
        }
    }

    private var board: some View {
        ZStack {
            BoardView(
                board: session.displayBoard,
                variants: model.progress.variants,
                highlighted: highlightedCells,
                hinted: session.hintCell,
                glowing: session.justBloomed,
                thirsty: thirstyCells,
                ghost: session.selectedCard.flatMap { session.hand.indices.contains($0) ? session.hand[$0] : nil },
                pulses: session.activeWave?.pulses ?? [],
                interactive: true
            ) { cell in
                session.tap(cell: cell)
            }
            .overlay(alignment: .top) {
                harvestFloaters
            }
            if let chain = session.chainBanner {
                ChainBanner(chain: chain)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.4), value: session.chainBanner)
    }

    private var highlightedCells: Set<Cell> {
        Set(Board.allCells.filter { session.isHighlighted($0) })
    }

    private var thirstyCells: Set<Cell> {
        guard session.level.weather == .hotDay || session.board.plots.contains(where: { $0.moisture == .dry }) else { return [] }
        return Set(session.board.budCells.filter { session.board[$0].moisture == .dry })
    }

    @ViewBuilder
    private var harvestFloaters: some View {
        if !session.harvestFloaters.isEmpty {
            HStack(spacing: 6) {
                ForEach(Array(session.harvestFloaters.enumerated()), id: \.offset) { _, harvest in
                    HStack(spacing: 2) {
                        FlowerIcon(kind: harvest.kind, size: 22)
                        Text("+\(harvest.yield)")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.ink)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Capsule().fill(Palette.paper))
                }
            }
            .padding(.top, 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

private struct ChainBanner: View {
    let chain: Int

    var body: some View {
        VStack(spacing: -4) {
            Text("Relay")
                .font(Typography.display(30))
            Text("×\(chain)")
                .font(Typography.display(54))
        }
        .foregroundStyle(LinearGradient(colors: [Palette.glow, Palette.sun, Palette.gold], startPoint: .top, endPoint: .bottom))
        .shadow(color: Palette.woodDark, radius: 0, y: 3)
        .shadow(color: Palette.glow.opacity(0.9), radius: 14)
        .rotationEffect(.degrees(-6))
        .allowsHitTesting(false)
    }
}

// MARK: - Goals

private struct GoalsPanel: View {
    let session: PlaySession

    var body: some View {
        PaperCard(padding: 10) {
            HStack(spacing: 12) {
                ForEach(Array(session.goalProgress.enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 8) {
                        Group {
                            if let kind = item.goal.kind {
                                FlowerIcon(kind: kind, size: 26)
                            } else {
                                Image(systemName: item.goal.symbol)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Palette.moss)
                                    .frame(width: 26, height: 26)
                            }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.goal.label)
                                .font(Typography.caption)
                                .foregroundStyle(Palette.ink)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                            HStack(spacing: 4) {
                                Text("\(item.progress)/\(item.goal.target)")
                                    .font(Typography.small)
                                    .foregroundStyle(item.done ? Palette.mossDark : Palette.inkSoft)
                                    .monospacedDigit()
                                if item.done {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Palette.mossDark)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                weather
            }
        }
    }

    private var weather: some View {
        VStack(spacing: 2) {
            Image(systemName: session.level.weather.symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(session.level.weather == .hotDay ? Palette.coral : (session.level.weather == .rain ? Palette.water : Palette.sun))
            Text(session.level.weather.name)
                .font(Typography.small)
                .foregroundStyle(Palette.inkSoft)
        }
        .frame(width: 58)
    }
}

// MARK: - Hand

private struct HandView: View {
    @Environment(AppModel.self) private var model
    @Bindable var session: PlaySession

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(session.hand.enumerated()), id: \.offset) { index, kind in
                    Button {
                        session.select(card: index)
                    } label: {
                        FlowerCard(kind: kind, variant: model.progress.variant(for: kind), selected: session.selectedCard == index, hinted: session.hintCard == index)
                    }
                    .buttonStyle(PressStyle())
                    .disabled(session.phase != .planning)
                    .accessibilityIdentifier("card-\(index)")
                    .accessibilityLabel("\(kind.name), \(kind.growTurns) turns")
                }
                nextCard
            }
            seedRow
        }
    }

    private var nextCard: some View {
        VStack(spacing: 2) {
            Text("Next")
                .font(Typography.small)
                .foregroundStyle(Palette.inkSoft)
            FlowerView(kind: session.next, stage: .bud, variant: model.progress.variant(for: session.next))
                .frame(width: 34, height: 34)
            TimerBadge(value: session.next.growTurns, size: 16)
        }
        .frame(width: 54)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.paperDark.opacity(0.8))
                .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Palette.woodDark.opacity(0.25), lineWidth: 1) }
        }
        .accessibilityIdentifier("next-card")
    }

    @ViewBuilder
    private var seedRow: some View {
        let seeds = model.progress.seeds.filter { $0.value > 0 && model.progress.isUnlocked($0.key) }.keys.sorted { $0.growTurns < $1.growTurns }
        if !seeds.isEmpty, !session.seedSwapUsedThisTurn, session.phase == .planning {
            HStack(spacing: 6) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette.inkSoft)
                Text(session.selectedCard == nil ? "Seed packets swap a card: pick a card first" : "Swap the card for a seed packet:")
                    .font(Typography.small)
                    .foregroundStyle(Palette.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 0)
                ForEach(seeds) { kind in
                    Button {
                        guard let index = session.selectedCard else { return }
                        model.progress.seeds[kind, default: 0] -= 1
                        model.save()
                        session.useSeed(kind, on: index)
                    } label: {
                        HStack(spacing: 2) {
                            FlowerIcon(kind: kind, size: 18)
                            Text("\(model.progress.seeds[kind, default: 0])")
                                .font(Typography.small)
                                .foregroundStyle(Palette.ink)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(Capsule().fill(Palette.paper))
                    }
                    .buttonStyle(PressStyle())
                    .disabled(session.selectedCard == nil)
                    .opacity(session.selectedCard == nil ? 0.5 : 1)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct FlowerCard: View {
    let kind: FlowerKind
    var variant: Int = 0
    var selected = false
    var hinted = false

    var body: some View {
        VStack(spacing: 4) {
            FlowerView(kind: kind, stage: .bud, variant: variant)
                .frame(height: 50)
                .overlay(alignment: .bottomTrailing) {
                    TimerBadge(value: kind.growTurns, size: 22)
                        .offset(x: 6, y: 2)
                }
            Text(kind.name.uppercased())
                .font(Typography.small)
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(colors: [Palette.paper, Palette.paperDark], startPoint: .top, endPoint: .bottom))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(selected ? Palette.sun : (hinted ? Palette.leaf : Palette.woodDark.opacity(0.3)), lineWidth: selected || hinted ? 3 : 1.5)
                }
                .shadow(color: selected ? Palette.sun.opacity(0.8) : .black.opacity(0.18), radius: selected ? 8 : 3, y: 2)
        }
        .scaleEffect(selected ? 1.06 : 1)
        .offset(y: selected ? -6 : 0)
        .animation(.spring(duration: 0.25, bounce: 0.4), value: selected)
    }
}

// MARK: - Tools

private struct ToolsBar: View {
    @Bindable var session: PlaySession

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                ForEach(Tool.allCases) { tool in
                    let count = session.toolCount(tool)
                    Button {
                        session.select(tool: tool)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tool.symbol)
                                .font(.system(size: 17, weight: .bold))
                                .frame(height: 20)
                            Text(tool.shortName)
                                .font(Typography.small)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .foregroundStyle(Palette.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(LinearGradient(colors: session.selectedTool == tool ? [Palette.leaf, Palette.mossDark] : [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                                .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(session.selectedTool == tool ? Palette.mossDark : Palette.woodDark, lineWidth: 2) }
                        }
                        .overlay(alignment: .topTrailing) {
                            Text("\(count)")
                                .font(Typography.small)
                                .foregroundStyle(.white)
                                .frame(width: 18, height: 18)
                                .background(Circle().fill(count > 0 ? Palette.coral : Palette.stone))
                                .offset(x: 5, y: -6)
                        }
                        .opacity(count > 0 ? 1 : 0.45)
                    }
                    .buttonStyle(PressStyle())
                    .disabled(count == 0 || session.phase != .planning)
                    .accessibilityIdentifier("tool-\(tool.rawValue)")
                }
                Button {
                    session.tend()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 17, weight: .bold))
                            .frame(height: 20)
                        Text("Tend")
                            .font(Typography.small)
                    }
                    .foregroundStyle(Palette.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                            .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Palette.woodDark, lineWidth: 2) }
                    }
                }
                .buttonStyle(PressStyle())
                .disabled(!session.canTend)
                .accessibilityIdentifier("tend-button")
            }
            Text(caption)
                .font(Typography.small)
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Palette.paper.opacity(0.9))
                }
        }
    }

    private var caption: String {
        if let tool = session.selectedTool {
            return "\(tool.name): \(tool.effect)"
        }
        if session.selectedCard != nil {
            return "Tap an empty plot to plant. The number is the care cycles until it blooms."
        }
        if session.phase == .animating {
            return "Blooming beds create care momentum for nearby plants."
        }
        return "Pick a bud below, or tend the beds to let a turn pass."
    }
}

// MARK: - Pause

private struct PauseMenu: View {
    @Environment(AppModel.self) private var model
    @Binding var paused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            WoodPanel(cornerRadius: 22, padding: 18) {
                VStack(spacing: 12) {
                    SignTitle(text: "Paused", size: 26)
                    if let level = model.session?.level {
                        PaperCard(padding: 10) {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(level.goals.enumerated()), id: \.offset) { _, goal in
                                    Label(goal.label, systemImage: goal.symbol)
                                        .font(Typography.body)
                                        .foregroundStyle(Palette.ink)
                                }
                                Label(level.weather.note, systemImage: level.weather.symbol)
                                    .font(Typography.caption)
                                    .foregroundStyle(Palette.inkSoft)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    PrimaryButton(title: "Resume", symbol: "play.fill", compact: true) { paused = false }
                        .accessibilityIdentifier("resume-button")
                    HStack(spacing: 10) {
                        WoodButton(title: "Restart", symbol: "arrow.counterclockwise") {
                            paused = false
                            model.retry()
                        }
                        WoodButton(title: "Quit", symbol: "house.fill") {
                            paused = false
                            model.abandonLevel()
                        }
                    }
                }
            }
            .contentColumn()
            .padding(.horizontal, 30)
        }
    }
}
