//
//  LoginViewModel.swift
//  ImbaLearn
//

import Foundation

protocol LoginViewModelDelegate: AnyObject{
    func onViewStateChanged(_ viewState: LoginViewModel.ViewState) -> Void
    func onNavigateToMainApp() -> Void
    func onNavigateToRegister() -> Void
}


class LoginViewModel {
    
    let authRepository: AuthRepository = AuthRepository(apiService: .shared)
    
    // MARK: - Properties
    private(set) var isLoading = false
    
    weak var delegate: LoginViewModelDelegate?

    
    // MARK: - View State
    enum ViewState {
        case idle
        case loading
        case success(message: String?)
        case validationError(title: String, message: String)
        case loginError(title: String, message: String)
        case networkError(error: NetworkError)
    }
    
//    // MARK: - Callbacks
//    var onViewStateChanged: ((ViewState) -> Void)?
//    var onNavigateToMainApp: (() -> Void)?
//    var onNavigateToRegister: (() -> Void)?
    
    // MARK: - Public Methods
    
    func login(email: String?, password: String?) {
        guard !isLoading else { return }
        
        // Validate inputs
        let validationResult = validateInputs(email: email, password: password)
        guard case .valid(let validatedEmail, let validatedPassword) = validationResult else {
            if case .invalid(let title, let message) = validationResult {
                delegate?.onViewStateChanged(.validationError(title: title, message: message))
            }
            return
        }
        
        isLoading = true
        delegate?.onViewStateChanged(.loading)
        
        print("🔐 Attempting login for: \(validatedEmail)")
        
        // Create login request
        let loginRequest = LoginRequest(
            email: validatedEmail,
            password: validatedPassword
        )
        
        // Call API
        /*NetworkManager.shared.login(request: loginRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.handleLoginResult(result, email: validatedEmail)
            }
        }*/
        authRepository.login(request: loginRequest, completion: {
            [weak self] result in
            guard let self else { return }
            self.isLoading = false
            self.handleLoginResult(result, email: validatedEmail)
        })
    }
    
    func navigateToRegister() {
        delegate?.onNavigateToRegister()
    }
    
    // MARK: - Validation
    private enum ValidationResult {
        case valid(email: String, password: String)
        case invalid(title: String, message: String)
    }
    
    private func validateInputs(email: String?, password: String?) -> ValidationResult {
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
            return .invalid(title: "Validation Error", message: "Please enter your password")
        }
        
        guard passwordText.count >= 6 else {
            return .invalid(title: "Validation Error", message: "Password must be at least 6 characters")
        }
        
        return .valid(email: emailText, password: passwordText)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Handle Login Result
    private func handleLoginResult(_ result: Result<AuthResponse, NetworkError>, email: String) {
        switch result {
        case .success(let response):
            if response.ok {
                // Save user data
                saveUserData(email: email)
                
                // Show success and navigate
                delegate?.onViewStateChanged(.success(message: "Login successful!"))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.delegate?.onNavigateToMainApp()
                }
            } else {
                delegate?.onViewStateChanged(.loginError(title: "Login Failed", message: response.message))
            }
            
        case .failure(let error):
            delegate?.onViewStateChanged(.networkError(error: error))
        }
    }
    
    private func saveUserData(email: String) {
        UserDefaults.standard.set(email, forKey: "userEmail")
        // Try to extract name from email or use placeholder
        let name = email.components(separatedBy: "@").first ?? "User"
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.synchronize()
    }
}
