import SwiftUI
import UIKit

struct ForecastScreen: View {
    @StateObject private var viewModel: ForecastScreenViewModel
    @Environment(\.openURL) private var openURL

    init(viewModel: ForecastScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            WeatherBackgroundView(category: backgroundCategory)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    content
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task {
            guard case .idle = viewModel.state else { return }
            await viewModel.loadForecast()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ForecastLoadingView(
                title: "Preparing forecast",
                subtitle: "Weather data will appear as soon as setup finishes."
            )
        case .requestingPermission:
            ForecastLoadingView(
                title: "Requesting your location",
                subtitle: "WeatherApp needs your current location to fetch the correct forecast."
            )
        case .loading:
            ForecastLoadingView(
                title: "Loading weather",
                subtitle: "Fetching the latest 5 day forecast."
            )
        case .loaded(let snapshot):
            ForecastHeaderView(snapshot: snapshot)
            ForecastListView(days: snapshot.forecastDays)
        case .permissionDenied(let message):
            ForecastErrorView(
                title: "Location required",
                message: message,
                buttonTitle: "Open Settings",
                action: openSettings
            )
        case .error(let message):
            ForecastErrorView(
                title: "Unable to load forecast",
                message: message,
                buttonTitle: "Try Again",
                action: reload
            )
        }
    }

    private var backgroundCategory: WeatherConditionCategory {
        if case .loaded(let snapshot) = viewModel.state {
            return snapshot.primaryCondition
        }

        return .cloudy
    }

    private func reload() {
        Task {
            await viewModel.loadForecast()
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

#Preview {
    ForecastScreen(
        viewModel: ForecastScreenViewModel(
            locationProvider: PreviewLocationProvider(),
            weatherProvider: PreviewWeatherProvider()
        )
    )
}

private struct PreviewLocationProvider: LocationProviding {
    func requestCurrentLocation() async throws -> LocationCoordinate {
        LocationCoordinate(latitude: -26.2041, longitude: 28.0473)
    }
}

private struct PreviewWeatherProvider: WeatherProviding {
    func fetchForecast(for coordinate: LocationCoordinate) async throws -> WeatherSnapshot {
        WeatherSnapshot(
            locationName: "Johannesburg",
            coordinate: coordinate,
            currentTemperatureCelsius: 23,
            primaryCondition: .cloudy,
            forecastDays: [
                ForecastDay(date: .now, temperatureCelsius: 20, condition: .sunny),
                ForecastDay(date: .now.addingTimeInterval(86_400), temperatureCelsius: 23, condition: .sunny),
                ForecastDay(date: .now.addingTimeInterval(172_800), temperatureCelsius: 27, condition: .sunny),
                ForecastDay(date: .now.addingTimeInterval(259_200), temperatureCelsius: 28, condition: .sunny),
                ForecastDay(date: .now.addingTimeInterval(345_600), temperatureCelsius: 30, condition: .sunny)
            ]
        )
    }
}
