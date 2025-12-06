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

// For auth responses (register/login/logout)
struct AuthResponse: Codable {
    let ok: Bool
    let message: String
}

// For user profile response
struct UserProfileResponse: Codable {
    let ok: Bool
    let message: String
    let data: UserProfileData
}

struct UserProfileData: Codable {
    let id: String  // Note: Changed from Int to String based on API response
    let email: String
    let name: String
    let status: String?
    let role: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case status
        case role
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

// Simple User model for local storage (compatible with both)
struct User: Codable {
    let id: String
    let name: String
    let email: String
    let createdAt: String?
    let updatedAt: String?
    
    // Initialize from UserProfileData
    init(from profileData: UserProfileData) {
        self.id = profileData.id
        self.name = profileData.name
        self.email = profileData.email
        self.createdAt = profileData.createdAt
        self.updatedAt = profileData.updatedAt
    }
}

struct ErrorResponse: Codable {
    let message: String?
    let errors: [String: [String]]?
    let error: String?
    let statusCode: Int?
}
