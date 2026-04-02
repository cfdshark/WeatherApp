import SwiftUI
import UIKit

struct ForecastScreen: View {
    @StateObject private var viewModel: ForecastScreenViewModel
    @Environment(\.openURL) private var openURL
    @State private var navigationPath: [ForecastDay] = []

    init(viewModel: ForecastScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
            .navigationDestination(for: ForecastDay.self) { day in
                if case .loaded(let snapshot) = viewModel.state {
                    ForecastDetailScreen(snapshot: snapshot, selectedDay: day)
                } else {
                    EmptyView()
                }
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
            ForecastListView(days: snapshot.forecastDays) { day in
                navigationPath.append(day)
            }
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
            currentFeelsLikeTemperatureCelsius: 21,
            primaryDescription: "Broken Clouds",
            humidityPercentage: 62,
            windSpeedKilometersPerHour: 18,
            precipitationProbabilityPercentage: 35,
            primaryCondition: .cloudy,
            primaryIcon: .cloud,
            forecastDays: [
                ForecastDay(
                    date: .now,
                    temperatureCelsius: 20,
                    feelsLikeTemperatureCelsius: 19,
                    minTemperatureCelsius: 15,
                    maxTemperatureCelsius: 22,
                    description: "Sunny",
                    humidityPercentage: 45,
                    windSpeedKilometersPerHour: 14,
                    precipitationProbabilityPercentage: 5,
                    condition: .sunny,
                    icon: .sun,
                    hourlyForecasts: previewHours(baseDate: .now, condition: .sunny, icon: .sun)
                ),
                ForecastDay(
                    date: .now.addingTimeInterval(86_400),
                    temperatureCelsius: 23,
                    feelsLikeTemperatureCelsius: 22,
                    minTemperatureCelsius: 16,
                    maxTemperatureCelsius: 24,
                    description: "Sunny",
                    humidityPercentage: 43,
                    windSpeedKilometersPerHour: 12,
                    precipitationProbabilityPercentage: 8,
                    condition: .sunny,
                    icon: .sun,
                    hourlyForecasts: previewHours(baseDate: .now.addingTimeInterval(86_400), condition: .sunny, icon: .sun)
                ),
                ForecastDay(
                    date: .now.addingTimeInterval(172_800),
                    temperatureCelsius: 27,
                    feelsLikeTemperatureCelsius: 26,
                    minTemperatureCelsius: 18,
                    maxTemperatureCelsius: 28,
                    description: "Sunny",
                    humidityPercentage: 40,
                    windSpeedKilometersPerHour: 16,
                    precipitationProbabilityPercentage: 10,
                    condition: .sunny,
                    icon: .sun,
                    hourlyForecasts: previewHours(baseDate: .now.addingTimeInterval(172_800), condition: .sunny, icon: .sun)
                ),
                ForecastDay(
                    date: .now.addingTimeInterval(259_200),
                    temperatureCelsius: 28,
                    feelsLikeTemperatureCelsius: 27,
                    minTemperatureCelsius: 19,
                    maxTemperatureCelsius: 29,
                    description: "Sunny",
                    humidityPercentage: 38,
                    windSpeedKilometersPerHour: 18,
                    precipitationProbabilityPercentage: 12,
                    condition: .sunny,
                    icon: .sun,
                    hourlyForecasts: previewHours(baseDate: .now.addingTimeInterval(259_200), condition: .sunny, icon: .sun)
                ),
                ForecastDay(
                    date: .now.addingTimeInterval(345_600),
                    temperatureCelsius: 30,
                    feelsLikeTemperatureCelsius: 29,
                    minTemperatureCelsius: 20,
                    maxTemperatureCelsius: 31,
                    description: "Sunny",
                    humidityPercentage: 35,
                    windSpeedKilometersPerHour: 20,
                    precipitationProbabilityPercentage: 15,
                    condition: .sunny,
                    icon: .sun,
                    hourlyForecasts: previewHours(baseDate: .now.addingTimeInterval(345_600), condition: .sunny, icon: .sun)
                )
            ]
        )
    }

    private func previewHours(baseDate: Date, condition: WeatherConditionCategory, icon: WeatherIconAsset) -> [ForecastHour] {
        let start = Calendar.current.startOfDay(for: baseDate).addingTimeInterval(9 * 3_600)

        return stride(from: 0, to: 6, by: 1).map { index in
            ForecastHour(
                date: start.addingTimeInterval(TimeInterval(index * 3 * 3_600)),
                temperatureCelsius: 19 + index,
                feelsLikeTemperatureCelsius: 18 + index,
                humidityPercentage: 48 - index,
                windSpeedKilometersPerHour: 10 + index,
                precipitationProbabilityPercentage: 5 + (index * 2),
                description: "Sunny",
                condition: condition,
                icon: icon
            )
        }
    }
}
