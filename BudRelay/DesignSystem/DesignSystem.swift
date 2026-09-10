import SwiftUI

enum Palette {
    static let cream = Color(red: 0.965, green: 0.910, blue: 0.800)
    static let paper = Color(red: 0.982, green: 0.948, blue: 0.872)
    static let paperDark = Color(red: 0.925, green: 0.860, blue: 0.730)
    static let wood = Color(red: 0.545, green: 0.353, blue: 0.169)
    static let woodLight = Color(red: 0.700, green: 0.485, blue: 0.275)
    static let woodDark = Color(red: 0.360, green: 0.227, blue: 0.118)
    static let soil = Color(red: 0.300, green: 0.185, blue: 0.108)
    static let soilLight = Color(red: 0.430, green: 0.270, blue: 0.155)
    static let soilDry = Color(red: 0.640, green: 0.520, blue: 0.370)
    static let soilWet = Color(red: 0.210, green: 0.130, blue: 0.080)
    static let moss = Color(red: 0.380, green: 0.620, blue: 0.290)
    static let mossDark = Color(red: 0.243, green: 0.478, blue: 0.204)
    static let leaf = Color(red: 0.482, green: 0.745, blue: 0.353)
    static let leafLight = Color(red: 0.700, green: 0.860, blue: 0.500)
    static let ink = Color(red: 0.231, green: 0.165, blue: 0.102)
    static let inkSoft = Color(red: 0.420, green: 0.320, blue: 0.220)
    static let sky = Color(red: 0.760, green: 0.890, blue: 0.950)
    static let sun = Color(red: 0.957, green: 0.773, blue: 0.259)
    static let gold = Color(red: 0.930, green: 0.700, blue: 0.200)
    static let blush = Color(red: 0.949, green: 0.549, blue: 0.694)
    static let lavender = Color(red: 0.608, green: 0.482, blue: 0.820)
    static let coral = Color(red: 0.894, green: 0.255, blue: 0.353)
    static let stone = Color(red: 0.600, green: 0.580, blue: 0.540)
    static let water = Color(red: 0.360, green: 0.660, blue: 0.850)
    static let glow = Color(red: 1.0, green: 0.900, blue: 0.450)
}

enum Typography {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static let title = display(28)
    static let heading = Font.system(size: 20, weight: .bold, design: .rounded)
    static let body = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let caption = Font.system(size: 13, weight: .semibold, design: .rounded)
    static let small = Font.system(size: 11, weight: .bold, design: .rounded)
}

enum Layout {
    static let contentWidth: CGFloat = 520
}

extension View {
    /// Keeps phone-sized layouts readable on iPad.
    func contentColumn() -> some View {
        frame(maxWidth: Layout.contentWidth)
            .frame(maxWidth: .infinity)
    }
}
