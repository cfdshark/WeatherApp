import XCTest
@testable import WeatherApp

final class ForecastPresentationFormatterTests: XCTestCase {
    func testTemperatureStringUsesDegreeSuffix() {
        XCTAssertEqual(ForecastPresentationFormatter.temperatureString(celsius: 24), "24°")
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
