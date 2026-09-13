import SwiftUI

@main
struct BudRelayApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ZStack {
            GardenBackdrop(scene: backdropScene)
                .ignoresSafeArea()
            Group {
                switch model.screen {
                case .home: HomeView()
                case .play: PlayView()
                case .result: ResultView()
                case .map: MapView()
                case .garden: GardenView()
                case .greenhouse: GreenhouseView()
                case .market: MarketView()
                case .daily: DailyView()
                case .settings: SettingsView()
                case .howToPlay: HowToPlayView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .id(screenKey)

            if let notice = model.notice {
                NoticeBanner(text: notice)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if let scene = model.currentScene {
                StoryOverlay(scene: scene)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: screenKey)
        .animation(.easeInOut(duration: 0.25), value: model.notice)
        .animation(.easeInOut(duration: 0.25), value: model.currentScene?.id)
        .tint(Palette.moss)
        .task {
            model.showWelcomeIfNeeded()
        }
    }

    private var backdropScene: GardenBackdrop.Scene {
        switch model.screen {
        case .greenhouse: .greenhouse
        case .market: .market
        case .garden: .garden
        case .daily: .daily
        case .map: .map
        default: .home
        }
    }

    private var screenKey: String {
        switch model.screen {
        case .home: "home"
        case .play: "play"
        case .result: "result"
        case .map: "map"
        case .garden: "garden"
        case .greenhouse: "greenhouse"
        case .market: "market"
        case .daily: "daily"
        case .settings: "settings"
        case .howToPlay: "howToPlay"
        }
    }
}
