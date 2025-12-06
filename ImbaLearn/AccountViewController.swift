//
//  AccountViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 17.11.25.
//

import UIKit

class AccountViewController: BaseViewController {
    
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
    
    private lazy var avatarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .color
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarLabel: UILabel = {
        let label = UILabel()
        label.text = "?" // Will be updated with user's first letter
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "loading..."
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    // Name Section
    private lazy var nameFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.isEnabled = false
        textField.text = "Loading..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    // Email Section
    private lazy var emailFieldLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.isEnabled = false
        textField.text = "loading..."
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    // Password Section
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "••••••••"
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.isSecureTextEntry = true
        textField.isEnabled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Password", for: .normal)
        button.setTitleColor(.pinkButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .pinkButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.pinkButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var currentUser: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTextFields()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh user data when view appears
        loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Account"
        
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add avatar and user info
        avatarContainer.addSubview(avatarCircle)
        avatarCircle.addSubview(avatarLabel)
        
        userInfoStack.addArrangedSubview(nameLabel)
        userInfoStack.addArrangedSubview(emailLabel)
        
        // Add all elements to content view
        contentView.addSubviews(avatarContainer, userInfoStack, nameFieldLabel, nameTextField, emailFieldLabel, emailTextField, passwordLabel, passwordTextField, changePasswordButton, logoutButton, deleteAccountButton)
    }
    
    private func setupTextFields() {
        // Set up text field delegates
        let textFields = [nameTextField, emailTextField]
        textFields.forEach { textField in
            textField.delegate = self
        }
        
        // Enable keyboard avoidance
        setupKeyboardAvoidance(with: scrollView)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 50
        let labelHeight: CGFloat = 20
        let verticalSpacing: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Avatar Container
            avatarContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            avatarContainer.widthAnchor.constraint(equalToConstant: 80),
            avatarContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Avatar Circle
            avatarCircle.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarCircle.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarCircle.widthAnchor.constraint(equalToConstant: 80),
            avatarCircle.heightAnchor.constraint(equalToConstant: 80),
            
            // Avatar Label
            avatarLabel.centerXAnchor.constraint(equalTo: avatarCircle.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarCircle.centerYAnchor),
            
            // User Info Stack
            userInfoStack.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 16),
            userInfoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            userInfoStack.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            // Name Field Label
            nameFieldLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 40),
            nameFieldLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameFieldLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            nameFieldLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Name Text Field
            nameTextField.topAnchor.constraint(equalTo: nameFieldLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            nameTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Email Field Label
            emailFieldLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: verticalSpacing),
            emailFieldLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emailFieldLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            emailFieldLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Email Text Field
            emailTextField.topAnchor.constraint(equalTo: emailFieldLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Password Label
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: verticalSpacing),
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            passwordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            passwordLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            // Password Text Field
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Change Password Button
            changePasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            changePasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Logout Button
            logoutButton.topAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 30),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            logoutButton.heightAnchor.constraint(equalToConstant: 55),
            
            // Delete Account Button
            deleteAccountButton.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            deleteAccountButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 30),
            deleteAccountButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Load User Data
    private func loadUserData() {
        // First try to load from saved data
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser"),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            updateUI(with: savedUser)
            print("✅ Loaded user from saved data: \(savedUser.name)")
        } else {
            // If no saved data, fetch from API
            fetchUserProfile()
        }
    }

    private func fetchUserProfile() {
        print("🔍 Fetching user profile from API...")
        
        showLoading()
        
        NetworkManager.shared.getUserProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                switch result {
                case .success(let response):
                    if response.ok {
                        let profileData = response.data
                        let user = User(from: profileData)
                        
                        // Update UI with real user data
                        self?.updateUI(with: user)
                        
                        // Save to UserDefaults for future use
                        self?.saveUserToDefaults(user)
                        
                        print("✅ Loaded user from API: \(user.name) (\(user.email))")
                    } else {
                        print("⚠️ Profile API returned error: \(response.message)")
                        self?.loadUserDataFromSaved()
                    }
                    
                case .failure(let error):
                    print("❌ Failed to fetch profile: \(error.localizedDescription)")
                    self?.loadUserDataFromSaved()
                }
            }
        }
    }

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
            updateUI(with: savedUser)
            print("✅ Loaded user from saved data: \(savedUser.name)")
        } else {
            // Show placeholder data
            updateUI(with: nil)
            print("⚠️ No user data found")
        }
    }
    
    private func updateUI(with user: User?) {
        currentUser = user
        
        if let user = user {
            // Update avatar with first letter of name
            if let firstLetter = user.name.first {
                avatarLabel.text = String(firstLetter).uppercased()
            } else {
                avatarLabel.text = "?"
            }
            
            // Update labels
            nameLabel.text = user.name
            emailLabel.text = user.email
            
            // Update text fields
            nameTextField.text = user.name
            emailTextField.text = user.email
            
            // Update avatar color based on first letter
            updateAvatarColor(for: user.name)
        } else {
            // Show placeholder data
            avatarLabel.text = "?"
            nameLabel.text = "Not logged in"
            emailLabel.text = "Please login"
            nameTextField.text = ""
            emailTextField.text = ""
            avatarCircle.backgroundColor = .lightGray
        }
    }
    
    private func updateAvatarColor(for name: String) {
        // Generate a consistent color based on the name
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemPink, .systemTeal, .systemIndigo, .systemBrown
        ]
        
        let hash = name.utf8.reduce(0) { $0 + Int($1) }
        let colorIndex = hash % colors.count
        avatarCircle.backgroundColor = colors[colorIndex]
    }
    
    // MARK: - Actions
    @objc private func changePasswordTapped() {
        print("Change password tapped - attempting to navigate...")
        
        // Check if we have a navigation controller
        if let navController = navigationController {
            print("✅ Navigation controller found, pushing ChangePasswordViewController")
            let changePasswordVC = ChangePasswordViewController()
            navController.pushViewController(changePasswordVC, animated: true)
        } else {
            print("❌ No navigation controller found!")
            
            // Try to present modally as fallback
            let changePasswordVC = ChangePasswordViewController()
            let navController = UINavigationController(rootViewController: changePasswordVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout",
                                    message: "Are you sure you want to logout?",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }
    
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(title: "Delete Account",
                                    message: "This action cannot be undone. All your data will be permanently deleted.",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performAccountDeletion()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Logout Implementation
    private func performLogout() {
        showLoading()
        
        // Call logout API if available
        NetworkManager.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading()
                
                switch result {
                case .success(let response):
                    print("✅ Logout successful: \(response.message)")
                case .failure(let error):
                    print("⚠️ Logout API error: \(error.localizedDescription)")
                    // We'll still clear local data even if API fails
                }
                
                // Clear all local data
                self?.clearLocalData()
                
                // Navigate to authentication
                self?.navigateToAuthentication()
            }
        }
    }
    
    private func clearLocalData() {
        // Clear token from NetworkManager
        NetworkManager.shared.authToken = nil
        
        // Clear all user data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()
        
        // Clear cookies
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        print("✅ All local data cleared")
    }
    
    private func navigateToAuthentication() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showAuthentication(animated: true)
        }
    }
    
    // MARK: - Account Deletion (Placeholder)
    private func performAccountDeletion() {
        // TODO: Implement actual account deletion API call
        showLoading()
        
        // For now, just simulate deletion and logout
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.hideLoading()
            
            let alert = UIAlertController(
                title: "Account Deleted",
                message: "Your account has been successfully deleted.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                // Clear data and logout
                self?.clearLocalData()
                self?.navigateToAuthentication()
            })
            self?.present(alert, animated: true)
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
}
