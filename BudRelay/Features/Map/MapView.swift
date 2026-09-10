import SwiftUI

struct MapView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 10) {
            ScreenHeader(title: "District Map", subtitle: "\(model.progress.totalStars) stars") { model.goHome() }
                .padding(.horizontal, 16)
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(ChapterID.allCases) { chapter in
                            ChapterCard(chapter: chapter)
                                .id(chapter.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .contentColumn()
                }
                .onAppear {
                    proxy.scrollTo(model.progress.currentChapter.id, anchor: .top)
                }
            }
        }
        .padding(.top, 8)
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
