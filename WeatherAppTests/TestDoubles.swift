import Foundation
@testable import WeatherApp

struct MockLocationProvider: LocationProviding {
    var result: Result<LocationCoordinate, Error>

    func requestCurrentLocation() async throws -> LocationCoordinate {
        try result.get()
    }
}

struct MockWeatherProvider: WeatherProviding {
    var result: Result<WeatherSnapshot, Error>

    func fetchForecast(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot {
        try result.get()
    }
}

struct MockOverlayProvider: OverlayTextProviding {
    var result: Result<WeatherOverlay, Error>

    func fetchOverlay(for snapshot: WeatherSnapshot) async throws -> WeatherOverlay {
        try result.get()
    }
}

struct MockHTTPClient: HTTPClient {
    var result: Result<(Data, URLResponse), Error>

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try result.get()
    }
}
