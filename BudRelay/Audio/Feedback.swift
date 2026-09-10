import UIKit

@MainActor
enum Feedback {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func place() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func bloom() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func relay() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.8)
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warn() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
