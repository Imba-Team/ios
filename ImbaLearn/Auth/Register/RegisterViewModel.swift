//
//  RegisterViewModel.swift
//  ImbaLearn
//

import Foundation

protocol RegisterViewModelDelegate: AnyObject {
    func onViewStateChanged(_ viewState: RegisterViewModel.ViewState) -> Void
    func onNavigateToMainApp() -> Void
    func onNavigateToLogin() -> Void
}

class RegisterViewModel {
    
    // MARK: - Properties
    private(set) var isLoading = false
    
    // MARK: - View State
    enum ViewState {
        case idle
        case loading
        case success(message: String)
        case validationError(title: String, message: String)
        case registrationError(title: String, message: String)
        case networkError(error: NetworkError)
    }
    
    weak var delegate: RegisterViewModelDelegate?
    
//    // MARK: - Callbacks
//    var onViewStateChanged: ((ViewState) -> Void)?
//    var onNavigateToMainApp: (() -> Void)?
//    var onNavigateToLogin: (() -> Void)?
//    
    // MARK: - Public Methods
    
    func register(fullName: String?, email: String?, password: String?, confirmPassword: String?) {
        guard !isLoading else { return }
        
        // Validate inputs
        let validationResult = validateInputs(
            fullName: fullName,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        guard case .valid(let validatedName, let validatedEmail, let validatedPassword) = validationResult else {
            if case .invalid(let title, let message) = validationResult {
                delegate?.onViewStateChanged(.validationError(title: title, message: message))
            }
            return
        }
        
        isLoading = true
        delegate?.onViewStateChanged(.loading)
        
        // Create request with single name field
        let registerRequest = RegisterRequest(
            name: validatedName,
            email: validatedEmail,
            password: validatedPassword
        )
        
        print("Sending registration request with name: \(registerRequest.name)")
        
        // Call API
        NetworkManager.shared.register(request: registerRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.handleRegistrationResult(result, name: validatedName, email: validatedEmail)
            }
        }
    }
    
    func navigateToLogin() {
        delegate?.onNavigateToLogin()
    }
    
    // MARK: - Validation
    private enum ValidationResult {
        case valid(name: String, email: String, password: String)
        case invalid(title: String, message: String)
    }
    
    private func validateInputs(fullName: String?, email: String?, password: String?, confirmPassword: String?) -> ValidationResult {
        // Validate full name
        guard let name = fullName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please enter your full name")
        }
        
        // Validate email
        guard let emailText = email?.trimmingCharacters(in: .whitespacesAndNewlines),
              !emailText.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please enter your email")
        }
        
        guard isValidEmail(emailText) else {
            return .invalid(title: "Validation Error", message: "Please enter a valid email address")
        }
        
        // Validate password
        guard let passwordText = password, !passwordText.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please enter a password")
        }
        
        guard passwordText.count >= 6 else {
            return .invalid(title: "Validation Error", message: "Password must be at least 6 characters")
        }
        
        // Validate confirm password
        guard let confirmPasswordText = confirmPassword,
              !confirmPasswordText.isEmpty else {
            return .invalid(title: "Validation Error", message: "Please confirm your password")
        }
        
        guard passwordText == confirmPasswordText else {
            return .invalid(title: "Validation Error", message: "Passwords do not match")
        }
        
        return .valid(name: name, email: emailText, password: passwordText)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Handle Registration Result
    private func handleRegistrationResult(_ result: Result<AuthResponse, NetworkError>, name: String, email: String) {
        switch result {
        case .success(let response):
            if response.ok {
                // Save user info from registration
                saveUserData(name: name, email: email)
                
                // Show success
                delegate?.onViewStateChanged(.success(message: response.message))
                
                // Auto-navigate after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.delegate?.onNavigateToMainApp()
                }
            } else {
                // API returned error
                delegate?.onViewStateChanged(.registrationError(title: "Registration Failed", message: response.message))
            }
            
        case .failure(let error):
            delegate?.onViewStateChanged(.networkError(error: error))
        }
    }
    
    private func saveUserData(name: String, email: String) {
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.synchronize()
    }
}
