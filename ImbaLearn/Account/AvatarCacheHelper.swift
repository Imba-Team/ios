// AvatarCacheHelper.swift
import UIKit

class AvatarCacheHelper {
    static let shared = AvatarCacheHelper()
    
    private init() {}
    
    func cacheAvatar(for userId: String, image: UIImage) {
        let cacheKey = "avatar_\(userId)"
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: cacheKey)
            UserDefaults.standard.synchronize()
            print("✅ Avatar cached for user: \(userId)")
        }
    }
    
    func getCachedAvatar(for userId: String) -> UIImage? {
        let cacheKey = "avatar_\(userId)"
        if let imageData = UserDefaults.standard.data(forKey: cacheKey),
           let image = UIImage(data: imageData) {
            print("✅ Loaded avatar from cache for user: \(userId)")
            return image
        }
        return nil
    }
    
    func removeCachedAvatar(for userId: String) {
        let cacheKey = "avatar_\(userId)"
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.synchronize()
    }
}
