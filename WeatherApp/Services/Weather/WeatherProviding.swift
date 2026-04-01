import Foundation

protocol WeatherProviding {
    func fetchForecast(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot
}
