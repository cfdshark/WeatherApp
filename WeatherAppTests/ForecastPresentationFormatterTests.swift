import XCTest
@testable import WeatherApp

final class ForecastPresentationFormatterTests: XCTestCase {
    func testTemperatureStringUsesCelsiusWhenPreferred() {
        XCTAssertEqual(
            ForecastPresentationFormatter.temperatureString(
                celsius: 24,
                unitPreference: .celsius
            ),
            "24°C"
        )
    }

    func testTemperatureStringConvertsToFahrenheitWhenPreferred() {
        XCTAssertEqual(
            ForecastPresentationFormatter.temperatureString(
                celsius: 24,
                unitPreference: .fahrenheit
            ),
            "75°F"
        )
    }

    func testTemperatureStringConvertsNegativeValuesToFahrenheit() {
        XCTAssertEqual(
            ForecastPresentationFormatter.temperatureString(
                celsius: -10,
                unitPreference: .fahrenheit
            ),
            "14°F"
        )
    }

    func testWeekdayStringReturnsWeekdayName() {
        let date = Date(timeIntervalSince1970: 1_743_508_800)
        XCTAssertEqual(
            ForecastPresentationFormatter.weekdayString(
                from: date,
                locale: Locale(identifier: "en_US_POSIX"),
                timeZone: TimeZone(secondsFromGMT: 0) ?? .gmt
            ),
            "Tuesday"
        )
    }
}
