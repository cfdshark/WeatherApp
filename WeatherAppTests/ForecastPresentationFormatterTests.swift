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

    func testRelativeDayLabelReturnsTomorrowOnlyWhenSelectedDayIsToday() {
        let calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 7_200) ?? .gmt
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        XCTAssertEqual(
            ForecastPresentationFormatter.relativeDayLabel(
                for: tomorrow,
                relativeTo: today,
                calendar: calendar,
                locale: Locale(identifier: "en_US_POSIX"),
                timeZone: timeZone
            ),
            "Tomorrow"
        )
    }

    func testRelativeDayLabelReturnsDateWhenSelectedDayIsNotToday() {
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        calendar.timeZone = timeZone
        let selectedDate = Date(timeIntervalSince1970: 1_743_681_600)
        let nextDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate

        XCTAssertEqual(
            ForecastPresentationFormatter.relativeDayLabel(
                for: nextDate,
                relativeTo: selectedDate,
                calendar: calendar,
                locale: Locale(identifier: "en_US_POSIX"),
                timeZone: timeZone
            ),
            "Fri, 4 Apr"
        )
    }

    func testTimeStringFormatsHourAndMinute() {
        var components = DateComponents()
        components.year = 2025
        components.month = 4
        components.day = 3
        components.hour = 17
        components.minute = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar(identifier: .gregorian).date(from: components) ?? .distantPast

        XCTAssertEqual(
            ForecastPresentationFormatter.timeString(
                from: date,
                locale: Locale(identifier: "en_US_POSIX"),
                timeZone: TimeZone(secondsFromGMT: 0) ?? .gmt
            ),
            "17:00"
        )
    }

    func testShortDateStringFormatsCompactDate() {
        let date = Date(timeIntervalSince1970: 1_743_681_600)
        XCTAssertEqual(
            ForecastPresentationFormatter.shortDateString(
                from: date,
                locale: Locale(identifier: "en_US_POSIX"),
                timeZone: TimeZone(secondsFromGMT: 0) ?? .gmt
            ),
            "Thu, 3 Apr"
        )
    }
}
