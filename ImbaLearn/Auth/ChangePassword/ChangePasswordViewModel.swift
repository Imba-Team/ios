//
//  ChangePasswordViewModel.swift
//  ImbaLearn
//

import Foundation

// MARK: - ChangePasswordViewModelDelegate Protocol
protocol ChangePasswordViewModelDelegate: AnyObject {
    func onViewStateChanged(_ viewState: ChangePasswordViewModel.ViewState) -> Void
    func onNavigateToLogin() -> Void  // Only keep this one for logout navigation
}

class ChangePasswordViewModel {
    
    // MARK: - Properties
    private(set) var isLoading = false
    private(set) var isCurrentPasswordVisible = false
    private(set) var isNewPasswordVisible = false
    private(set) var isConfirmPasswordVisible = false
    
    weak var delegate: ChangePasswordViewModelDelegate?
    
    // MARK: - View State
    enum ViewState {
        case idle
        case loading
        case success(message: String)
        case validationError(title: String, message: String, fieldToFocus: FocusField)
        case changePasswordError(title: String, message: String)
        case networkError(error: NetworkError)
    }
    
    enum FocusField {
        case currentPassword
        case newPassword
        case confirmPassword
    }
    
    // MARK: - Public Methods
    
    func changePassword(currentPassword: String?, newPassword: String?, confirmPassword: String?) {
        guard !isLoading else { return }
        
        // Validate inputs
        let validationResult = validateInputs(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword
        )
        
        guard case .valid(let validatedCurrentPassword, let validatedNewPassword, _) = validationResult else {
            if case .invalid(let title, let message, let field) = validationResult {
                delegate?.onViewStateChanged(.validationError(title: title, message: message, fieldToFocus: field))
            }
            return
        }
        
        isLoading = true
        delegate?.onViewStateChanged(.loading)
        
        print("🔐 Changing password...")
        print("   Old: \(String(repeating: "*", count: validatedCurrentPassword.count))")
        print("   New: \(String(repeating: "*", count: validatedNewPassword.count))")
        
        // Call API to change password
        NetworkManager.shared.changePassword(
            oldPassword: validatedCurrentPassword,
            newPassword: validatedNewPassword,
            confirmPassword: confirmPassword ?? ""
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.handleChangePasswordResult(result)
            }
        }
    }
    
    func toggleCurrentPasswordVisibility() {
        isCurrentPasswordVisible.toggle()
    }
    
    func toggleNewPasswordVisibility() {
        isNewPasswordVisible.toggle()
    }
    
    func toggleConfirmPasswordVisibility() {
        isConfirmPasswordVisible.toggle()
    }
    
    // MARK: - Logout (for successful password change)
    func logoutAndGoToLogin() {
        // Clear local data
        NetworkManager.shared.authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()
        
        // Navigate to login
        delegate?.onNavigateToLogin()
    }
    
    // MARK: - Validation
    private enum ValidationResult {
        case valid(currentPassword: String, newPassword: String, confirmPassword: String)
        case invalid(title: String, message: String, field: FocusField)
    }
    
    private func validateInputs(currentPassword: String?, newPassword: String?, confirmPassword: String?) -> ValidationResult {
        // Validate old password
        guard let oldPassword = currentPassword,
              !oldPassword.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please enter your old password", field: .currentPassword)
        }
        
        // Validate new password
        guard let newPasswordText = newPassword,
              !newPasswordText.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please enter a new password", field: .newPassword)
        }
        
        // Check password requirements
        guard isValidPassword(newPasswordText) else {
            return .invalid(
                title: "Validation Error",
                message: "Password must be at least 8 characters with uppercase, lowercase, and number",
                field: .newPassword
            )
        }
        
        // Validate confirm password
        guard let confirmPasswordText = confirmPassword,
              !confirmPasswordText.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please confirm your new password", field: .confirmPassword)
        }
        
        // Check if passwords match
        guard newPasswordText == confirmPasswordText else {
            return .invalid(title: "Validation Error", message: "New passwords do not match", field: .confirmPassword)
        }
        
        // Check if new password is different from old
        guard newPasswordText != oldPassword else {
            return .invalid(title: "Validation Error", message: "New password must be different from old password", field: .newPassword)
        }
        
        return .valid(currentPassword: oldPassword, newPassword: newPasswordText, confirmPassword: confirmPasswordText)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters
        guard password.count >= 8 else { return false }
        
        // At least one uppercase letter
        let uppercaseRegex = ".*[A-Z]+.*"
        let uppercaseTest = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        guard uppercaseTest.evaluate(with: password) else { return false }
        
        // At least one lowercase letter
        let lowercaseRegex = ".*[a-z]+.*"
        let lowercaseTest = NSPredicate(format: "SELF MATCHES %@", lowercaseRegex)
        guard lowercaseTest.evaluate(with: password) else { return false }
        
        // At least one number
        let numberRegex = ".*[0-9]+.*"
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        guard numberTest.evaluate(with: password) else { return false }
        
        return true
    }
    
    // MARK: - Handle Result
    private func handleChangePasswordResult(_ result: Result<AuthResponse, NetworkError>) {
        switch result {
        case .success(let response):
            print("✅ Change password response: ok=\(response.ok), message=\(response.message)")
            
            if response.ok {
                delegate?.onViewStateChanged(.success(message: response.message))
            } else {
                // API returned success false with error message
                delegate?.onViewStateChanged(.changePasswordError(title: "Change Password Failed", message: response.message))
            }
            
        case .failure(let error):
            print("❌ Change password error: \(error)")
            delegate?.onViewStateChanged(.networkError(error: error))
        }
    }
}
