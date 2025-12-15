//
//  LoginViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 17.11.25.
//

import UIKit

class LoginViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel = LoginViewModel()
    
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .pinkButton.withAlphaComponent(0.7)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ImbaLearn"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .pinkButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Member? Register!", for: .normal)
        button.setTitleColor(.pinkButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView(frame: view.bounds)
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
        navigationController?.navigationBar.tintColor = .white

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient layer frame when view layout changes
        if let gradientLayer = headerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = headerView.bounds
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubviews(headerView, scrollView, loadingView)
        
        headerView.addSubview(titleLabel)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(emailLabel, emailTextField, passwordLabel, passwordTextField, loginButton, registerButton)
                
        // Add button targets
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    private func setupTextFields() {
        // Set up text field delegates
        let textFields = [emailTextField, passwordTextField]
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
        
        viewModel.onNavigateToRegister = { [weak self] in
            self?.navigateToRegister()
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
            
            // Email Label
            emailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
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
            
            // Login Button (positioned directly under password field)
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            loginButton.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Register Button
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 30),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func loginTapped() {
        // Hide keyboard
        view.endEditing(true)
        
        // Call viewModel login
        viewModel.login(email: emailTextField.text, password: passwordTextField.text)
    }
    
    @objc private func registerTapped() {
        viewModel.navigateToRegister()
    }
    
    // MARK: - State Handling
    private func handleViewState(_ state: LoginViewModel.ViewState) {
        switch state {
        case .idle:
            // Do nothing
            break
            
        case .loading:
            showLoading()
            
        case .success(let message):
            hideLoading()
            if let message = message {
                showSuccessMessage(message)
            }
            
        case .validationError(let title, let message):
            hideLoading()
            showAlert(title: title, message: message)
            focusOnField(for: title, message: message)
            
        case .loginError(let title, let message):
            hideLoading()
            showAlert(title: title, message: message)
            
        case .networkError(let error):
            hideLoading()
            handleNetworkError(error)
        }
    }
    
    private func focusOnField(for title: String, message: String) {
        if message.contains("email") {
            emailTextField.becomeFirstResponder()
        } else if message.contains("password") || message.contains("Password") {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Navigation
    private func navigateToMainApp() {
        // Optional: Add a brief fade animation before navigation
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0.8
        }) { _ in
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showMainApp(animated: true)
            }
        }
    }
    
    private func navigateToRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
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
    
    private func showSuccessMessage(_ message: String) {
        // Show a brief success message
        let alert = UIAlertController(
            title: "Success!",
            message: message,
            preferredStyle: .alert
        )
        
        present(alert, animated: true)
        
        // Dismiss after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
            showAlert(title: "Login Failed", message: "Invalid email or password")
        case .forbidden:
            showAlert(title: "Access Denied", message: "You don't have permission")
        case .notFound:
            showAlert(title: "User Not Found", message: "No account found with this email")
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
extension LoginViewController {
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            loginTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
