import Foundation

protocol OverlayTextProviding {
    func fetchOverlay(for snapshot: WeatherSnapshot) async throws -> WeatherOverlay
}
