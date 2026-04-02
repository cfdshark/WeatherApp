import Combine
import Foundation
import SwiftUI

@MainActor
final class ForecastScreenViewModel: ObservableObject {
    @Published private(set) var state: ForecastScreenState = .idle

    private let locationProvider: LocationProviding
    private let weatherProvider: WeatherProviding

    init(
        locationProvider: LocationProviding,
        weatherProvider: WeatherProviding
    ) {
        self.locationProvider = locationProvider
        self.weatherProvider = weatherProvider
    }

    func loadForecast() async {
        state = .requestingPermission

        do {
            let coordinate = try await locationProvider.requestCurrentLocation()
            state = .loading

            let snapshot = try await weatherProvider.fetchForecast(for: coordinate)
            state = .loaded(snapshot)
        } catch let error as LocationError {
            state = .permissionDenied(message: error.userMessage)
        } catch let error as WeatherServiceError {
            state = .error(message: error.userMessage)
        } catch {
            state = .error(message: "Something went wrong while loading the forecast. Please try again.")
        }
    }

}
