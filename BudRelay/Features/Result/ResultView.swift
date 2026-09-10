import SwiftUI

struct ResultView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        if let outcome = model.outcome {
            ResultContent(outcome: outcome)
        } else {
            Color.clear.onAppear { model.goHome() }
        }
    }
}

private struct ResultContent: View {
    @Environment(AppModel.self) private var model
    let outcome: LevelOutcome

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                title
                    .padding(.top, 16)
                if !outcome.isDaily {
                    StarRow(stars: outcome.stars, size: 34)
                        .padding(.top, 4)
                }
                statsCard
                if outcome.won || outcome.isDaily {
                    earnedCard
                }
                buttons
                    .padding(.top, 6)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
            .contentColumn()
        }
    }

    private var title: some View {
        VStack(spacing: 6) {
            Text(headline)
                .font(Typography.display(40))
                .foregroundStyle(outcome.won ? Palette.leafLight : Palette.cream)
                .shadow(color: Palette.woodDark, radius: 0, y: 3)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("result-title")
            Text(subline)
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Palette.paper)
                        .overlay { RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Palette.woodDark.opacity(0.35), lineWidth: 1.5) }
                }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.woodLight, Palette.wood], startPoint: .top, endPoint: .bottom))
                WoodGrain().clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Palette.woodDark, lineWidth: 3)
            }
            .shadow(color: .black.opacity(0.3), radius: 8, y: 5)
        }
    }

    private var headline: String {
        if outcome.isDaily { return outcome.dailyBest ? "New Best!" : "Daily Done" }
        return outcome.won ? "Great Bloom!" : "Not Yet"
    }

    private var subline: String {
        if outcome.isDaily { return "Longest relay today: ×\(outcome.stats.longestChain)" }
        return outcome.won ? "You made the garden brighter!" : "The beds need one more try."
    }

    private var statsCard: some View {
        PaperCard(padding: 14) {
            VStack(spacing: 8) {
                statRow("Longest relay", value: "×\(outcome.stats.longestChain)", symbol: "link")
                statRow("Flowers bloomed", value: "\(outcome.stats.bloomed)", symbol: "camera.macro")
                statRow("Bee visits", value: "\(outcome.stats.pollinatorBonuses)", symbol: "ant.fill")
                statRow("Turns remaining", value: "\(outcome.turnsLeft)", symbol: "clock.fill")
            }
        }
    }

    private func statRow(_ label: String, value: String, symbol: String) -> some View {
        HStack {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.moss)
                .frame(width: 22)
            Text(label)
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
            Spacer()
            Text(value)
                .font(Typography.heading)
                .foregroundStyle(Palette.ink)
                .monospacedDigit()
        }
    }

    private var earnedCard: some View {
        WoodPanel(cornerRadius: 18, padding: 12) {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill").foregroundStyle(Palette.leafLight)
                    SignTitle(text: "You Earned", size: 22)
                    Image(systemName: "leaf.fill").foregroundStyle(Palette.leafLight).scaleEffect(x: -1)
                }
                HStack(spacing: 8) {
                    rewardTile(symbol: "dollarsign.circle.fill", tint: Palette.gold, label: "+\(outcome.coins)", caption: "Coins")
                    ForEach(outcome.flowers.sorted { $0.key.value > $1.key.value }, id: \.key) { kind, count in
                        rewardTile(kind: kind, label: "+\(count)", caption: kind.name)
                    }
                    ForEach(outcome.seeds.sorted { $0.key.value > $1.key.value }, id: \.key) { kind, count in
                        rewardTile(symbol: "bag.fill", tint: Palette.moss, label: "+\(count)", caption: "\(kind.name) seeds")
                    }
                    if let kind = outcome.unlockedKind {
                        rewardTile(kind: kind, label: "NEW", caption: kind.name, isNew: true)
                    }
                    if let decor = outcome.unlockedDecor {
                        rewardTile(symbol: decor.symbol, tint: Palette.woodDark, label: "NEW", caption: decor.name, isNew: true)
                    }
                }
                Text(footnote)
                    .font(Typography.caption)
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Palette.paper.opacity(0.9))
                    }
            }
        }
    }

    private var footnote: String {
        if outcome.flowers.isEmpty {
            return "Relays of ×3, ×5, and ×8 earn flowers for orders and your garden."
        }
        return "Another step toward a greener tomorrow."
    }

    private func rewardTile(symbol: String? = nil, kind: FlowerKind? = nil, tint: Color = Palette.gold, label: String, caption: String, isNew: Bool = false) -> some View {
        VStack(spacing: 4) {
            if let kind {
                FlowerIcon(kind: kind, size: 40, variant: model.progress.variant(for: kind))
            } else if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(height: 40)
            }
            Text(label)
                .font(Typography.heading)
                .foregroundStyle(isNew ? Palette.coral : Palette.ink)
            Text(caption)
                .font(Typography.small)
                .foregroundStyle(Palette.inkSoft)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.paper)
                .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(isNew ? Palette.coral : Palette.woodDark.opacity(0.25), lineWidth: isNew ? 2 : 1) }
        }
    }

    private var buttons: some View {
        VStack(spacing: 10) {
            if outcome.isDaily {
                PrimaryButton(title: "Home", symbol: "house.fill", action: model.goHome)
                    .accessibilityIdentifier("home-button")
                WoodButton(title: "Play Again", symbol: "arrow.counterclockwise", action: model.retry)
            } else if outcome.won {
                PrimaryButton(title: "Next Level", symbol: "arrow.right", action: model.nextLevel)
                    .accessibilityIdentifier("next-level-button")
                HStack(spacing: 10) {
                    WoodButton(title: "Garden", symbol: "leaf.fill") {
                        model.session = nil
                        model.go(.garden)
                    }
                    WoodButton(title: "Home", symbol: "house.fill", action: model.goHome)
                }
            } else {
                PrimaryButton(title: "Try Again", symbol: "arrow.counterclockwise", action: model.retry)
                    .accessibilityIdentifier("retry-button")
                WoodButton(title: "Home", symbol: "house.fill", action: model.goHome)
            }
        }
    }
}
