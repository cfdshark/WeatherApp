import Foundation

struct StubOverlayTextProvider: OverlayTextProviding {
    func fetchOverlay(for snapshot: WeatherSnapshot) async throws -> WeatherOverlay {
        WeatherOverlay(
            title: "Current outlook",
            message: "Live forecast is active for \(snapshot.locationName). Connect an overlay API to replace this development placeholder."
        )
    }
}
