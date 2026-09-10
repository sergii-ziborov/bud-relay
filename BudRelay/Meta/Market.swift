import Foundation

struct Order: Hashable, Sendable, Identifiable {
    let id: Int
    let name: String
    let from: String
    let needs: [FlowerKind: Int]
    let coins: Int
    let decor: DecorID?

    var needsList: [(FlowerKind, Int)] {
        needs.sorted { $0.key.value > $1.key.value }.map { ($0.key, $0.value) }
    }
}

struct MarketState: Hashable, Codable, Sendable {
    var activeOrders: [Int] = [0, 1, 2]
    var nextOrder: Int = 3
    var completed: Int = 0
}

enum MarketCatalog {
    static let orders: [Order] = [
        Order(id: 0, name: "Spring Cheer", from: "Evelyn", needs: [.tulip: 2, .daisy: 3], coins: 90, decor: nil),
        Order(id: 1, name: "Sunny Smiles", from: "Tomas", needs: [.sunflower: 2, .lavender: 1], coins: 120, decor: nil),
        Order(id: 2, name: "New Beginnings", from: "Ms. Adeyemi", needs: [.daisy: 4], coins: 70, decor: nil),
        Order(id: 3, name: "Classroom Vase", from: "Ms. Adeyemi", needs: [.tulip: 3, .lavender: 2], coins: 140, decor: nil),
        Order(id: 4, name: "Bee Bouquet", from: "Jonah", needs: [.lavender: 3, .sunflower: 1], coins: 150, decor: nil),
        Order(id: 5, name: "Market Bunch", from: "Mara", needs: [.rose: 2, .daisy: 2], coins: 180, decor: nil),
        Order(id: 6, name: "Golden Hour", from: "Tomas", needs: [.marigold: 3, .sunflower: 2], coins: 170, decor: nil),
        Order(id: 7, name: "Bench Warming", from: "Evelyn", needs: [.tulip: 4, .rose: 1], coins: 190, decor: .lantern),
        Order(id: 8, name: "Lakeside Table", from: "Priya", needs: [.lavender: 2, .marigold: 2, .daisy: 2], coins: 200, decor: nil),
        Order(id: 9, name: "Florist's Favourite", from: "Mara", needs: [.rose: 3, .lavender: 2], coins: 260, decor: nil),
        Order(id: 10, name: "Harvest Crate", from: "Priya", needs: [.sunflower: 4, .marigold: 2], coins: 240, decor: .birdhouse),
        Order(id: 11, name: "Winter Store", from: "Evelyn", needs: [.rose: 2, .tulip: 2, .sunflower: 2, .lavender: 2], coins: 320, decor: nil),
    ]

    static func order(_ id: Int) -> Order {
        orders[id % orders.count]
    }

    static func seedPrice(_ kind: FlowerKind) -> Int {
        switch kind {
        case .daisy: 40
        case .tulip: 70
        case .lavender: 100
        case .sunflower: 120
        case .marigold: 80
        case .rose: 150
        }
    }

    static let decorForSale: [DecorID] = DecorID.allCases.filter { $0.price != nil }
}
