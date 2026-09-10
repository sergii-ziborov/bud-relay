import Foundation

/// The six flowers of the 1.0 garden. Every value here is a game rule, not botany.
enum FlowerKind: String, CaseIterable, Codable, Identifiable, Sendable, Hashable, CodingKeyRepresentable {
    case daisy
    case tulip
    case sunflower
    case lavender
    case rose
    case marigold

    var id: String { rawValue }

    var name: String {
        switch self {
        case .daisy: "Daisy"
        case .tulip: "Tulip"
        case .sunflower: "Sunflower"
        case .lavender: "Lavender"
        case .rose: "Rose"
        case .marigold: "Marigold"
        }
    }

    /// Care cycles a fresh bud needs before it blooms. Slow flowers can wait for a bigger relay.
    var growTurns: Int {
        switch self {
        case .daisy: 1
        case .tulip: 3
        case .sunflower: 4
        case .lavender: 3
        case .rose: 5
        case .marigold: 3
        }
    }

    /// Care points handed to each orthogonal neighbour bud when this flower blooms.
    var relayPower: Int {
        switch self {
        case .tulip: 2
        default: 1
        }
    }

    /// Turns a bloom stays on the plot before it is harvested.
    var bloomStay: Int {
        switch self {
        case .marigold: 2
        default: 1
        }
    }

    /// Coins a single harvested flower fetches when sold outright.
    var value: Int {
        switch self {
        case .daisy: 4
        case .tulip: 6
        case .sunflower: 10
        case .lavender: 7
        case .rose: 12
        case .marigold: 5
        }
    }

    /// Flowers that count toward a pollinator bonus when they bloom together with lavender.
    var pollinatorFriendly: Bool {
        switch self {
        case .daisy, .sunflower, .lavender: true
        default: false
        }
    }

    var trait: String {
        switch self {
        case .daisy: "Fast Bloomer"
        case .tulip: "Strong Relay"
        case .sunflower: "High Value"
        case .lavender: "Pollinator Favorite"
        case .rose: "Bouquet Flower"
        case .marigold: "Stays Longer"
        }
    }

    var traitDetail: String {
        switch self {
        case .daisy: "Blooms the turn it is planted. The trigger for a prepared bed."
        case .tulip: "Hands two care points to every neighbour when it blooms."
        case .sunflower: "Four turns to grow, and the market pays well for it."
        case .lavender: "Blooming next to daisies or sunflowers brings bees, and bees bring seeds."
        case .rose: "Five turns of patience. Florists ask for it by name."
        case .marigold: "Its bloom lingers for two turns and keeps neighbouring soil from drying."
        }
    }

    var motto: String {
        switch self {
        case .daisy: "Brings smiles everywhere."
        case .tulip: "Colors a brighter day."
        case .sunflower: "Reaches for a kinder tomorrow."
        case .lavender: "Small blooms. Big impact."
        case .rose: "A classic for a brighter world."
        case .marigold: "Brightens any garden."
        }
    }

    /// A short, careful note from the garden journal.
    var journalFact: String {
        switch self {
        case .daisy:
            "The common daisy closes its petals in the evening and opens them again in the morning light."
        case .tulip:
            "Tulips grow from bulbs planted in autumn. The bulb rests through winter and sends up a stem in spring."
        case .sunflower:
            "Young sunflower heads follow the sun across the sky during the day and turn back east overnight."
        case .lavender:
            "Lavender is a favourite of bees and other pollinators, which is why it is so often planted near vegetable beds."
        case .rose:
            "Roses have been grown in gardens for thousands of years, and many cultivated varieties are pruned each spring."
        case .marigold:
            "Marigolds are easy annuals that keep flowering until the first frost when spent blooms are removed."
        }
    }

    /// Cosmetic petal variants unlocked in the greenhouse. Index 0 is the common form.
    var variantNames: [String] {
        switch self {
        case .daisy: ["Common Daisy", "Pink Daisy", "Golden Daisy", "Twilight Daisy"]
        case .tulip: ["Red Tulip", "Yellow Tulip", "White Triumph", "Purple Tulip"]
        case .sunflower: ["Giant Sunflower", "Lemon Sunflower", "Rusty Sunflower", "Cream Sunflower"]
        case .lavender: ["English Lavender", "French Lavender", "Blue Lavender", "White Lavender"]
        case .rose: ["Pink Rose", "Peach Rose", "Crimson Rose", "Ivory Rose"]
        case .marigold: ["Orange Marigold", "Lemon Marigold", "Ruby Marigold", "Vanilla Marigold"]
        }
    }

    static let variantThresholds = [0, 15, 40, 80]
}

/// Consumable tools used during a level. None of them costs a turn.
enum Tool: String, CaseIterable, Codable, Identifiable, Sendable, Hashable, CodingKeyRepresentable {
    case water
    case compost
    case fertilizer
    case mulch
    case shears

    var id: String { rawValue }

    var name: String {
        switch self {
        case .water: "Watering Can"
        case .compost: "Compost"
        case .fertilizer: "Fertilizer"
        case .mulch: "Mulch"
        case .shears: "Shears"
        }
    }

    var shortName: String {
        switch self {
        case .water: "Water"
        case .compost: "Compost"
        case .fertilizer: "Fertilizer"
        case .mulch: "Mulch"
        case .shears: "Shears"
        }
    }

    var symbol: String {
        switch self {
        case .water: "drop.fill"
        case .compost: "leaf.arrow.circlepath"
        case .fertilizer: "sparkles"
        case .mulch: "square.stack.3d.up.fill"
        case .shears: "scissors"
        }
    }

    var effect: String {
        switch self {
        case .water: "Soaks a plot and its neighbours. Buds on dry soil do not grow."
        case .compost: "Enriches an empty plot. The next bud planted there starts one turn closer to bloom."
        case .fertilizer: "A growing bud yields two flowers at harvest instead of one."
        case .mulch: "Keeps a plot from drying out for the rest of the level."
        case .shears: "Removes a plant. You lose its flower."
        }
    }

    var price: Int {
        switch self {
        case .water: 30
        case .compost: 60
        case .fertilizer: 80
        case .mulch: 50
        case .shears: 40
        }
    }
}

enum Weather: String, Codable, Sendable, Hashable {
    case mild
    case hotDay
    case rain

    var name: String {
        switch self {
        case .mild: "Mild"
        case .hotDay: "Hot Day"
        case .rain: "Rain"
        }
    }

    var symbol: String {
        switch self {
        case .mild: "cloud.sun.fill"
        case .hotDay: "sun.max.fill"
        case .rain: "cloud.rain.fill"
        }
    }

    var note: String {
        switch self {
        case .mild: "Nothing dries out. Plant freely."
        case .hotDay: "Soil dries a step each turn. Buds on dry soil wait."
        case .rain: "Every plot stays wet all level."
        }
    }
}
