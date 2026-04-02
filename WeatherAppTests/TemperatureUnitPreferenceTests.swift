import XCTest
@testable import WeatherApp

@MainActor
final class TemperatureUnitPreferenceTests: XCTestCase {
    func testInitUsesFahrenheitLocalePreference() {
        XCTAssertEqual(
            TemperatureUnitPreference(locale: Locale(identifier: "en_US")),
            .fahrenheit
        )
    }

    func testInitUsesCelsiusLocalePreference() {
        XCTAssertEqual(
            TemperatureUnitPreference(locale: Locale(identifier: "en_ZA")),
            .celsius
        )
    }

    func testDisplayValueLeavesCelsiusUntouched() {
        XCTAssertEqual(TemperatureUnitPreference.celsius.displayValue(forCelsius: 18), 18)
    }

    func testDisplayValueConvertsToRoundedFahrenheit() {
        XCTAssertEqual(TemperatureUnitPreference.fahrenheit.displayValue(forCelsius: 18), 64)
    }
}
