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
    let id: String
    let email: String
    let name: String
    let status: String?
    let role: String?
    let createdAt: String?
    let updatedAt: String?
    let profilePicture: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case status
        case role
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
        case profilePicture = "profilePicture"
    }
}

// MARK: - User Info Model (for UI display)
struct UserInfo: Codable {
    let id: String
    let name: String
    let avatarUrl: String?
    let isCurrentUser: Bool
    
    init(id: String, name: String, avatarUrl: String? = nil, isCurrentUser: Bool = false) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.isCurrentUser = isCurrentUser
    }
    
    // Convenience initializer from UserProfileData
    init(from profileData: UserProfileData, isCurrentUser: Bool = true) {
        self.id = profileData.id
        self.name = profileData.name
        self.avatarUrl = profileData.profilePicture
        self.isCurrentUser = isCurrentUser
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

// Simple Progress model that matches API response
struct ProgressData: Codable {
    let not_started: Double
    let in_progress: Double
    let completed: Double
    
    // Computed properties for cleaner Swift usage
    var notStarted: Double { return not_started }
    var inProgress: Double { return in_progress }
    
    var total: Int {
        return Int(not_started + in_progress + completed)
    }
}

struct ModuleResponse: Codable {
    let id: String
    let slug: String
    var title: String
    var description: String?
    var isPrivate: Bool
    let userId: String
    let progress: ProgressData?
    
    // Optional fields
    let createdAt: String?
    let updatedAt: String?
    
    // Computed property
    var termsCount: Int? {
        return progress?.total
    }
}



struct CreateModuleResponse: Codable {
    let ok: Bool
    let message: String
    let data: ModuleResponse?
}

struct UserModulesResponse: Codable {
    let ok: Bool
    let message: String
    let data: [ModuleResponse]?
}

// MARK: - Update Module Request

struct UpdateModuleRequest: Codable {
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
    var term: String
    let status: String
    var definition: String
    var isStarred: Bool
    let createdAt: String?
    let updatedAt: String?
    let moduleId: String?  // optional since response might not have it
    
    enum CodingKeys: String, CodingKey {
        case id, term, status, definition, createdAt, updatedAt
        case isStarred = "isStarred"
        case moduleId = "moduleId"

    }
}

// MARK: - Update Term Request
struct UpdateTermRequest: Codable {
    let term: String
    let definition: String
    let isStarred: Bool
    
    enum CodingKeys: String, CodingKey {
        case term
        case definition
        case isStarred
    }
}

struct ResponseModel<T: Decodable>: Decodable {
    let ok: Bool
    let message: String
    let data: T
}

//ResponseModel<TermResponse>.self

struct PaginatedTermsData: Codable {
    let data: [TermResponse]
    let total: Int
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
    let data: PaginatedTermsData?
}

// MARK: - Update Term Response
struct UpdateTermResponse: Codable {
    let ok: Bool
    let message: String
    let data: TermResponse
}

// MARK: - Term Model (for local use in UI)
struct Term {
    var term: String
    var definition: String
    var isStarred: Bool = false  
    
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
