import Foundation

enum NetworkError: Error, Equatable {
    case invalidResponse
    case requestFailed(statusCode: Int)
}
