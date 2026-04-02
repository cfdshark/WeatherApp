import XCTest
@testable import WeatherApp

final class OpenWeatherForecastMapperTests: XCTestCase {
    func testMapperBuildsFiveForecastDaysAndPrimaryCondition() {
        let response = OpenWeatherResponse(
            list: [
                makeEntry(timestamp: 1_743_638_400, temp: 18, feelsLike: 17, min: 16, max: 20, code: 803, main: "Clouds"),
                makeEntry(timestamp: 1_743_649_200, temp: 19, feelsLike: 18, min: 17, max: 21, code: 804, main: "Clouds"),
                makeEntry(timestamp: 1_743_724_800, temp: 21, feelsLike: 20, min: 19, max: 23, code: 800, main: "Clear"),
                makeEntry(timestamp: 1_743_811_200, temp: 17, feelsLike: 16, min: 15, max: 19, code: 500, main: "Rain"),
                makeEntry(timestamp: 1_743_897_600, temp: 16, feelsLike: 15, min: 14, max: 18, code: 502, main: "Rain"),
                makeEntry(timestamp: 1_743_984_000, temp: 22, feelsLike: 21, min: 20, max: 25, code: 800, main: "Clear")
            ],
            city: .init(name: "Pretoria", timezone: 7_200)
        )

        let snapshot = OpenWeatherForecastMapper().map(
            response: response,
            coordinate: LocationCoordinate(latitude: -25.7479, longitude: 28.2293)
        )

        XCTAssertEqual(snapshot.locationName, "Pretoria")
        XCTAssertEqual(snapshot.primaryDescription, "Clouds")
        XCTAssertEqual(snapshot.currentFeelsLikeTemperatureCelsius, 17)
        XCTAssertEqual(snapshot.humidityPercentage, 56)
        XCTAssertEqual(snapshot.windSpeedKilometersPerHour, 14)
        XCTAssertEqual(snapshot.precipitationProbabilityPercentage, 20)
        XCTAssertEqual(snapshot.primaryCondition, .cloudy)
        XCTAssertEqual(snapshot.primaryIcon, .cloud)
        XCTAssertEqual(snapshot.forecastDays.count, 5)
        XCTAssertEqual(snapshot.forecastDays[0].minTemperatureCelsius, 16)
        XCTAssertEqual(snapshot.forecastDays[0].maxTemperatureCelsius, 21)
        XCTAssertEqual(snapshot.forecastDays[0].hourlyForecasts.count, 2)
        XCTAssertEqual(snapshot.forecastDays[1].condition, .sunny)
        XCTAssertEqual(snapshot.forecastDays[1].icon, .sun)
    }

    private func makeEntry(timestamp: TimeInterval, temp: Double, feelsLike: Double, min: Double, max: Double, code: Int, main: String) -> OpenWeatherResponse.ForecastEntry {
        OpenWeatherResponse.ForecastEntry(
            timestamp: timestamp,
            main: .init(
                temperature: temp,
                feelsLikeTemperature: feelsLike,
                minimumTemperature: min,
                maximumTemperature: max,
                humidity: 56
            ),
            weather: [.init(id: code, main: main, description: main)],
            wind: .init(speed: 4),
            precipitationProbability: 0.2
        )
    }
}
