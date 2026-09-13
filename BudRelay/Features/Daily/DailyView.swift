import SwiftUI

struct DailyView: View {
    @Environment(AppModel.self) private var model

    private var day: Int { DailyBloom.dayNumber() }
    private var level: LevelDef { DailyBloom.level(for: day) }

    var body: some View {
        VStack(spacing: 10) {
            HUDBar()
            HStack(spacing: 8) {
                BackButton(action: model.goHome)
                Spacer(minLength: 0)
                LogoView(subtitle: "Daily Bloom", scale: 0.58)
                Spacer(minLength: 0)
                Color.clear.frame(width: 44, height: 44)
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    challengeCard
                    PrimaryButton(title: model.progress.dailyRecord(for: day) == nil ? "Play" : "Play Again", action: model.playDaily)
                        .accessibilityIdentifier("daily-play-button")
                    recentDays
                }
                .padding(.bottom, 8)
            }
            HubNav(selected: .daily)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .contentColumn()
    }

    private var challengeCard: some View {
        WoodPanel(cornerRadius: 18, padding: 12) {
            VStack(spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Bloom #\(day)")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.cream.opacity(0.85))
                        Text(DailyBloom.title(for: day))
                            .font(Typography.display(24))
                            .foregroundStyle(Palette.cream)
                            .shadow(color: Palette.woodDark, radius: 0, y: 2)
                    }
                    Spacer()
                    streakTag
                }
                HStack(alignment: .top, spacing: 10) {
                    BoardView(board: level.initialBoard(), variants: model.progress.variants, interactive: false)
                        .frame(width: 168, height: 168)
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(symbol: "link", text: "Goal: the longest relay you can")
                        infoRow(symbol: "clock.fill", text: "\(level.turns) turns")
                        infoRow(symbol: level.weather.symbol, text: level.weather.name)
                        HStack(spacing: 4) {
                            ForEach(level.kinds) { kind in
                                FlowerIcon(kind: kind, size: 24)
                            }
                        }
                        if let record = model.progress.dailyRecord(for: day) {
                            infoRow(symbol: "trophy.fill", text: "Your best today: ×\(record.bestChain)")
                        } else {
                            infoRow(symbol: "sparkles", text: "Not played yet")
                        }
                        infoRow(symbol: "arrow.clockwise", text: "Resets in \(resetText)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                PaperCard(padding: 8) {
                    Text("Everyone gets the same bed today. Coins grow with every bloom, and bees still leave seeds.")
                        .font(Typography.small)
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var streakTag: some View {
        VStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(model.progress.displayedStreak > 0 ? Palette.coral : Palette.inkSoft)
            Text("\(model.progress.displayedStreak)")
                .font(Typography.heading)
                .foregroundStyle(Palette.ink)
            Text("day streak")
                .font(Typography.small)
                .foregroundStyle(Palette.inkSoft)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Palette.paper)
                .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(Palette.woodDark.opacity(0.3), lineWidth: 1) }
        }
    }

    private func infoRow(symbol: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.sun)
                .frame(width: 16)
            Text(text)
                .font(Typography.caption)
                .foregroundStyle(Palette.cream)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    private var resetText: String {
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime) else { return "—" }
        let minutes = max(0, Int(tomorrow.timeIntervalSince(now) / 60))
        return "\(minutes / 60)h \(minutes % 60)m"
    }

    private var recentDays: some View {
        let records = model.progress.daily.sorted { $0.day > $1.day }.prefix(7)
        return PaperCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Beds")
                    .font(Typography.heading)
                    .foregroundStyle(Palette.ink)
                if records.isEmpty {
                    Text("Your daily results will collect here.")
                        .font(Typography.caption)
                        .foregroundStyle(Palette.inkSoft)
                } else {
                    ForEach(Array(records), id: \.day) { record in
                        HStack {
                            Text("#\(record.day) · \(DailyBloom.title(for: record.day))")
                                .font(Typography.caption)
                                .foregroundStyle(Palette.ink)
                            Spacer()
                            Text("×\(record.bestChain)")
                                .font(Typography.body)
                                .foregroundStyle(Palette.mossDark)
                                .monospacedDigit()
                            Text("\(record.bloomed) blooms")
                                .font(Typography.small)
                                .foregroundStyle(Palette.inkSoft)
                        }
                    }
                }
                if model.progress.lifetimeLongestChain > 0 {
                    Divider()
                    HStack {
                        Text("Lifetime longest relay")
                            .font(Typography.caption)
                            .foregroundStyle(Palette.inkSoft)
                        Spacer()
                        Text("×\(model.progress.lifetimeLongestChain)")
                            .font(Typography.body)
                            .foregroundStyle(Palette.ink)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
