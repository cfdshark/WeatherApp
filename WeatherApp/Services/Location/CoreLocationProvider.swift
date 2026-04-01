import CoreLocation
import Foundation

enum LocationError: Error, Equatable {
    case servicesDisabled
    case permissionDenied
    case unableToDetermineLocation

    var userMessage: String {
        switch self {
        case .servicesDisabled:
            return "Location Services are turned off for this device."
        case .permissionDenied:
            return "Allow location access in Settings to load the forecast for your current area."
        case .unableToDetermineLocation:
            return "The app could not determine your location just now."
        }
    }
}

@MainActor
final class CoreLocationProvider: NSObject, CLLocationManagerDelegate, LocationProviding {
    private let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    private var locationContinuation: CheckedContinuation<LocationCoordinate, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestCurrentLocation() async throws -> LocationCoordinate {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return try await requestLocation()
        case .notDetermined:
            try await requestAuthorization()

            guard manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse else {
                throw LocationError.permissionDenied
            }

            return try await requestLocation()
        case .restricted, .denied:
            throw LocationError.permissionDenied
        @unknown default:
            throw LocationError.unableToDetermineLocation
        }
    }

    private func requestAuthorization() async throws {
        try await withCheckedThrowingContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    private func requestLocation() async throws -> LocationCoordinate {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                authorizationContinuation?.resume(returning: ())
                authorizationContinuation = nil
            case .restricted, .denied:
                authorizationContinuation?.resume(throwing: LocationError.permissionDenied)
                authorizationContinuation = nil
            case .notDetermined:
                break
            @unknown default:
                authorizationContinuation?.resume(throwing: LocationError.unableToDetermineLocation)
                authorizationContinuation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.first else {
                locationContinuation?.resume(throwing: LocationError.unableToDetermineLocation)
                locationContinuation = nil
                return
            }

            locationContinuation?.resume(
                returning: LocationCoordinate(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            )
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: mapLocationError(error, authorizationStatus: manager.authorizationStatus))
            locationContinuation = nil
        }
    }

    private func mapLocationError(_ error: Error, authorizationStatus: CLAuthorizationStatus) -> LocationError {
        if let clError = error as? CLError, clError.code == .denied {
            return authorizationStatus == .denied || authorizationStatus == .restricted
                ? .permissionDenied
                : .servicesDisabled
        }

        return .unableToDetermineLocation
    }
}
