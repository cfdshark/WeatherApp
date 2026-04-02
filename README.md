# WeatherApp

WeatherApp is a SwiftUI weather client that fetches a 5-day forecast from OpenWeather using the user's current location, then displays a weather-aware background and forecast UI. The codebase is intentionally split into small views and focused services instead of a single monolithic screen.

## Conventions And Architecture

- Architecture: MVVM with feature-oriented folders and protocol-backed services.
- UI framework: SwiftUI only for app presentation. No functional UIKit screens are introduced.
- Networking: `URLSession` + `Codable`; no third-party HTTP or JSON libraries.
- State management: `ObservableObject` + `@Published` in the feature view model.
- Dependency direction: Views depend on view models, view models depend on protocols, services depend on infrastructure helpers, and domain models stay framework-light.
- Scope: one application target and one unit-test target.

## Project Structure

```text
WeatherApp/
  App/
  Domain/Models/
  Features/Forecast/ViewModels/
  Features/Forecast/Views/
  Services/Location/
  Services/Networking/
  Services/Weather/
  Shared/
WeatherAppTests/
docs/
```

See [docs/Architecture.md](/Users/blessingmabunda/Documents/WeatherApp/docs/Architecture.md) for the detailed architecture breakdown.

## Third-Party Dependencies

No third-party dependencies are currently used.

- OpenWeather is used as an external HTTP API, not as a bundled SDK.
- If cross-cutting tooling is added later, it must stay limited to concerns such as linting, logging, or CI support.

## Configuration

The current testing configuration is defined in [AppConfiguration.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/App/AppConfiguration.swift).

- `openWeatherAPIKey`

The OpenWeather key is currently stored on the client for testing.

## Build And Run

1. Open [WeatherApp.xcodeproj](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp.xcodeproj).
2. Select the `WeatherApp` scheme.
3. Edit [AppConfiguration.swift](/Users/blessingmabunda/Documents/WeatherApp/WeatherApp/App/AppConfiguration.swift) with your testing values.
4. Run on an iPhone simulator or device with location permissions enabled.

CLI examples:

```bash
xcodebuild build -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild test -project WeatherApp.xcodeproj -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Testing Strategy

- Unit tests cover:
  - OpenWeather response mapping into app-owned models
  - theme/background mapping
  - forecast view-model state transitions
  - presentation formatting helpers
- Protocol-based test doubles isolate location, network, and weather flows.
- UI verification is handled through SwiftUI previews plus view-model coverage rather than snapshot tooling.

## CI/CD And Coverage

GitHub Actions is configured in [ios.yml](/Users/blessingmabunda/Documents/WeatherApp/.github/workflows/ios.yml). The pipeline is currently a CI workflow rather than a full deployment workflow, so its job is to validate the app on every change to `main` and on pull requests.

The workflow currently runs a single job named `test-and-analyze` on `macos-latest`. That job:

- checks out the repository with `actions/checkout`
- selects the latest stable Xcode with `maxim-lobanov/setup-xcode`
- runs `xcodebuild test` against the `WeatherApp` scheme on the `iPhone 16` simulator
- enables code coverage during test execution
- writes the test result bundle to `TestResults.xcresult`
- runs `xcodebuild analyze` for static analysis after tests
- exports a human-readable coverage report with `xcrun xccov view --report`
- uploads the generated `coverage.txt` file as a GitHub Actions artifact named `weatherapp-coverage`

In practical terms, CI is enforcing three things on every push and pull request:

- the app target and test target must compile successfully
- the unit tests must pass on the configured simulator destination
- Xcode static analysis must complete without failing the workflow

The artifact handling is intentionally simple. Coverage is not yet posted as a PR comment, uploaded to a third-party dashboard, or used as a merge gate. Instead, the workflow keeps the `coverage.txt` file as a downloadable build artifact for manual inspection from the Actions run page.

There is no CD step yet. The repository does not currently build release archives, sign the app, upload to TestFlight, deploy metadata, or publish artifacts beyond the test coverage report. If release automation is added later, it should be kept separate from the validation job so CI failures and release failures remain easy to distinguish.

If GitHub Actions shows JavaScript runtime warnings such as Node 20 deprecation notices, those warnings are about the GitHub-hosted action runtime used by actions like `actions/checkout`, not about the Swift app itself. They should be handled by updating workflow action versions when newer compatible releases are available.

## Static Analysis

- Native compiler warnings are left enabled in the Xcode project.
- CI runs `xcodebuild analyze` to catch analyzer issues early.
- No third-party static-analysis tool is required for this version of the app.

## Security Consideration

The API key is stored on the client side, which is unsecure, and any bad actors can unbundle the app and gain access to the API key. This is only for testing purposes. If the app was to be mass distributed, the API key would be moved to Firebase Secrets Manager.
