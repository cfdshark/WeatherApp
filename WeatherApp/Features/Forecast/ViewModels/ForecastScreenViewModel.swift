import Combine
import Foundation
import SwiftUI

@MainActor
final class ForecastScreenViewModel: ObservableObject {
    @Published private(set) var state: ForecastScreenState = .idle

    private let locationProvider: LocationProviding
    private let weatherProvider: WeatherProviding
    private let overlayTextProvider: OverlayTextProviding

    init(
        locationProvider: LocationProviding,
        weatherProvider: WeatherProviding,
        overlayTextProvider: OverlayTextProviding
    ) {
        self.locationProvider = locationProvider
        self.weatherProvider = weatherProvider
        self.overlayTextProvider = overlayTextProvider
    }

    func loadForecast() async {
        state = .requestingPermission

        do {
            let coordinate = try await locationProvider.requestCurrentLocation()
            state = .loading

            var snapshot = try await weatherProvider.fetchForecast(for: coordinate)
            snapshot = await enrichSnapshot(snapshot)

            state = .loaded(snapshot)
        } catch let error as LocationError {
            state = .permissionDenied(message: error.userMessage)
        } catch let error as WeatherServiceError {
            state = .error(message: error.userMessage)
        } catch {
            state = .error(message: "Something went wrong while loading the forecast. Please try again.")
        }
    }

    private func enrichSnapshot(_ snapshot: WeatherSnapshot) async -> WeatherSnapshot {
        do {
            let overlay = try await overlayTextProvider.fetchOverlay(for: snapshot)
            return WeatherSnapshot(
                locationName: snapshot.locationName,
                coordinate: snapshot.coordinate,
                currentTemperatureCelsius: snapshot.currentTemperatureCelsius,
                primaryCondition: snapshot.primaryCondition,
                forecastDays: snapshot.forecastDays,
                overlay: overlay
            )
        } catch {
            return snapshot
        }
    }
}
