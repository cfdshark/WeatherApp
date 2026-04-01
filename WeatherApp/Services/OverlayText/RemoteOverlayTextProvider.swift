import Foundation

struct RemoteOverlayTextProvider: OverlayTextProviding {
    private let baseURL: URL
    private let httpClient: HTTPClient

    init(baseURL: URL, httpClient: HTTPClient) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    func fetchOverlay(for snapshot: WeatherSnapshot) async throws -> WeatherOverlay {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            OverlayRequest(
                locationName: snapshot.locationName,
                latitude: snapshot.coordinate.latitude,
                longitude: snapshot.coordinate.longitude,
                temperatureCelsius: snapshot.currentTemperatureCelsius,
                primaryCondition: snapshot.primaryCondition.rawValue
            )
        )

        let (data, _) = try await httpClient.data(for: request)
        let response = try JSONDecoder().decode(OverlayResponse.self, from: data)

        return WeatherOverlay(title: response.title, message: response.message)
    }
}

private struct OverlayRequest: Encodable {
    let locationName: String
    let latitude: Double
    let longitude: Double
    let temperatureCelsius: Int
    let primaryCondition: String
}

private struct OverlayResponse: Decodable {
    let title: String
    let message: String
}
