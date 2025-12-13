//
//  NetworkError.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 12.12.25.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case serverError(String)
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case networkError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Session expired. Please login again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "Resource not found."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
