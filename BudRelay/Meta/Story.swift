import Foundation

struct StoryLine: Hashable, Sendable {
    let speaker: String
    let text: String
}

struct StoryScene: Hashable, Sendable, Identifiable {
    let id: String
    let title: String
    let symbol: String
    let lines: [StoryLine]
}

enum StoryTrigger: Hashable, Sendable {
    case firstLaunch
    case levelCompleted(Int)
    case gardenGoal(GardenGoal)
}

enum StoryCatalog {
    static func scene(for trigger: StoryTrigger) -> StoryScene? {
        switch trigger {
        case .firstLaunch: return welcome
        case let .levelCompleted(id): return byLevel[id]
        case let .gardenGoal(goal): return byGardenGoal[goal]
        }
    }

    static let welcome = StoryScene(
        id: "welcome",
        title: "Green Neighbors",
        symbol: "leaf.fill",
        lines: [
            StoryLine(speaker: "Evelyn", text: "You found the old gate. Most people walk straight past it now."),
            StoryLine(speaker: "Evelyn", text: "There used to be gardens all through this district. Rooftops, the schoolyard, the park by the lake."),
            StoryLine(speaker: "Evelyn", text: "Nobody kept them up. The beds went to grass and the greenhouse door rusted shut."),
            StoryLine(speaker: "Evelyn", text: "A few of us still meet on Saturdays. We could use another pair of hands. Start with that little bed by the greenhouse."),
        ]
    )

    static let byLevel: [Int: StoryScene] = [
        3: StoryScene(
            id: "relay",
            title: "Care Momentum",
            symbol: "link",
            lines: [
                StoryLine(speaker: "Evelyn", text: "See how the whole bed comes alive once one corner does? Watering, weeding, bees moving from bloom to bloom."),
                StoryLine(speaker: "Evelyn", text: "Plant with the next bloom in mind, not just this one. A bud you set today is a gift to next week."),
            ]
        ),
        10: StoryScene(
            id: "chapter1",
            title: "Sunflowers Again",
            symbol: "sun.max.fill",
            lines: [
                StoryLine(speaker: "Evelyn", text: "There were always sunflowers along this fence. People stopped by after work and stayed until dark."),
                StoryLine(speaker: "Evelyn", text: "The compost bin was mine, years ago. Take it. Level leftovers make better soil than anything from a bag."),
                StoryLine(speaker: "Evelyn", text: "Tomas has been asking about the rooftop over the laundrette. Small planters, thin soil. Bring water."),
            ]
        ),
        15: StoryScene(
            id: "rooftop",
            title: "Thin Soil",
            symbol: "building.2.fill",
            lines: [
                StoryLine(speaker: "Tomas", text: "Up here the sun bakes the planters by noon. Mulch slows it down, but nothing beats a full can."),
                StoryLine(speaker: "Tomas", text: "Marigolds hold on longer than anything else I have tried. Give them a corner."),
            ]
        ),
        20: StoryScene(
            id: "chapter2",
            title: "A View Worth Climbing For",
            symbol: "sunset.fill",
            lines: [
                StoryLine(speaker: "Tomas", text: "The whole building came up for the first bloom. My neighbour brought chairs."),
                StoryLine(speaker: "Tomas", text: "The school across the street saw it from their windows. The teacher wants to talk to you."),
            ]
        ),
        22: StoryScene(
            id: "bees",
            title: "Small Wings",
            symbol: "ant.fill",
            lines: [
                StoryLine(speaker: "Ms. Adeyemi", text: "The children counted three bees all of last summer. Three."),
                StoryLine(speaker: "Ms. Adeyemi", text: "Lavender next to daisies and sunflowers. Let them see what a full bed sounds like."),
            ]
        ),
        30: StoryScene(
            id: "chapter3",
            title: "Field Notes",
            symbol: "graduationcap.fill",
            lines: [
                StoryLine(speaker: "Ms. Adeyemi", text: "Jonah keeps hives on the allotments. He built this bee hotel for the class. It belongs in your garden."),
                StoryLine(speaker: "Jonah", text: "Solitary bees, mostly. No honey, no stings, plenty of pollen. Put it somewhere sunny."),
                StoryLine(speaker: "Ms. Adeyemi", text: "And the flower market is opening again. Mara asked for roses."),
            ]
        ),
        35: StoryScene(
            id: "florist",
            title: "Bouquet Orders",
            symbol: "storefront.fill",
            lines: [
                StoryLine(speaker: "Mara", text: "I used to buy roses from this greenhouse before it closed. Bring me some and I will pay properly."),
                StoryLine(speaker: "Mara", text: "Fertilizer is worth the coins. Two flowers from one bud pays for itself on the first order."),
            ]
        ),
        40: StoryScene(
            id: "chapter4",
            title: "Open Again",
            symbol: "storefront.fill",
            lines: [
                StoryLine(speaker: "Mara", text: "First Saturday market in six years. We sold out by ten."),
                StoryLine(speaker: "Mara", text: "Priya from the park office left this rain barrel. She says the beds by the lake flood one week and crack the next."),
            ]
        ),
        45: StoryScene(
            id: "lakeside",
            title: "Weather Notes",
            symbol: "cloud.sun.rain.fill",
            lines: [
                StoryLine(speaker: "Priya", text: "Rain days are a gift. Plant everything and let the beds run."),
                StoryLine(speaker: "Priya", text: "Hot days are the test. Water before you plant, not after."),
            ]
        ),
        50: StoryScene(
            id: "chapter5",
            title: "The Path to the Water",
            symbol: "water.waves",
            lines: [
                StoryLine(speaker: "Priya", text: "People sit by the lake again. Somebody left a thank-you note on the bench."),
                StoryLine(speaker: "Evelyn", text: "That leaves the old botanical garden. It was the pride of the district. Take the herb spiral; it was always the first thing visitors saw."),
            ]
        ),
        55: StoryScene(
            id: "botanical",
            title: "Old Bones",
            symbol: "building.columns.fill",
            lines: [
                StoryLine(speaker: "Evelyn", text: "The beds here were laid out for long relays. One bloom used to run the whole length of the walk."),
                StoryLine(speaker: "Evelyn", text: "Tulips carry a bed. Daisies fill the gaps. Compost the slow ones."),
            ]
        ),
        60: StoryScene(
            id: "finale",
            title: "A Greener Tomorrow",
            symbol: "sparkles",
            lines: [
                StoryLine(speaker: "Evelyn", text: "The sundial is running again. Nobody fixed it; it just needed the ivy off."),
                StoryLine(speaker: "Tomas", text: "Half the district came for the opening. Jonah brought the bees, Mara brought the flowers, the kids brought the noise."),
                StoryLine(speaker: "Evelyn", text: "Small seeds. You planted them at the right time. That is all any gardener ever does."),
            ]
        ),
    ]

    static let byGardenGoal: [GardenGoal: StoryScene] = [
        .placeToSit: StoryScene(
            id: "bench",
            title: "Somebody Sat Down",
            symbol: "chair.lounge.fill",
            lines: [
                StoryLine(speaker: "Evelyn", text: "A bench changes a garden. It turns a place you look at into a place you stay."),
                StoryLine(speaker: "Evelyn", text: "Do not be surprised if you find neighbours on it before you do."),
            ]
        ),
        .beeHotel: StoryScene(
            id: "beehotel",
            title: "Guests",
            symbol: "ant.fill",
            lines: [
                StoryLine(speaker: "Jonah", text: "First tenants already. Mason bees, by the look of the mud caps."),
                StoryLine(speaker: "Jonah", text: "I will drop by with a few orders. Lavender pays in seeds now, not just coins."),
            ]
        ),
        .pollinatorBed: StoryScene(
            id: "pollinatorbed",
            title: "A Full Bed",
            symbol: "camera.macro",
            lines: [
                StoryLine(speaker: "Ms. Adeyemi", text: "The class counted forty-one bees this morning. They have stopped counting the butterflies."),
            ]
        ),
    ]
}
