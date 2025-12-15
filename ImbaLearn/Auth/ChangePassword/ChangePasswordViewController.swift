//
//  ChangePasswordViewController.swift
//  ImbaLearn
//

import UIKit

class ChangePasswordViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel = ChangePasswordViewModel()
    
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
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Change Password"
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.alpha = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Current Password
    private lazy var currentPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Old Password"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var currentPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter old password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        textField.applyShadow()
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Add show/hide button
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(toggleCurrentPasswordVisibility), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        
        return textField
    }()
    
    // New Password
    private lazy var newPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "New Password"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter new password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.applyShadow()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Add show/hide button
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.addTarget(self, action: #selector(toggleNewPasswordVisibility), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        
        return textField
    }()
    
    // Confirm New Password
    private lazy var confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm New Password"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm new password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.applyShadow()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Add show/hide button
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 40)
        button.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        
        return textField
    }()
    
    // Password requirements label
    private lazy var requirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "• At least 8 characters\n• At least one uppercase letter\n• At least one lowercase letter\n• At least one number"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Change Password Button
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Password", for: .normal)
        button.backgroundColor = .greenButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
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
        setupNavigationBar()
        setupViewModelCallbacks()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .background
        
        // Add header view
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all form elements to contentView
        contentView.addSubviews(
            currentPasswordLabel, currentPasswordTextField,
            newPasswordLabel, newPasswordTextField,
            confirmPasswordLabel, confirmPasswordTextField,
            requirementsLabel,
            changePasswordButton
        )
        
        // Add loading view
        view.addSubview(loadingView)
    }
    
    private func setupNavigationBar() {
        // Hide the default back button if it exists
        navigationItem.hidesBackButton = true
    }
    
    private func setupTextFields() {
        // Set up text field delegates
        let textFields = [currentPasswordTextField, newPasswordTextField, confirmPasswordTextField]
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
        
        viewModel.onNavigateBack = { [weak self] in
            self?.navigateBack()
        }
        
        viewModel.onNavigateToLogin = { [weak self] in
            self?.logoutAndGoToLogin()
        }
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 60
        let labelHeight: CGFloat = 20
        let headerHeight: CGFloat = 150
        
        NSLayoutConstraint.activate([
            // Header View
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            // Back Button
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: padding),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Title Label
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -padding),
            
            // Scroll View
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
            
            // Current Password Label
            currentPasswordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            currentPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            currentPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            currentPasswordLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Current Password Text Field
            currentPasswordTextField.topAnchor.constraint(equalTo: currentPasswordLabel.bottomAnchor, constant: 8),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            currentPasswordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // New Password Label
            newPasswordLabel.topAnchor.constraint(equalTo: currentPasswordTextField.bottomAnchor, constant: 20),
            newPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            newPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            newPasswordLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // New Password Text Field
            newPasswordTextField.topAnchor.constraint(equalTo: newPasswordLabel.bottomAnchor, constant: 8),
            newPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            newPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Confirm Password Label
            confirmPasswordLabel.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 20),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            confirmPasswordLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Confirm Password Text Field
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 8),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Requirements Label
            requirementsLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 15),
            requirementsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            requirementsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            // Change Password Button
            changePasswordButton.topAnchor.constraint(equalTo: requirementsLabel.bottomAnchor, constant: 30),
            changePasswordButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            changePasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            changePasswordButton.heightAnchor.constraint(equalToConstant: fieldHeight),
            changePasswordButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        print("← Back button tapped")
        viewModel.navigateBack()
    }
    
    @objc private func toggleCurrentPasswordVisibility() {
        viewModel.toggleCurrentPasswordVisibility()
        updatePasswordFieldVisibility()
    }
    
    @objc private func toggleNewPasswordVisibility() {
        viewModel.toggleNewPasswordVisibility()
        updatePasswordFieldVisibility()
    }
    
    @objc private func toggleConfirmPasswordVisibility() {
        viewModel.toggleConfirmPasswordVisibility()
        updatePasswordFieldVisibility()
    }
    
    @objc private func changePasswordTapped() {
        view.endEditing(true)
        viewModel.changePassword(
            currentPassword: currentPasswordTextField.text,
            newPassword: newPasswordTextField.text,
            confirmPassword: confirmPasswordTextField.text
        )
    }
    
    // MARK: - State Handling
    private func handleViewState(_ state: ChangePasswordViewModel.ViewState) {
        switch state {
        case .idle:
            // Do nothing
            break
            
        case .loading:
            showLoading()
            
        case .success(let message):
            hideLoading()
            showSuccessAlert(message: message)
            
        case .validationError(let title, let message, let field):
            hideLoading()
            showAlert(title: title, message: message)
            focusOnField(field)
            
        case .changePasswordError(let title, let message):
            hideLoading()
            showAlert(title: title, message: message)
            
        case .networkError(let error):
            hideLoading()
            handleNetworkError(error)
        }
    }
    
    private func focusOnField(_ field: ChangePasswordViewModel.FocusField) {
        switch field {
        case .currentPassword:
            currentPasswordTextField.becomeFirstResponder()
        case .newPassword:
            newPasswordTextField.becomeFirstResponder()
        case .confirmPassword:
            confirmPasswordTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - UI Updates
    private func updatePasswordFieldVisibility() {
        // Update current password field
        currentPasswordTextField.isSecureTextEntry = !viewModel.isCurrentPasswordVisible
        let currentButton = currentPasswordTextField.rightView as? UIButton
        let currentImageName = viewModel.isCurrentPasswordVisible ? "eye" : "eye.slash"
        currentButton?.setImage(UIImage(systemName: currentImageName), for: .normal)
        
        // Update new password field
        newPasswordTextField.isSecureTextEntry = !viewModel.isNewPasswordVisible
        let newButton = newPasswordTextField.rightView as? UIButton
        let newImageName = viewModel.isNewPasswordVisible ? "eye" : "eye.slash"
        newButton?.setImage(UIImage(systemName: newImageName), for: .normal)
        
        // Update confirm password field
        confirmPasswordTextField.isSecureTextEntry = !viewModel.isConfirmPasswordVisible
        let confirmButton = confirmPasswordTextField.rightView as? UIButton
        let confirmImageName = viewModel.isConfirmPasswordVisible ? "eye" : "eye.slash"
        confirmButton?.setImage(UIImage(systemName: confirmImageName), for: .normal)
    }
    
    // MARK: - Navigation
    private func navigateBack() {
        // Try different ways to go back
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            // If we're in a navigation stack, pop back
            navigationController.popViewController(animated: true)
        } else if let presentingViewController = presentingViewController {
            // If we were presented modally, dismiss
            dismiss(animated: true, completion: nil)
        } else {
            // Fallback: just dismiss if nothing else works
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func logoutAndGoToLogin() {
        // Navigate to login
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showAuthentication(animated: true)
        }
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
            message: "\(message)\n\nPlease login again with your new password.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Logout and go to login screen
            self?.viewModel.logoutAndGoToLogin()
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func handleNetworkError(_ error: NetworkError) {
        switch error {
        case .unauthorized:
            showAlert(title: "Invalid Password", message: "Your old password is incorrect")
            currentPasswordTextField.becomeFirstResponder()
        case .serverError(let message):
            // Try to parse the error message
            if let data = message.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                if let messages = json["message"] as? [String] {
                    let errorMessage = messages.joined(separator: "\n")
                    showAlert(title: "Error", message: errorMessage)
                } else if let errorMessage = json["message"] as? String {
                    showAlert(title: "Error", message: errorMessage)
                } else {
                    showAlert(title: "Error", message: message)
                }
            } else {
                showAlert(title: "Error", message: message)
            }
        default:
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ChangePasswordViewController {
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case currentPasswordTextField:
            newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            textField.resignFirstResponder()
            changePasswordTapped()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
