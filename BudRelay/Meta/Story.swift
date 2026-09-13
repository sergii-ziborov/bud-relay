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

struct LoreEntry: Hashable, Sendable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let unlockLevel: Int
    let text: String
}

/// Persistent context for scenes that used to disappear after dismissal.
enum LoreCatalog {
    static let all: [LoreEntry] = [
        LoreEntry(id: "evelyn", title: "Evelyn Hart", subtitle: "Keeper of the old gate", symbol: "person.crop.circle.fill", unlockLevel: 1, text: "Evelyn helped establish Green Neighbors years ago and kept meeting every Saturday even after most beds closed. She remembers what grew where, but insists that a restored garden must belong to its new caretakers."),
        LoreEntry(id: "community", title: "Community Garden", subtitle: "The first open gate", symbol: "house.and.flag.fill", unlockLevel: 1, text: "The greenhouse yard was once the district's shared nursery. Its nearest courtyard becomes the starting point: a bench, a working path, four flowers, and a reason for neighbours to stop again."),
        LoreEntry(id: "tomas", title: "Tomas Vale", subtitle: "Rooftop caretaker", symbol: "person.crop.circle.fill", unlockLevel: 11, text: "Tomas manages the flats above the laundrette. He understands wind, reflected heat, shallow planters, and the quiet social power of carrying two chairs onto a roof."),
        LoreEntry(id: "rooftop", title: "Rooftop Garden", subtitle: "Thin soil, wide sky", symbol: "building.2.fill", unlockLevel: 11, text: "The roof receives fierce noon sun and very little shelter. Mulch, rain storage, and resilient flowers turn a forgotten utility space into the first garden visible from the school."),
        LoreEntry(id: "adeyemi", title: "Ms. Adeyemi", subtitle: "Teacher and field-note editor", symbol: "person.crop.circle.fill", unlockLevel: 21, text: "Ms. Adeyemi turns restoration work into observation: bee counts, bloom dates, sketches, and questions from the school gardening club. Her class begins the encyclopedia kept in the greenhouse."),
        LoreEntry(id: "jonah", title: "Jonah Reed", subtitle: "Pollinator steward", symbol: "person.crop.circle.fill", unlockLevel: 22, text: "Jonah keeps allotment hives and builds nesting blocks for solitary bees. He is careful to explain that a bee hotel needs dry shelter, replaceable stems, and nearby forage—not just a decorative roof."),
        LoreEntry(id: "schoolyard", title: "Schoolyard Garden", subtitle: "A living classroom", symbol: "graduationcap.fill", unlockLevel: 21, text: "The school replaces clipped lawn with mixed sunny beds. Children record what visits each flower and learn that biodiversity is created by variety, shelter, water, and patient maintenance."),
        LoreEntry(id: "mara", title: "Mara Chen", subtitle: "Florist and market organiser", symbol: "person.crop.circle.fill", unlockLevel: 31, text: "Mara once bought local stems from the greenhouse. Reopening her bouquet board connects puzzle harvests to neighbourhood requests and gives the restored beds a modest working economy."),
        LoreEntry(id: "market", title: "Greenhouse Market", subtitle: "The Saturday return", symbol: "storefront.fill", unlockLevel: 31, text: "Seed packets, useful supplies, cut flowers, and locally made garden pieces share the old greenhouse apron. Nothing waits on a real-time clock: the puzzle provides the rhythm."),
        LoreEntry(id: "priya", title: "Priya Nair", subtitle: "Lakeside park officer", symbol: "person.crop.circle.fill", unlockLevel: 41, text: "Priya reads water movement across the park. She brings a salvaged rain barrel and helps choose plants that can handle a wet week followed by a hot one."),
        LoreEntry(id: "lakeside", title: "Lakeside Park", subtitle: "Where water sets the pace", symbol: "water.waves", unlockLevel: 41, text: "Reeds, willow shade, iris, and raised paths reconnect the garden route with the lake. The aim is not to tame the edge, but to make room for people without erasing habitat."),
        LoreEntry(id: "botanical", title: "Old Botanical Garden", subtitle: "The district remembers", symbol: "building.columns.fill", unlockLevel: 51, text: "Long borders and old labels survive beneath ivy. Restoring the courtyard gathers every lesson—soil, timing, water, pollinators, commerce, and shared stewardship—without pretending the work ever truly ends."),
    ]
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
        5: StoryScene(
            id: "firsthelpers",
            title: "The Saturday List",
            symbol: "person.3.fill",
            lines: [
                StoryLine(speaker: "Evelyn", text: "Someone straightened the gate while we worked. Someone else left a kettle and six clean mugs."),
                StoryLine(speaker: "Evelyn", text: "A garden begins with plants, but it lasts because people notice what needs doing next."),
            ]
        ),
        8: StoryScene(
            id: "meadowgate",
            title: "Beyond the First Beds",
            symbol: "camera.macro",
            lines: [
                StoryLine(speaker: "Evelyn", text: "The grass beyond the path does not need to become another tidy bed. Let part of it stay loose."),
                StoryLine(speaker: "Evelyn", text: "Poppies, daisies, and a little bare soil will make a better meadow than a perfect green square."),
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
        12: StoryScene(
            id: "roofwind",
            title: "The Wind Test",
            symbol: "wind",
            lines: [
                StoryLine(speaker: "Tomas", text: "Anything light ends up two streets away. We anchor pots, group them for shelter, and water before the roof turns hot."),
                StoryLine(speaker: "Tomas", text: "The poppies can have the low corner. They bend better than they fight."),
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
        18: StoryScene(
            id: "roofchairs",
            title: "Two More Chairs",
            symbol: "chair.lounge.fill",
            lines: [
                StoryLine(speaker: "Tomas", text: "I put out two chairs. By sunset there were nine people and somebody had brought soup."),
                StoryLine(speaker: "Evelyn", text: "That is why we restore places, not displays."),
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
        25: StoryScene(
            id: "classledger",
            title: "Forty Questions",
            symbol: "books.vertical.fill",
            lines: [
                StoryLine(speaker: "Ms. Adeyemi", text: "The class has forty questions and three clipboards. We are calling that an encyclopedia."),
                StoryLine(speaker: "Jonah", text: "Start with what you can observe: flower shape, visitors, weather, and what changed since last week."),
            ]
        ),
        28: StoryScene(
            id: "orchardpromise",
            title: "Fruit for Someone Else",
            symbol: "tree.fill",
            lines: [
                StoryLine(speaker: "Evelyn", text: "An annual bed thanks you this season. A young tree may do its best work for someone you have not met yet."),
                StoryLine(speaker: "Ms. Adeyemi", text: "The children voted for an orchard. Apples first, then pears, and one cherry for the blossom."),
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
        33: StoryScene(
            id: "marketledger",
            title: "What a Stem Is Worth",
            symbol: "list.clipboard.fill",
            lines: [
                StoryLine(speaker: "Mara", text: "A fair price includes seed, water, compost, time, and the stems that never made the bucket."),
                StoryLine(speaker: "Mara", text: "We can sell flowers without pretending the people who grew them worked for free."),
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
        38: StoryScene(
            id: "greenhousekey",
            title: "The Greenhouse Key",
            symbol: "key.fill",
            lines: [
                StoryLine(speaker: "Mara", text: "The lock finally turned. Half the glass needs work, but the benches are sound."),
                StoryLine(speaker: "Evelyn", text: "Keep the field notes here. A restored place should remember how it was restored."),
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
        42: StoryScene(
            id: "irisbank",
            title: "Blue Along the Bank",
            symbol: "water.waves",
            lines: [
                StoryLine(speaker: "Priya", text: "The bank is damp without being drowned. Iris will mark that middle ground better than a fence."),
                StoryLine(speaker: "Priya", text: "Leave a clear way to the water. Maintenance is part of the design."),
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
        47: StoryScene(
            id: "pondvoices",
            title: "At the Water's Edge",
            symbol: "bird.fill",
            lines: [
                StoryLine(speaker: "Priya", text: "The birds arrived before the bench did. People came next, mostly to see what the birds were looking at."),
                StoryLine(speaker: "Jonah", text: "Keep one shallow edge and a stone above the waterline. Small visitors need a way out."),
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
        52: StoryScene(
            id: "willowcutting",
            title: "A Willow for the Pond",
            symbol: "tree.fill",
            lines: [
                StoryLine(speaker: "Priya", text: "This cutting came from the old lakeside willow after a winter storm."),
                StoryLine(speaker: "Evelyn", text: "Give it room. Restoring a garden also means deciding what should still be here in fifty years."),
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
        58: StoryScene(
            id: "sharedmap",
            title: "One Garden, Many Places",
            symbol: "map.fill",
            lines: [
                StoryLine(speaker: "Ms. Adeyemi", text: "The class drew the district as one garden: roofs, school, market, lake, and every path between them."),
                StoryLine(speaker: "Evelyn", text: "That is closer to the truth than any boundary line."),
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
        .diverseBorders: StoryScene(
            id: "manykinds",
            title: "Not Just One Good Flower",
            symbol: "camera.macro",
            lines: [
                StoryLine(speaker: "Jonah", text: "Eight kinds means different shapes and different weeks of bloom. A visitor that misses one still finds another."),
                StoryLine(speaker: "Ms. Adeyemi", text: "The encyclopedia finally needs an index."),
            ]
        ),
        .youngOrchard: StoryScene(
            id: "youngorchard",
            title: "Future Shade",
            symbol: "tree.fill",
            lines: [
                StoryLine(speaker: "Evelyn", text: "Three young trees do not look like an orchard yet. That is exactly why planting them matters."),
                StoryLine(speaker: "Tomas", text: "I put their watering days on the Saturday board."),
            ]
        ),
        .pondRetreat: StoryScene(
            id: "pondretreat",
            title: "A Cooler Corner",
            symbol: "water.waves",
            lines: [
                StoryLine(speaker: "Priya", text: "The willow breaks the afternoon glare, the pond holds insects, and the bench keeps people quiet long enough to notice both."),
            ]
        ),
    ]
}
