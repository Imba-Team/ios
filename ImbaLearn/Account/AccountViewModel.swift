import Foundation
import UIKit

class AccountViewModel {
    
    // MARK: - Properties
    private(set) var currentUser: User?
    private(set) var isLoading = false
    private(set) var profileImage: UIImage? {
        didSet {
            saveProfileImageToCache()
        }
    }
    
    // MARK: - Callbacks
    var onUserDataUpdated: ((User?) -> Void)?
    var onProfileImageUpdated: ((UIImage?) -> Void)?
    var onError: ((String) -> Void)?
    var onLogoutSuccess: (() -> Void)?
    var onAccountDeleteSuccess: (() -> Void)?
    
    // MARK: - Initialization
    init() {
        loadProfileImageFromCache()
    }
    
    // MARK: - Data Methods
    func loadUserData() {
        // First try to load from saved data
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser"),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            currentUser = savedUser
            onUserDataUpdated?(savedUser)
            print("✅ Loaded user from saved data: \(savedUser.name)")
            
            // Load profile image if user has one
            loadProfileImageFromBackend()
        } else {
            // If no saved data, fetch from API
            fetchUserProfile()
        }
    }
    
    private func uploadProfileImageToBackend(_ image: UIImage) {
        print("📸 Starting profile image upload...")
        
        NetworkManager.shared.uploadProfilePicture(image: image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("✅ Profile image uploaded successfully")
                    print("📸 Response data: \(response.data)")
                    
                    // Check if profilePicture URL is returned
                    if let profilePictureUrl = response.data.profilePicture {
                        print("📸 Profile picture URL: \(profilePictureUrl)")
                        
                        // Update current user with new URL
                        self?.currentUser?.profilePicture = profilePictureUrl
                        
                        // Reload user data to get updated info
                        self?.fetchUserProfile()
                    } else {
                        print("⚠️ Profile picture URL not returned in response")
                        print("📸 Full response data: \(response.data)")
                    }
                    
                case .failure(let error):
                    print("❌ Failed to upload profile image: \(error)")
                    // Show error to user
                    self?.onError?("Failed to upload profile picture. Please try again.")
                }
            }
        }
    }
    
    func fetchUserProfile() {
        guard !isLoading else { return }
        
        isLoading = true
        print("🔍 Fetching user profile from API...")
        
        NetworkManager.shared.getUserProfile { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.ok {
                        let profileData = response.data
                        let user = User(from: profileData)
                        
                        // Update current user
                        self.currentUser = user
                        
                        // Save to UserDefaults for future use
                        self.saveUserToDefaults(user)
                        
                        // Load profile image from backend (if available)
                        self.loadProfileImageFromBackend()
                        
                        // Notify view controller
                        self.onUserDataUpdated?(user)
                        
                        print("✅ Loaded user from API: \(user.name) (\(user.email))")
                    } else {
                        print("⚠️ Profile API returned error: \(response.message)")
                        self.loadUserDataFromSaved()
                    }
                    
                case .failure(let error):
                    print("❌ Failed to fetch profile: \(error.localizedDescription)")
                    self.loadUserDataFromSaved()
                }
            }
        }
    }
    
    // MARK: - Profile Image Methods
    func setProfileImage(_ image: UIImage) {
        profileImage = image
        onProfileImageUpdated?(image)
        uploadProfileImageToBackend(image)
    }
    
    func removeProfileImage() {
        profileImage = nil
        onProfileImageUpdated?(nil)
        deleteProfileImageFromBackend()
    }
    
    private func loadProfileImageFromCache() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    
    private func saveProfileImageToCache() {
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        } else {
            UserDefaults.standard.removeObject(forKey: "profileImage")
        }
        UserDefaults.standard.synchronize()
    }
    
    private func loadProfileImageFromBackend() {
        guard let user = currentUser,
                 let profilePicturePath = user.profilePicture else {
               print("⚠️ No profile picture URL available")
               return
           }
           
           print("📸 Profile picture path from server: \(profilePicturePath)")
           
           // Construct the full URL
           let fullImageUrlString = "https://imba-server.up.railway.app" + profilePicturePath
           print("📸 Full download URL: \(fullImageUrlString)")
           
           guard let profilePictureUrl = URL(string: fullImageUrlString) else {
               print("❌ Failed to create URL from string: \(fullImageUrlString)")
               return
           }
        
        // Download image
        DispatchQueue.global().async { [weak self] in
            URLSession.shared.dataTask(with: profilePictureUrl) { data, response, error in
                if let error = error {
                    print("❌ Error downloading profile image: \(error)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ Invalid image data")
                    return
                }
                
                DispatchQueue.main.async {
                    print("✅ Successfully downloaded profile image")
                    self?.profileImage = image
                    
                    // Cache the image
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        UserDefaults.standard.set(imageData, forKey: "profileImage_\(user.id)")
                        UserDefaults.standard.synchronize()
                    }
                    
                    self?.onProfileImageUpdated?(image)
                }
            }.resume()
        }
    }
    
//    private func uploadProfileImageToBackend(_ image: UIImage) {
//        // TODO: Implement API call to upload profile image
//        print("📸 Uploading profile image to backend...")
//        
//        // Simulate upload
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            print("✅ Profile image uploaded successfully")
//        }
//    }
    
    private func deleteProfileImageFromBackend() {
        // TODO: Implement API call to delete profile image
        print("📸 Deleting profile image from backend...")
        
        // Simulate deletion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("✅ Profile image deleted successfully")
        }
    }
    
    // MARK: - Helper Methods
    private func saveUserToDefaults(_ user: User) {
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            UserDefaults.standard.set(userData, forKey: "currentUser")
            UserDefaults.standard.synchronize()
            print("✅ User saved to UserDefaults: \(user.name)")
        } catch {
            print("❌ Failed to save user: \(error)")
        }
    }
    
    private func loadUserDataFromSaved() {
        // Try to load from saved data
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser"),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            currentUser = savedUser
            onUserDataUpdated?(savedUser)
            print("✅ Loaded user from saved data: \(savedUser.name)")
        } else {
            // Show placeholder data
            currentUser = nil
            onUserDataUpdated?(nil)
            print("⚠️ No user data found")
        }
    }
    
    func getAvatarFirstLetter(for name: String) -> String {
        if let firstLetter = name.first {
            return String(firstLetter).uppercased()
        }
        return "?"
    }
    
    func getAvatarColor(for name: String) -> UIColor {
        // Generate a consistent color based on the name
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemPink, .systemTeal, .systemIndigo, .systemBrown
        ]
        
        let hash = name.utf8.reduce(0) { $0 + Int($1) }
        let colorIndex = hash % colors.count
        return colors[colorIndex]
    }
    
    // MARK: - User Actions
    func performLogout() {
        isLoading = true
        
        // Call logout API if available
        NetworkManager.shared.logout { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    print("✅ Logout successful: \(response.message)")
                case .failure(let error):
                    print("⚠️ Logout API error: \(error.localizedDescription)")
                    // We'll still clear local data even if API fails
                }
                
                // Clear all local data
                self.clearLocalData()
                
                // Notify logout success
                self.onLogoutSuccess?()
            }
        }
    }
    
    func performAccountDeletion() {
        isLoading = true
        
        // TODO: Implement actual account deletion API call
        // For now, simulate deletion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // Clear all local data
            self.clearLocalData()
            
            // Notify account deletion success
            self.onAccountDeleteSuccess?()
        }
    }
    
    private func clearLocalData() {
        // Clear token from NetworkManager
        NetworkManager.shared.authToken = nil
        
        // Clear all user data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.removeObject(forKey: "profileImage")
        UserDefaults.standard.synchronize()
        
        // Clear cookies
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        // Clear profile image
        profileImage = nil
        
        print("✅ All local data cleared")
    }
}
