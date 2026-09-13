import Foundation

/// Every flower in the garden. Numeric values are game rules; the journal fields
/// below are the real-world notes shown in the greenhouse encyclopedia.
enum FlowerKind: String, CaseIterable, Codable, Identifiable, Sendable, Hashable, CodingKeyRepresentable {
    case daisy
    case tulip
    case sunflower
    case lavender
    case rose
    case marigold
    case daffodil
    case hydrangea
    case aster
    case peony
    case poppy
    case iris

    var id: String { rawValue }

    var name: String {
        switch self {
        case .daisy: "Daisy"
        case .tulip: "Tulip"
        case .sunflower: "Sunflower"
        case .lavender: "Lavender"
        case .rose: "Rose"
        case .marigold: "Marigold"
        case .daffodil: "Daffodil"
        case .hydrangea: "Hydrangea"
        case .aster: "Aster"
        case .peony: "Peony"
        case .poppy: "Poppy"
        case .iris: "Iris"
        }
    }

    var pluralName: String {
        switch self {
        case .daisy: "Daisies"
        case .peony: "Peonies"
        case .poppy: "Poppies"
        case .iris: "Irises"
        default: "\(name)s"
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
        case .daffodil: 2
        case .hydrangea: 4
        case .aster: 4
        case .peony: 6
        case .poppy: 2
        case .iris: 4
        }
    }

    /// Care points handed to each orthogonal neighbour bud when this flower blooms.
    var relayPower: Int {
        switch self {
        case .tulip, .iris: 2
        default: 1
        }
    }

    /// Hydrangea reaches all eight plots around it; other blooms relay in a cross.
    func relayNeighbors(of cell: Cell) -> [Cell] {
        self == .hydrangea ? Board.surroundingNeighbors(of: cell) : Board.neighbors(of: cell)
    }

    /// Turns a bloom stays on the plot before it is harvested.
    var bloomStay: Int {
        switch self {
        case .marigold, .aster: 2
        default: 1
        }
    }

    /// Peonies are slow to prepare but contribute two stems to the harvest basket.
    var harvestYield: Int { self == .peony ? 2 : 1 }

    /// Coins a single harvested flower fetches when sold outright.
    var value: Int {
        switch self {
        case .daisy: 4
        case .tulip: 6
        case .sunflower: 10
        case .lavender: 7
        case .rose: 12
        case .marigold: 5
        case .daffodil: 7
        case .hydrangea: 11
        case .aster: 9
        case .peony: 16
        case .poppy: 8
        case .iris: 13
        }
    }

    /// Flowers that count toward a pollinator bonus when they bloom together with lavender.
    var pollinatorFriendly: Bool {
        switch self {
        case .daisy, .sunflower, .lavender, .daffodil, .aster, .poppy: true
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
        case .daffodil: "Quick Spring Bloom"
        case .hydrangea: "Wide Relay"
        case .aster: "Bee Haven"
        case .peony: "Grand Harvest"
        case .poppy: "Meadow Spark"
        case .iris: "Measured Relay"
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
        case .daffodil: "Blooms in two turns: fast enough to start a relay, patient enough to help you time it."
        case .hydrangea: "Reaches diagonal buds as well as orthogonal neighbours when it blooms."
        case .aster: "Its bloom stays for two turns and can join lavender in bringing a bee visit."
        case .peony: "Needs six turns, but every harvested peony adds two flowers to the basket."
        case .poppy: "A quick two-cycle flower that helps a mixed pollinator relay get moving."
        case .iris: "Takes four cycles, then hands two care points to every adjacent bud."
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
        case .daffodil: "The first bright note of spring."
        case .hydrangea: "A whole cloud of colour."
        case .aster: "Keeps the garden buzzing late."
        case .peony: "Patience opens into abundance."
        case .poppy: "A bright pause in the meadow."
        case .iris: "Strong roots. A graceful relay."
        }
    }

    var scientificName: String {
        switch self {
        case .daisy: "Bellis perennis"
        case .tulip: "Tulipa (garden hybrids)"
        case .sunflower: "Helianthus annuus"
        case .lavender: "Lavandula angustifolia"
        case .rose: "Rosa (garden hybrids)"
        case .marigold: "Tagetes patula"
        case .daffodil: "Narcissus pseudonarcissus"
        case .hydrangea: "Hydrangea macrophylla"
        case .aster: "Symphyotrichum novi-belgii"
        case .peony: "Paeonia lactiflora"
        case .poppy: "Papaver rhoeas"
        case .iris: "Iris germanica (garden hybrids)"
        }
    }

    var familyName: String {
        switch self {
        case .daisy, .sunflower, .marigold, .aster: "Daisy family · Asteraceae"
        case .tulip: "Lily family · Liliaceae"
        case .lavender: "Mint family · Lamiaceae"
        case .rose: "Rose family · Rosaceae"
        case .daffodil: "Amaryllis family · Amaryllidaceae"
        case .hydrangea: "Hydrangea family · Hydrangeaceae"
        case .peony: "Peony family · Paeoniaceae"
        case .poppy: "Poppy family · Papaveraceae"
        case .iris: "Iris family · Iridaceae"
        }
    }

    var bloomSeason: String {
        switch self {
        case .tulip, .daffodil: "Spring"
        case .peony: "Late spring–early summer"
        case .daisy, .rose, .lavender, .hydrangea: "Late spring–summer"
        case .sunflower, .marigold: "Summer–early autumn"
        case .aster: "Late summer–autumn"
        case .poppy: "Late spring–summer"
        case .iris: "Spring–early summer"
        }
    }

    var nativeNote: String {
        switch self {
        case .daisy: "Native across much of Europe and western Asia; naturalized much farther afield."
        case .tulip: "Wild tulips range from southeastern Europe through Central Asia; garden tulips are cultivated hybrids."
        case .sunflower: "Native to North America and cultivated worldwide for seed, oil, and ornament."
        case .lavender: "Native to the Mediterranean region and happiest in bright, freely draining sites."
        case .rose: "The genus occurs across the Northern Hemisphere; garden roses combine many cultivated lineages."
        case .marigold: "Native to Mexico and Central America and now a familiar warm-season annual in gardens worldwide."
        case .daffodil: "Native to western Europe; its bulbs rest underground between growing seasons."
        case .hydrangea: "Native to Japan; many garden forms were selected for their large flower heads."
        case .aster: "Native to eastern North America, where its late flowers feed many visiting insects."
        case .peony: "Native to parts of East Asia and long cultivated as a durable garden perennial."
        case .poppy: "Native across parts of Europe, North Africa, and western Asia; now familiar in disturbed ground and meadows farther afield."
        case .iris: "The bearded iris has Mediterranean and European ancestry; most garden forms are long-selected hybrids."
        }
    }

    var gardenRole: String {
        switch self {
        case .daisy: "Low edging and open, pollinator-friendly patches."
        case .tulip: "Spring colour in beds and containers."
        case .sunflower: "Tall structure, edible seed heads, and a landing place for insects and birds."
        case .lavender: "Aromatic edging for sunny paths and pollinator beds."
        case .rose: "A long-lived focal shrub and classic cutting flower."
        case .marigold: "Warm-season edging with a long run of bright flowers."
        case .daffodil: "Early colour beneath deciduous shrubs and in naturalized drifts."
        case .hydrangea: "A generous flowering shrub for sheltered borders."
        case .aster: "Late-season colour when many summer flowers are fading."
        case .peony: "A long-lived border anchor and generous early-summer cut flower."
        case .poppy: "Loose meadow planting and open sunny beds where its fine stems can move in the breeze."
        case .iris: "Architectural leaves and a strong spring accent along paths and sunny borders."
        }
    }

    var careNote: String {
        switch self {
        case .daisy: "Sun or light shade; allow ordinary soil to drain between waterings."
        case .tulip: "Plant bulbs in autumn in a sunny, well-drained position."
        case .sunflower: "Give it full sun, room for roots, and support where tall stems meet wind."
        case .lavender: "Prioritize sun and drainage; rich, waterlogged soil shortens its life."
        case .rose: "Most garden roses flower best with sun, airflow, deep watering, and seasonal pruning."
        case .marigold: "Sun and regular deadheading keep new flowers coming through warm weather."
        case .daffodil: "Let the leaves remain after flowering until they yellow; they replenish the bulb."
        case .hydrangea: "Morning sun with afternoon shelter and evenly moist soil suits many bigleaf hydrangeas."
        case .aster: "Sun and good airflow support sturdy growth and a strong late display."
        case .peony: "Plant the crown shallowly in sun and give the clump time; established plants dislike disturbance."
        case .poppy: "Sow on open, lightly worked soil in sun; avoid smothering the tiny seedlings with deep mulch."
        case .iris: "Keep the top of the rhizome near the soil surface, give it sun, and divide crowded clumps after flowering."
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
        case .daffodil:
            "A daffodil's yellow trumpet is a corona surrounded by six petal-like tepals."
        case .hydrangea:
            "A hydrangea flower head is a community of many small flowers, not one giant bloom."
        case .aster:
            "Asters flower late in the season, when their nectar can be especially useful to visiting insects."
        case .peony:
            "A well-sited peony can return for decades, growing slowly into a broad and dependable clump."
        case .poppy:
            "Poppy petals are thin and often short-lived, while the seed capsule that follows can remain standing much longer."
        case .iris:
            "The three upright standards and three lower falls give many iris flowers their distinctive layered shape."
        }
    }

    var journalEntries: [String] {
        let extra: [String]
        switch self {
        case .daisy:
            extra = ["What looks like one flower is a head made of many tiny florets.", "Its familiar English name is often linked with 'day's eye', reflecting the flower's daily opening habit."]
        case .tulip:
            extra = ["A tulip bulb stores the energy needed for the next spring shoot.", "Modern garden tulips come from centuries of selection and crossing among several species."]
        case .sunflower:
            extra = ["The dark centre is packed with many individual disk florets.", "As a flower head matures, its developing seeds become food for finches and other birds."]
        case .lavender:
            extra = ["Its fragrant oils are held in tiny glands on leaves and flowers.", "The narrow, grey-green leaves help the plant cope with sunny, relatively dry conditions."]
        case .rose:
            extra = ["Rose hips are the fruit that forms after a pollinated flower.", "Prickles on rose stems are outgrowths of the outer stem tissue rather than true thorns."]
        case .marigold:
            extra = ["Each flower head contains many small florets, as in other members of the daisy family.", "Removing old flower heads redirects the plant toward making more blooms instead of seed."]
        case .daffodil:
            extra = ["The bulb contains a compact store of food and a developing shoot.", "Daffodils contain compounds that make the bulbs unpalatable and unsafe to eat."]
        case .hydrangea:
            extra = ["In some bigleaf cultivars, soil chemistry influences whether pigments appear bluer or pinker.", "The showy outer parts of many heads are enlarged sepals surrounding small fertile flowers."]
        case .aster:
            extra = ["Its name comes from an ancient word for star, matching the radiating flower heads.", "Many North American plants once called asters are now classified in the genus Symphyotrichum."]
        case .peony:
            extra = ["Large peony blooms may need a ring or neighbouring stems for support after rain.", "Many peonies need a winter chill before they can begin another strong season of growth."]
        case .poppy:
            extra = ["A mature capsule releases many very small seeds through pores below its top.", "Bees visit poppies mainly for pollen because the flowers do not offer nectar."]
        case .iris:
            extra = ["Bearded irises spread through thick horizontal rhizomes near the soil surface.", "The coloured beard on each fall helps guide visiting insects toward the flower's centre."]
        }
        return [journalFact] + extra
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
        case .daffodil: ["Golden Trumpet", "Cream Daffodil", "Apricot Cup", "White Star"]
        case .hydrangea: ["Blue Mophead", "Pink Mophead", "Violet Lacecap", "Snowball"]
        case .aster: ["New York Aster", "Rose Aster", "Blue Aster", "White Aster"]
        case .peony: ["Blush Peony", "Coral Peony", "Crimson Peony", "Ivory Peony"]
        case .poppy: ["Field Poppy", "Salmon Poppy", "Ivory Poppy", "Plum Poppy"]
        case .iris: ["Blue Bearded Iris", "Amber Iris", "White Iris", "Violet Iris"]
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
        case .fertilizer: "A growing bud yields one extra flower at harvest."
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
