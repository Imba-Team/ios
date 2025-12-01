//
//  File.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 01.12.25.
//

// AuthModels.swift
// AuthModels.swift
import Foundation

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Updated to match actual API response
struct AuthResponse: Codable {
    let ok: Bool           // Changed from "status" to "ok"
    let message: String
    //let data: Any?         // Can be null or user data
    
    // Custom decoding to handle null data
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ok = try container.decode(Bool.self, forKey: .ok)
        message = try container.decode(String.self, forKey: .message)
        
        // Try to decode data, but it can be null
//        if let userData = try? container.decode(UserData.self, forKey: .data) {
//            data = userData
//        } else {
//            data = nil
//        }
    }
}

struct UserData: Codable {
    let user: User?
}

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let emailVerifiedAt: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ErrorResponse: Codable {
    let message: String?
    let errors: [String: [String]]?
    let error: String?
    let statusCode: Int?
}
