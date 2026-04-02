import XCTest
@testable import WeatherApp

@MainActor
final class ForecastScreenViewModelTests: XCTestCase {
    func testLoadForecastPublishesLoadedStateWhenRequestsSucceed() async {
        let snapshot = WeatherSnapshot(
            locationName: "Cape Town",
            coordinate: LocationCoordinate(latitude: -33.9249, longitude: 18.4241),
            currentTemperatureCelsius: 18,
            primaryCondition: .cloudy,
            forecastDays: [
                ForecastDay(date: .now, temperatureCelsius: 18, condition: .cloudy)
            ]
        )

        let viewModel = ForecastScreenViewModel(
            locationProvider: MockLocationProvider(result: .success(snapshot.coordinate)),
            weatherProvider: MockWeatherProvider(result: .success(snapshot))
        )

        await viewModel.loadForecast()

        guard case .loaded(let loadedSnapshot) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedSnapshot.locationName, "Cape Town")
        XCTAssertEqual(loadedSnapshot.forecastDays.count, 1)
    }

    func testLoadForecastPublishesPermissionDeniedState() async {
        let viewModel = ForecastScreenViewModel(
            locationProvider: MockLocationProvider(result: .failure(LocationError.permissionDenied)),
            weatherProvider: MockWeatherProvider(result: .failure(WeatherServiceError.invalidURL))
        )

        await viewModel.loadForecast()

        guard case .permissionDenied(let message) = viewModel.state else {
            return XCTFail("Expected permission denied state")
        }

        XCTAssertTrue(message.contains("Allow location access"))
    }

    func testLoadForecastPublishesErrorStateForWeatherFailure() async {
        let viewModel = ForecastScreenViewModel(
            locationProvider: MockLocationProvider(result: .success(LocationCoordinate(latitude: 1, longitude: 1))),
            weatherProvider: MockWeatherProvider(result: .failure(WeatherServiceError.missingAPIKey))
        )

        await viewModel.loadForecast()

        guard case .error(let message) = viewModel.state else {
            return XCTFail("Expected error state")
        }

        XCTAssertTrue(message.contains("OpenWeather API key"))
    }

    func testLoadForecastPublishesLoadedStateForWeatherSuccess() async {
        let snapshot = WeatherSnapshot(
            locationName: "Durban",
            coordinate: LocationCoordinate(latitude: -29.8587, longitude: 31.0218),
            currentTemperatureCelsius: 25,
            primaryCondition: .sunny,
            forecastDays: [
                ForecastDay(date: .now, temperatureCelsius: 25, condition: .sunny)
            ]
        )

        let viewModel = ForecastScreenViewModel(
            locationProvider: MockLocationProvider(result: .success(snapshot.coordinate)),
            weatherProvider: MockWeatherProvider(result: .success(snapshot))
        )

        await viewModel.loadForecast()

        guard case .loaded(let loadedSnapshot) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }

        XCTAssertEqual(loadedSnapshot.primaryCondition, .sunny)
    }
}
