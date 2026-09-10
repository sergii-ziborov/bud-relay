import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmReset = false

    var body: some View {
        VStack(spacing: 12) {
            ScreenHeader(title: "Settings") { model.goHome() }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    PaperCard(padding: 14) {
                        VStack(spacing: 12) {
                            Toggle(isOn: Binding(get: { model.progress.hapticsEnabled }, set: { _ in model.toggleHaptics() })) {
                                Label("Haptics", systemImage: "hand.tap.fill")
                                    .font(Typography.body)
                                    .foregroundStyle(Palette.ink)
                            }
                            .tint(Palette.moss)
                            Divider()
                            Button {
                                model.go(.howToPlay)
                            } label: {
                                HStack {
                                    Label("How to Play", systemImage: "questionmark.circle.fill")
                                        .font(Typography.body)
                                        .foregroundStyle(Palette.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Palette.inkSoft)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    PaperCard(padding: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            statRow("Levels cleared", "\(model.progress.stars.count)/\(LevelCatalog.count)")
                            statRow("Stars", "\(model.progress.totalStars)")
                            statRow("Flowers bloomed", "\(model.progress.lifetimeBloomed)")
                            statRow("Longest relay", "×\(model.progress.lifetimeLongestChain)")
                            statRow("Orders delivered", "\(model.progress.ordersCompleted)")
                            Divider()
                            Button(role: .destructive) {
                                confirmReset = true
                            } label: {
                                Label("Reset progress", systemImage: "trash")
                                    .font(Typography.body)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Palette.coral)
                            .accessibilityIdentifier("reset-button")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    PaperCard(padding: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("About")
                                .font(Typography.heading)
                                .foregroundStyle(Palette.ink)
                            Text("Bud Relay \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                            Text("Plant now. Bloom later. A relay puzzle about restoring a neighbourhood's gardens. No account, no ads, no tracking. Progress stays on this device.")
                                .font(Typography.caption)
                                .foregroundStyle(Palette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Flower notes in the greenhouse are general gardening knowledge, not planting advice for your climate.")
                                .font(Typography.small)
                                .foregroundStyle(Palette.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .contentColumn()
        .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset everything", role: .destructive) {
                model.resetProgress()
            }
            Button("Keep playing", role: .cancel) {}
        } message: {
            Text("Stars, coins, flowers, and the garden will start over.")
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.inkSoft)
            Spacer()
            Text(value)
                .font(Typography.body)
                .foregroundStyle(Palette.ink)
                .monospacedDigit()
        }
    }
}
