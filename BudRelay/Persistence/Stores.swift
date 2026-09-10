import Foundation

final class ProgressStore: Sendable {
    private let url: URL

    init(fileManager: FileManager = .default, filename: String = "progress.json") {
        let folder = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("BudRelay", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        url = folder.appendingPathComponent(filename)
    }

    func load() -> ProgressState {
        guard let data = try? Data(contentsOf: url) else { return .fresh }
        return (try? JSONDecoder().decode(ProgressState.self, from: data)) ?? .fresh
    }

    func save(_ state: ProgressState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: url, options: [.atomic])
    }

    func wipe() {
        try? FileManager.default.removeItem(at: url)
    }
}
