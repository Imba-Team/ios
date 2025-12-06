//
//  NetworkManager.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 01.12.25.
//
// NetworkManager.swift
// NetworkManager.swift
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

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://imba-server.up.railway.app"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    // Token management
    var authToken: String? {
        get { return UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .post,
        body: Data? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Build URL
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if needed
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Log request for debugging
        logRequest(request)
        
        // Make the request
        session.dataTask(with: request) { [weak self] data, response, error in
            // Handle network error
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            // Handle HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
                return
            }
            
            if let headers = httpResponse.allHeaderFields as? [String: String],
                       let url = request.url {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                        
                        // Find token cookie
                        if let tokenCookie = cookies.first(where: { $0.name == "token" }) {
                            DispatchQueue.main.async {
                                self?.authToken = tokenCookie.value
                                print("✅ Extracted token from cookies: \(tokenCookie.value.prefix(20))...")
                            }
                        }
                    }
            
            // Log response for debugging
            self?.logResponse(httpResponse, data: data)
            
            // Handle status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.noData))
                    }
                    return
                }
                
                do {
                    let decodedData = try self?.decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedData!))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError(error)))
                    }
                }
                
            case 401:
                // Unauthorized - clear token
                self?.authToken = nil
                DispatchQueue.main.async {
                    completion(.failure(.unauthorized))
                }
                
            case 403:
                DispatchQueue.main.async {
                    completion(.failure(.forbidden))
                }
                
            case 404:
                DispatchQueue.main.async {
                    completion(.failure(.notFound))
                }
                
            case 429:
                DispatchQueue.main.async {
                    completion(.failure(.rateLimited))
                }
                
            case 400...499, 500...599:
                // Client or server error
                if let data = data, let errorMessage = self?.parseErrorMessage(from: data) {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(errorMessage)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(.serverError("Server error: \(httpResponse.statusCode)")))
                    }
                }
                
            default:
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
    
    // MARK: - Convenience Methods
    func post<T: Decodable, U: Encodable>(
        endpoint: String,
        body: U,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        do {
            let bodyData = try encoder.encode(body)
            request(endpoint: endpoint, method: .post, body: bodyData, requiresAuth: requiresAuth, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }
    
    // MARK: - Authentication Methods
    func register(request: RegisterRequest, completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        post(endpoint: "/auth/register", body: request, completion: completion)
    }
    
    func login(request: LoginRequest, completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        post(endpoint: "/auth/login", body: request, completion: completion)
    }
    
    // LOGOUT METHOD:
    func logout(completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        request(endpoint: "/auth/logout", method: .post, requiresAuth: true, completion: completion)
    }

    // User Profile Endpoint
    func getUserProfile(completion: @escaping (Result<UserProfileResponse, NetworkError>) -> Void) {
        request(endpoint: "/users/me", method: .get, requiresAuth: true, completion: completion)
    }

    // Update profile method
    func updateProfile(name: String, email: String, completion: @escaping (Result<UserProfileResponse, NetworkError>) -> Void) {
        let body = ["name": name, "email": email]
        post(endpoint: "/users/me", body: body, requiresAuth: true, completion: completion)
    }

    // Change Password Method
    func changePassword(oldPassword: String, newPassword: String, confirmPassword: String, completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        let body = [
            "oldPassword": oldPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmPassword
        ]
        
        // Use PATCH method
        do {
            let bodyData = try encoder.encode(body)
            request(endpoint: "/users/me/change-password", method: .patch, body: bodyData, requiresAuth: true, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }
    
    // Delete Account
    func deleteAccount(completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        request(endpoint: "/users/me", method: .delete, requiresAuth: true, completion: completion)
    }
    
    // MARK: - Helper Methods
    private func parseErrorMessage(from data: Data) -> String {
        do {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            if let message = errorResponse.message {
                return message
            } else if let errors = errorResponse.errors {
                // Combine all error messages
                let allErrors = errors.values.flatMap { $0 }
                return allErrors.joined(separator: "\n")
            }
        } catch {
            // If we can't decode, try to get raw string
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        }
        return "Unknown error occurred"
    }
    
    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("\n=== HTTP Request ===")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("===================\n")
        #endif
    }
    
    private func logResponse(_ response: HTTPURLResponse, data: Data?) {
        #if DEBUG
        print("\n=== HTTP Response ===")
        print("Status Code: \(response.statusCode)")
        print("Headers: \(response.allHeaderFields)")
        if let data = data, let bodyString = String(data: data, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("====================\n")
        #endif
    }
}
