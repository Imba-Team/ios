import Foundation


// MARK: - Authentication Models
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

// MARK: - Module Models
struct CreateModuleRequest: Codable {
    let title: String
    let description: String?
    let isPrivate: Bool
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case isPrivate
    }
    
    init(title: String, description: String? = nil, isPrivate: Bool = false) {
        self.title = title
        self.description = description
        self.isPrivate = isPrivate
    }
}

struct ModuleResponse: Codable {
    let id: String
        let slug: String
        let title: String
        let description: String?
        let isPrivate: Bool
        let userId: String
        let termsCount: Int?
        let progress: ProgressData?
        let createdAt: String?
        let updatedAt: String?
}

struct ProgressData: Codable {
    let notStarted: Double
    let inProgress: Double
    let completed: Double
    
    enum CodingKeys: String, CodingKey {
        case notStarted = "not_started"
        case inProgress = "in_progress"
        case completed
    }
}

struct CreateModuleResponse: Codable {
    let ok: Bool
    let message: String
    let data: ModuleResponse?  
}

// For fetching modules
struct UserModulesResponse: Codable {
    let ok: Bool
    let message: String
    let data: [ModuleResponse]?
}

// MARK: - Term/Flashcard Models (for adding terms to module)
struct CreateTermRequest: Codable {
    let moduleId: String
    let term: String
    let definition: String
    let isStarred: Bool?  // Added this
    
    enum CodingKeys: String, CodingKey {
        case moduleId
        case term
        case definition
        case isStarred
    }
    
    init(moduleId: String, term: String, definition: String, isStarred: Bool = false) {
        self.moduleId = moduleId
        self.term = term
        self.definition = definition
        self.isStarred = isStarred
    }
}

struct TermResponse: Codable {
    let id: String
    let term: String
    let status: String
    let definition: String
    let isStarred: Bool
    let createdAt: String?
    let updatedAt: String?
    let moduleId: String?  // Make optional since response might not have it
    
    enum CodingKeys: String, CodingKey {
        case id, term, status, definition, isStarred, createdAt, updatedAt, moduleId
    }
}

struct CreateTermResponse: Codable {
    let ok: Bool
    let message: String
    let data: TermResponse?
}

// For fetching terms from a module
struct TermsListResponse: Codable {
    let ok: Bool
    let message: String
    let data: [TermResponse]?
}

// MARK: - Term Model (for local use in UI)
struct Term {
    var term: String
    var definition: String
    var isStarred: Bool = false  // Add this
    
    // Helper to convert to CreateTermRequest
    func toCreateTermRequest(moduleId: String) -> CreateTermRequest {
        return CreateTermRequest(
            moduleId: moduleId,
            term: term.trimmingCharacters(in: .whitespacesAndNewlines),
            definition: definition.trimmingCharacters(in: .whitespacesAndNewlines),
            isStarred: isStarred
        )
    }
}

// Extension to convert API response to local model
extension TermResponse {
    func toTerm() -> Term {
        return Term(term: self.term, definition: self.definition)
    }
}
