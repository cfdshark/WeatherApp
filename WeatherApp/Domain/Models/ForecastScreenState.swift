import Foundation

enum ForecastScreenState: Equatable {
    case idle
    case requestingPermission
    case loading
    case loaded(WeatherSnapshot)
    case permissionDenied(message: String)
    case error(message: String)
}
