//
//  NetworkManager.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 01.12.25.
//
import Foundation
import UIKit

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
           self.decoder.keyDecodingStrategy = .useDefaultKeys
           self.decoder.dateDecodingStrategy = .iso8601
           self.encoder = JSONEncoder()
           self.encoder.keyEncodingStrategy = .useDefaultKeys
           self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Generic Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .post,
        queryParameters: [String: String]? = nil,
        body: Data? = nil,
        requiresAuth: Bool = false,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Build URL with query parameters
        var urlComponents = URLComponents(string: baseURL + endpoint)
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents?.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        // Get the URL from urlComponents (which includes query parameters)
        guard let url = urlComponents?.url else {
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
                       // Send notification that session expired
                       NotificationCenter.default.post(name: .sessionExpired, object: nil)
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
    
    func validateToken(completion: @escaping (Bool) -> Void) {
        request(endpoint: "/users/me", method: .get, requiresAuth: true) { (result: Result<UserProfileResponse, NetworkError>) in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("Token validation failed: \(error)")
                completion(false)
            }
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
    
    // upload profile picture
    func uploadProfilePicture(image: UIImage, completion: @escaping (Result<UserProfileResponse, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + "/users/me/profile-picture") else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("📸 Uploading profile picture to: \(url.absoluteString)")
        print("📸 Image size: \(image.size)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        // Set authorization header
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("📸 Using auth token")
        } else {
            print("⚠️ No auth token available")
        }
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG")
            completion(.failure(.encodingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"]))))
            return
        }
        
        print("📸 Image data size: \(imageData.count) bytes")
        
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        logRequest(request)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ No HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
                return
            }
            
            print("📸 Response status code: \(httpResponse.statusCode)")
            
            self.logResponse(httpResponse, data: data)
            
            guard let data = data else {
                print("❌ No response data")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📸 Raw response: \(responseString)")
            }
            
            do {
                let decodedData = try self.decoder.decode(UserProfileResponse.self, from: data)
                print("✅ Successfully decoded response")
                print("📸 Profile picture in response: \(decodedData.data.profilePicture ?? "nil")")
                
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                print("❌ Decoding error: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                
                // Try to decode as error response
                if let errorResponse = try? self.decoder.decode(ErrorResponse.self, from: data) {
                    print("❌ Error message: \(errorResponse.message ?? "No message")")
                }
                
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }

    func deleteProfilePicture(completion: @escaping (Result<UserProfileResponse, NetworkError>) -> Void) {
        request(endpoint: "/users/me/profile-picture", method: .delete, requiresAuth: true, completion: completion)
    }
    
    
    
    // MARK: - Module Methods
    func createModule(request: CreateModuleRequest, completion: @escaping (Result<CreateModuleResponse, NetworkError>) -> Void) {
        do {
            // Create a custom encoder that doesn't convert to snake_case
            let customEncoder = JSONEncoder()
            customEncoder.keyEncodingStrategy = .useDefaultKeys // Use camelCase as-is
            customEncoder.outputFormatting = .prettyPrinted
            
            let bodyData = try customEncoder.encode(request)
            
            // Debug: Print what we're sending
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("📦 Sending module request (camelCase):")
                print(jsonString)
            }
            
            // Use a different variable name to avoid conflict
            let endpoint = "/modules"
            
            // Call the generic request method
            self.request(endpoint: endpoint, method: .post, body: bodyData, requiresAuth: true, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }

    func getUserModules(completion: @escaping (Result<UserModulesResponse, NetworkError>) -> Void) {
        request(endpoint: "/modules", method: .get, requiresAuth: true, completion: completion)
    }

    func getModuleById(moduleId: String, completion: @escaping (Result<CreateModuleResponse, NetworkError>) -> Void) {
        request(endpoint: "/modules/\(moduleId)", method: .get, requiresAuth: true, completion: completion)
    }

    func deleteModule(moduleId: String, completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        request(endpoint: "/modules/\(moduleId)", method: .delete, requiresAuth: true, completion: completion)
    }

    // MARK: - Term Methods (for adding terms to module)
    func createTerm(request: CreateTermRequest, completion: @escaping (Result<CreateTermResponse, NetworkError>) -> Void) {
        do {
            // Use camelCase encoder for terms
            let customEncoder = JSONEncoder()
            customEncoder.keyEncodingStrategy = .useDefaultKeys  // camelCase
            customEncoder.outputFormatting = .prettyPrinted
            
            let bodyData = try customEncoder.encode(request)
            
            // Debug print
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("📦 Sending term request to /terms:")
                print(jsonString)
            }
            
            // Endpoint is /terms (not /modules/{id}/terms)
            self.request(endpoint: "/terms", method: .post, body: bodyData, requiresAuth: true, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }

    func getModuleTerms(moduleId: String, completion: @escaping (Result<TermsListResponse, NetworkError>) -> Void) {
        let queryParameters = ["moduleId": moduleId]
        request(endpoint: "/terms", method: .get, queryParameters: queryParameters, requiresAuth: true, completion: completion)
    }
    
    func updateTermFavorite(termId: String, isStarred: Bool, completion: @escaping (Result<TermResponse, NetworkError>) -> Void) {
        let body = ["isStarred": isStarred]
        
        do {
            let bodyData = try encoder.encode(body)
            
            // First decode as UpdateTermResponse, then extract the data
            request(endpoint: "/terms/\(termId)", method: .patch, body: bodyData, requiresAuth: true) { (result: Result<UpdateTermResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    // Return only the term data from inside the response
                    completion(.success(response.data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }
    
    func getUserById(userId: String, completion: @escaping (Result<UserProfileResponse, NetworkError>) -> Void) {
        // If we're trying to get current user, use /users/me
        if let currentUserId = UserDefaults.standard.string(forKey: "currentUserId"),
           userId == currentUserId {
            print("✅ Getting current user via /users/me")
            getUserProfile(completion: completion)
        } else {
            // For other users, if your API doesn't support it, we need to handle differently
            print("⚠️ Cannot fetch other users - API only supports /users/me")
            completion(.failure(.notFound))
        }
    }
    
    // MARK: - Update Module
    func updateModule(moduleId: String, request: UpdateModuleRequest, completion: @escaping (Result<CreateModuleResponse, NetworkError>) -> Void) {
        do {
            let customEncoder = JSONEncoder()
            customEncoder.keyEncodingStrategy = .useDefaultKeys
            customEncoder.outputFormatting = .prettyPrinted
            
            let bodyData = try customEncoder.encode(request)
            
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("📦 Sending module update request:")
                print(jsonString)
            }
            
            let endpoint = "/modules/\(moduleId)"
            self.request(endpoint: endpoint, method: .patch, body: bodyData, requiresAuth: true, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }

    // MARK: - Update Term
    func updateTerm(termId: String, request: UpdateTermRequest, completion: @escaping (Result<UpdateTermResponse, NetworkError>) -> Void) {
        do {
            let customEncoder = JSONEncoder()
            customEncoder.keyEncodingStrategy = .useDefaultKeys
            customEncoder.outputFormatting = .prettyPrinted
            
            let bodyData = try customEncoder.encode(request)
            
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("📦 Sending term update request:")
                print(jsonString)
            }
            
            let endpoint = "/terms/\(termId)"
            self.request(endpoint: endpoint, method: .patch, body: bodyData, requiresAuth: true, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }

    // MARK: - Delete Term
    func deleteTerm(termId: String, completion: @escaping (Result<AuthResponse, NetworkError>) -> Void) {
        request(endpoint: "/terms/\(termId)", method: .delete, requiresAuth: true, completion: completion)
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
