import Foundation

/// One shared puzzle per calendar day. Same seed, same board, for everyone.
enum DailyBloom {
    static let epoch: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 1
        return Calendar(identifier: .gregorian).date(from: components) ?? Date(timeIntervalSince1970: 1_767_225_600)
    }()

    static func dayNumber(for date: Date = .now, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: epoch)
        let today = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        return max(1, days + 1)
    }

    static func seed(for day: Int) -> UInt64 {
        UInt64(day) &* 0x9E37_79B9_7F4A_7C15 &+ 0xB5D3
    }

    static let turns = 16

    static func level(for day: Int) -> LevelDef {
        var rng = SeededRNG(seed: seed(for: day) ^ 0xDA11)
        var kinds = FlowerKind.allCases
        kinds.shuffle(using: &rng)
        kinds = Array(kinds.prefix(4)).sorted { $0.growTurns < $1.growTurns }
        if !kinds.contains(where: { $0.growTurns == 1 }) {
            kinds[0] = .daisy
        }

        let weatherRoll = rng.int(below: 10)
        let weather: Weather = weatherRoll < 6 ? .mild : (weatherRoll < 8 ? .rain : .hotDay)

        let patterns: [[Cell]] = [
            [],
            [Cell(0, 0), Cell(0, 4), Cell(4, 0), Cell(4, 4)],
            [Cell(2, 2)],
            [Cell(1, 1), Cell(1, 3), Cell(3, 1), Cell(3, 3)],
            [Cell(0, 2), Cell(4, 2)],
        ]
        let blocked = patterns[rng.int(below: patterns.count)]

        var preset: [PresetPlant] = []
        let presetCount = rng.int(below: 3)
        var candidates = Board.allCells.filter { !blocked.contains($0) }
        candidates.shuffle(using: &rng)
        for cell in candidates.prefix(presetCount) {
            let kind = kinds[rng.int(below: kinds.count)]
            preset.append(PresetPlant(cell: cell, kind: kind, turns: kind.growTurns))
        }

        let chapter = ChapterID.allCases[day % ChapterID.allCases.count]
        return LevelDef(
            id: 1_000 + day,
            chapter: chapter,
            goals: [.chain(6)],
            turns: turns,
            kinds: kinds,
            weather: weather,
            blocked: blocked,
            preset: preset,
            dry: [],
            stars: StarThresholds(two: 99, three: 99),
            grants: weather == .hotDay ? [.water: 3] : [:],
            hints: 1
        )
    }

    static func title(for day: Int) -> String {
        let names = [
            "Summer Color Bed", "Morning Relay", "Neighbour's Corner", "Tulip Terrace", "Bee Lane",
            "Quiet Bloom", "Sunflower Row", "Rain Day Beds", "Lantern Walk", "Old Bench Garden",
            "Schoolyard Mix", "Lakeside Planters", "Rooftop Rows", "Rose Cart", "Marigold Path",
        ]
        return names[day % names.count]
    }
}
