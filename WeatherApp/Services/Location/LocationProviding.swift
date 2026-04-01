import Foundation

protocol LocationProviding {
    func requestCurrentLocation() async throws -> LocationCoordinate
}
