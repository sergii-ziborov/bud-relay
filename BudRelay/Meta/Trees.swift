import Foundation

/// Long-lived plants for the permanent estate. Trees do not enter the 5×5
/// relay puzzle: they are slow, personal landmarks that make the meta garden
/// read as a place rather than another level board.
enum TreeKind: String, CaseIterable, Codable, Identifiable, Sendable, Hashable {
    case apple
    case pear
    case cherry
    case lemon
    case maple
    case willow

    var id: String { rawValue }

    var name: String {
        switch self {
        case .apple: "Apple"
        case .pear: "Pear"
        case .cherry: "Cherry"
        case .lemon: "Lemon"
        case .maple: "Field Maple"
        case .willow: "White Willow"
        }
    }

    var scientificName: String {
        switch self {
        case .apple: "Malus domestica"
        case .pear: "Pyrus communis"
        case .cherry: "Prunus avium"
        case .lemon: "Citrus × limon"
        case .maple: "Acer campestre"
        case .willow: "Salix alba"
        }
    }

    var familyName: String {
        switch self {
        case .apple, .pear, .cherry: "Rose family · Rosaceae"
        case .lemon: "Rue family · Rutaceae"
        case .maple: "Soapberry family · Sapindaceae"
        case .willow: "Willow family · Salicaceae"
        }
    }

    var decor: DecorID {
        switch self {
        case .apple: .appleTree
        case .pear: .pearTree
        case .cherry: .cherryTree
        case .lemon: .lemonTree
        case .maple: .mapleTree
        case .willow: .willowTree
        }
    }

    var unlockLevel: Int {
        switch self {
        case .apple: 8
        case .pear: 16
        case .cherry: 24
        case .lemon: 32
        case .maple: 44
        case .willow: 52
        }
    }

    var season: String {
        switch self {
        case .apple, .pear, .cherry: "Spring blossom · late-summer/autumn fruit"
        case .lemon: "Flowers and fruit in more than one season in warm shelter"
        case .maple: "Spring flowers · golden autumn colour"
        case .willow: "Early spring catkins · summer shade"
        }
    }

    var gardenRole: String {
        switch self {
        case .apple: "A productive centrepiece for the shared orchard."
        case .pear: "An upright fruit tree that fits a narrower orchard edge."
        case .cherry: "Spring blossom for pollinators and a small summer harvest."
        case .lemon: "A fragrant container tree for the warm greenhouse yard."
        case .maple: "A resilient shade tree and long-lived habitat anchor."
        case .willow: "A moisture-loving landmark for the pond garden."
        }
    }

    var careNote: String {
        switch self {
        case .apple: "Give it sun, free-draining soil, and another compatible apple nearby when the cultivar needs cross-pollination."
        case .pear: "Plant in sun and water deeply while young; prune lightly to keep an open, healthy framework."
        case .cherry: "Choose sun and good drainage, and protect ripening fruit only with wildlife-safe netting."
        case .lemon: "Keep it bright and sheltered, water when the surface dries, and protect it from hard frost."
        case .maple: "Water through its first dry summers; an established field maple usually needs little intervention."
        case .willow: "Allow generous root room beside reliable moisture, well away from drains and small structures."
        }
    }

    var journalEntries: [String] {
        switch self {
        case .apple:
            ["Most named apples are propagated by grafting so a new tree keeps the fruit qualities of its parent cultivar.", "An apple grown from a pip is genetically new and may produce very different fruit.", "Old orchard trees provide blossom, fruit, cavities, and dead wood used by many species."]
        case .pear:
            ["Pear flowers open in clusters before the canopy is fully leafed out.", "Many pear cultivars crop more reliably with pollen from a compatible second tree.", "Pears are often picked firm and allowed to finish ripening after harvest."]
        case .cherry:
            ["Sweet cherries and many ornamental cherries belong to the genus Prunus.", "Their early blossom can be valuable to insects emerging in spring.", "Birds also value the fruit, so a community harvest is always partly shared."]
        case .lemon:
            ["The fragrant white flowers are often called citrus blossom.", "A healthy sheltered tree can carry buds, flowers, and fruit at the same time.", "Citrus roots need air as well as water, which is why a free-draining container mix matters."]
        case .maple:
            ["Field maple is a compact European maple often found in hedgerows.", "Its paired winged fruits spin as they fall and are commonly called keys or samaras.", "A mature native canopy moderates heat and gives birds a sheltered route through a garden."]
        case .willow:
            ["Willow catkins provide early pollen and nectar when relatively little else is flowering.", "Flexible young willow stems have long been woven into baskets and living structures.", "Willows transpire plenty of water and belong where their vigorous roots have room to spread."]
        }
    }

    var fruitColorName: String {
        switch self {
        case .apple: "red"
        case .pear: "gold"
        case .cherry: "cherry"
        case .lemon: "lemon"
        case .maple: "none"
        case .willow: "none"
        }
    }
}
