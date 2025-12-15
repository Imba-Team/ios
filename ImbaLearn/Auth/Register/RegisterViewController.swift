//
//  RegisterViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 17.11.25.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel = RegisterViewModel()
    
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
        view.backgroundColor = .pinkButton.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Register"
        label.textColor = .white
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
        textField.applyShadow()
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
        textField.applyShadow()
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
        textField.applyShadow()
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
        textField.applyShadow()
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
    
    private lazy var loadingView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTextFields()
        setupViewModelCallbacks()
    }
    
    // MARK: - Setup Methods
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
        
        // Add loading view
        view.addSubview(loadingView)
        
        // Add button targets
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
    
    private func setupViewModelCallbacks() {
        viewModel.onViewStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleViewState(state)
            }
        }
        
        viewModel.onNavigateToMainApp = { [weak self] in
            self?.navigateToMainApp()
        }
        
        viewModel.onNavigateToLogin = { [weak self] in
            self?.navigateToLogin()
        }
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
        
        // Call viewModel register
        viewModel.register(
            fullName: fullNameTextField.text,
            email: emailTextField.text,
            password: passwordTextField.text,
            confirmPassword: confirmPasswordTextField.text
        )
    }
    
    @objc private func loginTapped() {
        viewModel.navigateToLogin()
    }
    
    // MARK: - State Handling
    private func handleViewState(_ state: RegisterViewModel.ViewState) {
        switch state {
        case .idle:
            // Do nothing
            break
            
        case .loading:
            showLoading()
            
        case .success(let message):
            hideLoading()
            showSuccessAlert(message: message)
            
        case .validationError(let title, let message):
            hideLoading()
            showAlert(title: title, message: message)
            focusOnField(for: title, message: message)
            
        case .registrationError(let title, let message):
            hideLoading()
            showAlert(title: title, message: message)
            
        case .networkError(let error):
            hideLoading()
            handleNetworkError(error)
        }
    }
    
    private func focusOnField(for title: String, message: String) {
        if message.contains("full name") || message.contains("Full Name") {
            fullNameTextField.becomeFirstResponder()
        } else if message.contains("email") || message.contains("Email") {
            emailTextField.becomeFirstResponder()
        } else if message.contains("password") || message.contains("Password") {
            if message.contains("confirm") || message.contains("Confirm") {
                confirmPasswordTextField.becomeFirstResponder()
            } else {
                passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - Navigation
    private func navigateToMainApp() {
        // Add a smooth transition
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0.8
        }) { _ in
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showMainApp(animated: true)
            }
        }
    }
    
    private func navigateToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI Helper Methods
    private func showLoading() {
        loadingView.isHidden = false
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        loadingView.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success!",
            message: "\(message)\n\nYou have been automatically logged in.",
            preferredStyle: .alert
        )
        
        present(alert, animated: true)
        
        // Auto-dismiss and navigate after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
