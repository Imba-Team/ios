//  RegisterViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 17.11.25.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .color3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Register"
        label.textColor = .text
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.alpha = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your full name"
        textField.borderStyle = .none
        textField.autocapitalizationType = .words
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm your password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .greenButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Login!", for: .normal)
        button.setTitleColor(.greenButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTextFields()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        // Add header view directly to main view (not in scroll view)
        view.addSubview(headerView)
        
        // Add scroll view and content view below header
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add title label to header
        headerView.addSubview(titleLabel)
        
        // Add all form elements to contentView (only full name, no separate first/last)
        contentView.addSubviews(fullNameLabel, fullNameTextField, emailLabel, emailTextField, passwordLabel, passwordTextField, confirmPasswordLabel, confirmPasswordTextField, registerButton, loginButton)
        
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    private func setupTextFields() {
        // Set up text field delegates
        let textFields = [fullNameTextField, emailTextField, passwordTextField, confirmPasswordTextField]
        textFields.forEach { textField in
            textField.delegate = self
        }
        
        // Enable keyboard avoidance
        setupKeyboardAvoidance(with: scrollView)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 60
        let labelHeight: CGFloat = 20
        let headerHeight: CGFloat = 180
        
        NSLayoutConstraint.activate([
            // Header View - Fixed at top, not in scroll view
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            // Title Label - centered in header
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -padding),
            
            // Scroll View - Below header
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Full Name Label
            fullNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            fullNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            fullNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            fullNameLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Full Name Text Field
            fullNameTextField.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            fullNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            fullNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            fullNameTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            emailLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Email Text Field
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Password Label
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            passwordLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Password Text Field
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Confirm Password Label
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            confirmPasswordLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Confirm Password Text Field
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Register Button
            registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            registerButton.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 30),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func registerTapped() {
        // Hide keyboard
        view.endEditing(true)
        
        // Validate inputs
        guard validateInputs() else { return }
        
        // Show loading
        showLoading()
        
        // Create request with single name field
        let registerRequest = RegisterRequest(
            name: fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            email: emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            password: passwordTextField.text ?? ""
        )
        
        print("Sending registration request with name: \(registerRequest.name)")
        
        // Call API
        NetworkManager.shared.register(request: registerRequest) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                self?.handleRegistrationResult(result)
            }
        }
    }
    
    @objc private func loginTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Validation
    private func validateInputs() -> Bool {
        // Validate full name
        guard let fullName = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !fullName.isEmpty else {
            showAlert(title: "Validation Error", message: "Please enter your full name")
            fullNameTextField.becomeFirstResponder()
            return false
        }
        
        // Validate email
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showAlert(title: "Validation Error", message: "Please enter your email")
            emailTextField.becomeFirstResponder()
            return false
        }
        
        guard isValidEmail(email) else {
            showAlert(title: "Validation Error", message: "Please enter a valid email address")
            emailTextField.becomeFirstResponder()
            return false
        }
        
        // Validate password
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Validation Error", message: "Please enter a password")
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        guard password.count >= 6 else {
            showAlert(title: "Validation Error", message: "Password must be at least 6 characters")
            passwordTextField.becomeFirstResponder()
            return false
        }
        
        // Validate confirm password
        guard let confirmPassword = confirmPasswordTextField.text,
              !confirmPassword.isEmpty else {
            showAlert(title: "Validation Error", message: "Please confirm your password")
            confirmPasswordTextField.becomeFirstResponder()
            return false
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Validation Error", message: "Passwords do not match")
            confirmPasswordTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Handle Registration Result
    private func handleRegistrationResult(_ result: Result<AuthResponse, NetworkError>) {
        switch result {
        case .success(let response):
            if response.ok {
                // Save user info from registration
                let name = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                UserDefaults.standard.set(name, forKey: "userName")
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.synchronize()
                
                // Show success
                showSuccessAlert(message: response.message)
            } else {
                // API returned error
                showAlert(title: "Registration Failed", message: response.message)
            }
            
        case .failure(let error):
            handleNetworkError(error)
        }
    }

    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .invalidURL:
            showAlert(title: "Error", message: "Invalid URL configuration")
        case .noData:
            showAlert(title: "Error", message: "No response from server")
        case .decodingError(let decodingError):
            showAlert(title: "Error", message: "Failed to process server response: \(decodingError.localizedDescription)")
        case .encodingError(let encodingError):
            showAlert(title: "Error", message: "Failed to prepare request: \(encodingError.localizedDescription)")
        case .serverError(let message):
            // Try to parse array error messages
            if let data = message.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                if let messages = json["message"] as? [String] {
                    // Error messages in array format
                    let errorMessage = messages.joined(separator: "\n")
                    showAlert(title: "Validation Error", message: errorMessage)
                } else if let errorMessage = json["message"] as? String {
                    // Single error message
                    showAlert(title: "Error", message: errorMessage)
                } else {
                    showAlert(title: "Error", message: message)
                }
            } else {
                showAlert(title: "Error", message: message)
            }
        case .unauthorized:
            showAlert(title: "Session Expired", message: "Please login again")
        case .forbidden:
            showAlert(title: "Access Denied", message: "You don't have permission")
        case .notFound:
            showAlert(title: "Not Found", message: "Resource not found")
        case .rateLimited:
            showAlert(title: "Too Many Requests", message: "Please try again later")
        case .networkError(let networkError):
            showAlert(title: "Network Error", message: networkError.localizedDescription)
        case .unknown:
            showAlert(title: "Error", message: "An unknown error occurred")
        }
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success!",
            message: "\(message)\n\nYou have been automatically logged in.",
            preferredStyle: .alert
        )
        
        present(alert, animated: true)
        
        // Auto-dismiss and navigate after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            alert.dismiss(animated: true) {
                // Add a smooth transition
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.alpha = 0.8
                }) { _ in
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.showMainApp(animated: true)
                    }
                }
            }
        }
    }
    
    private func navigateToMainScreen() {
        // Check if we have a token (user should be logged in)
        if NetworkManager.shared.authToken != nil {
            print("✅ User is logged in, navigating to main screen")
            
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                       sceneDelegate.showMainApp()
                   }
               } else {
                   // Go back to login
                   navigationController?.popViewController(animated: true)
               }
    }

    
    // MARK: - Helper Methods
    private func showLoading() {
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        loadingView.tag = 999
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView.center
        activityIndicator.startAnimating()
        loadingView.addSubview(activityIndicator)
        
        view.addSubview(loadingView)
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        view.subviews.forEach { subview in
            if subview.tag == 999 {
                subview.removeFromSuperview()
            }
        }
        view.isUserInteractionEnabled = true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController {
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case fullNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            registerTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
