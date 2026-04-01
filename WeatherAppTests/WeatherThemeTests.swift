import XCTest
@testable import WeatherApp

final class WeatherThemeTests: XCTestCase {
    func testBackgroundAssetMappingMatchesWeatherCategory() {
        XCTAssertEqual(WeatherTheme.backgroundAssetName(for: .sunny), "Sunny")
        XCTAssertEqual(WeatherTheme.backgroundAssetName(for: .cloudy), "Cloudy")
        XCTAssertEqual(WeatherTheme.backgroundAssetName(for: .rainy), "Rainy")
    }
}
