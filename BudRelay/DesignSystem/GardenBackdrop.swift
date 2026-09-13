import SwiftUI

/// A soft, painterly garden behind every screen: sky, blurred foliage, and a few flowers at the edges.
struct GardenBackdrop: View {
    enum Scene {
        case home, garden, greenhouse, market, daily, map
    }

    let scene: Scene

    private var imageName: String {
        switch scene {
        case .home, .daily: "SceneHome"
        case .garden: "SceneGardenEstate"
        case .greenhouse: "SceneGreenhouse"
        case .market: "SceneMarket"
        case .map: "SceneMap"
        }
    }

    private struct Blob: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let color: Color
    }

    private var skyColors: [Color] {
        switch scene {
        case .home: [Palette.sky, Color(red: 0.86, green: 0.93, blue: 0.80), Color(red: 0.62, green: 0.76, blue: 0.48)]
        case .garden: [Color(red: 0.80, green: 0.90, blue: 0.96), Color(red: 0.88, green: 0.93, blue: 0.78), Color(red: 0.56, green: 0.72, blue: 0.42)]
        case .greenhouse: [Color(red: 0.86, green: 0.94, blue: 0.94), Color(red: 0.90, green: 0.95, blue: 0.85), Color(red: 0.66, green: 0.80, blue: 0.56)]
        case .market: [Color(red: 0.98, green: 0.90, blue: 0.76), Color(red: 0.95, green: 0.88, blue: 0.70), Color(red: 0.68, green: 0.72, blue: 0.42)]
        case .daily: [Color(red: 0.98, green: 0.93, blue: 0.72), Color(red: 0.92, green: 0.94, blue: 0.76), Color(red: 0.62, green: 0.78, blue: 0.46)]
        case .map: [Palette.sky, Color(red: 0.76, green: 0.88, blue: 0.66), Color(red: 0.48, green: 0.70, blue: 0.37)]
        }
    }

    private var blobs: [Blob] {
        let greens = [Palette.leaf, Palette.moss, Palette.mossDark, Palette.leafLight]
        let accents: [Color]
        switch scene {
        case .home: accents = [Palette.blush, Palette.sun, Palette.lavender]
        case .garden: accents = [Palette.blush, Palette.coral, Palette.lavender, Palette.sun]
        case .greenhouse: accents = [Palette.water.opacity(0.7), Palette.leafLight, Palette.blush]
        case .market: accents = [Palette.sun, Palette.coral, Palette.gold]
        case .daily: accents = [Palette.sun, Palette.gold, Palette.lavender]
        case .map: accents = [Palette.water, Palette.sun, Palette.lavender]
        }
        return (0..<26).map { index in
            let t = CGFloat(index)
            let x = CGFloat((index * 37) % 100) / 100
            let y = 0.18 + CGFloat((index * 53) % 100) / 100 * 0.85
            let radius = 60 + CGFloat((index * 29) % 70)
            let color = index % 4 == 0 ? accents[index % accents.count] : greens[Int(t) % greens.count]
            return Blob(id: index, x: x, y: y, radius: radius, color: color)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: skyColors, startPoint: .top, endPoint: .bottom)
                // The garden has its own camera-controlled world. An independent
                // full-screen illustration here would slide beneath its objects.
                if scene != .garden {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(0.08), location: 0),
                        .init(color: .clear, location: 0.38),
                        .init(color: .black.opacity(0.12), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func edgeFlowers(in size: CGSize) -> some View {
        let kinds: [FlowerKind] = [.daisy, .tulip, .lavender, .sunflower, .rose, .marigold]
        ForEach(0..<10, id: \.self) { index in
            let kind = kinds[index % kinds.count]
            let x = index < 5 ? CGFloat(index) * 0.11 : 1 - CGFloat(index - 5) * 0.11
            let y = 0.86 + CGFloat(index % 3) * 0.05
            FlowerView(kind: kind, stage: .bloom, variant: 0)
                .frame(width: 44 + CGFloat(index % 3) * 10)
                .opacity(0.55)
                .blur(radius: 1.2)
                .position(x: x * size.width, y: y * size.height)
        }
    }
}
