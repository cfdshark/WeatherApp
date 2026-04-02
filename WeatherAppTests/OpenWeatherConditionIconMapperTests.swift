import XCTest
@testable import WeatherApp

final class OpenWeatherConditionIconMapperTests: XCTestCase {
    private let subject = OpenWeatherConditionIconMapper()

    func testMapsClearSkyToSunIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 800, main: "Clear", description: "clear sky")), .sun)
    }

    func testMapsLightRainToLightRainWithSunIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 500, main: "Rain", description: "light rain")), .lightRainWithSun)
    }

    func testMapsHeavyRainToHeavyRainIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 503, main: "Rain", description: "very heavy rain")), .heavyRain)
    }

    func testMapsThunderstormToThunderstormIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 211, main: "Thunderstorm", description: "thunderstorm")), .thunderstorm)
    }

    func testMapsSnowToSnowIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 601, main: "Snow", description: "snow")), .snow)
    }

    func testMapsHeavySnowToHeavySnowfallIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 622, main: "Snow", description: "heavy shower snow")), .heavySnowfall)
    }

    func testMapsSleetToHailstormIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 611, main: "Snow", description: "sleet")), .hailstorm)
    }

    func testMapsFogToCloudIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 741, main: "Fog", description: "fog")), .cloud)
    }

    func testMapsTornadoToHeavyWindIcon() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 781, main: "Tornado", description: "tornado")), .heavyWind)
    }

    func testFallsBackToDescriptionHeuristicsBeforeDefault() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 999, main: "Custom", description: "heavy rain")), .heavyRain)
    }

    func testFallsBackToDefaultCloudIconForUnknownCondition() {
        XCTAssertEqual(subject.icon(for: makeWeather(id: 999, main: "Custom", description: "mystery weather")), .cloud)
    }

    private func makeWeather(id: Int, main: String, description: String) -> OpenWeatherResponse.Weather {
        .init(id: id, main: main, description: description)
    }
}
