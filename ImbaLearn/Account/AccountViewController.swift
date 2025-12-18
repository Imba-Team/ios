import UIKit
import PhotosUI

class AccountViewController: BaseViewController {
    
    // MARK: - Properties
    private var viewModel = AccountViewModel()
    
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
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var avatarLabel: UILabel = {
        let label = UILabel()
        label.text = "?"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var editAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: "pencil.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .pinkButton
        button.backgroundColor = .white
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.background.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editAvatarTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "loading..."
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        textField.applyShadow()
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
        textField.applyShadow()
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
        textField.applyShadow()
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //  setupTextFields()
        setupViewModelCallbacks()
        setupAvatarGesture()
        viewModel.loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh user data when view appears
        viewModel.loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Account"
        
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add avatar and user info
        avatarContainer.addSubview(avatarCircle)
        avatarCircle.addSubview(avatarImageView)
        avatarCircle.addSubview(avatarLabel)
        avatarContainer.addSubview(editAvatarButton)
        
        contentView.addSubviews(nameLabel, emailLabel)
        
        
        // Add all elements to content view
        contentView.addSubviews(avatarContainer, nameFieldLabel, nameTextField, emailFieldLabel, emailTextField, passwordLabel, passwordTextField, changePasswordButton, logoutButton, deleteAccountButton)
        setupConstraints()
    }
    
    private func setupAvatarGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editAvatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
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
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 80),
            avatarContainer.heightAnchor.constraint(equalToConstant: 80),
            
            // Avatar Circle
            avatarCircle.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarCircle.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            avatarCircle.widthAnchor.constraint(equalToConstant: 80),
            avatarCircle.heightAnchor.constraint(equalToConstant: 80),
            
            // Avatar Image View
            avatarImageView.centerXAnchor.constraint(equalTo: avatarCircle.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarCircle.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalTo: avatarCircle.widthAnchor),
            avatarImageView.heightAnchor.constraint(equalTo: avatarCircle.heightAnchor),
            
            // Avatar Label
            avatarLabel.centerXAnchor.constraint(equalTo: avatarCircle.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarCircle.centerYAnchor),
            
            // Edit Avatar Button
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: -2),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: -2),
            editAvatarButton.widthAnchor.constraint(equalToConstant: 28),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 28),
            
            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding),
            
            // Email Label - centered below name
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: padding),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding),
            
            // Name Field Label
            nameFieldLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
            
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
    
    private func setupViewModelCallbacks() {
        viewModel.delegate = self
    }
    
    // MARK: - UI Updates
    private func updateUI(with user: User?) {
        if let user = user {
            // Update labels
            nameLabel.text = user.name
            emailLabel.text = user.email
            
            // Update text fields
            nameTextField.text = user.name
            emailTextField.text = user.email
            
            // Update avatar
            updateAvatar(for: user.name)
        } else {
            // Show placeholder data
            avatarLabel.text = "?"
            nameLabel.text = "Not logged in"
            emailLabel.text = "Please login"
            nameTextField.text = ""
            emailTextField.text = ""
            avatarImageView.image = nil
            avatarLabel.isHidden = false
            avatarCircle.backgroundColor = .lightGray
        }
    }
    
    private func updateAvatar(for name: String) {
        // Show label if no image, hide if image exists
        avatarLabel.text = viewModel.getAvatarFirstLetter(for: name)
        avatarLabel.isHidden = (viewModel.profileImage != nil)
        avatarCircle.backgroundColor = viewModel.getAvatarColor(for: name)
    }
    
    private func updateProfileImage(_ image: UIImage?) {
        if let image = image {
            avatarImageView.image = image
            avatarLabel.isHidden = true
            avatarCircle.backgroundColor = .clear
        } else {
            avatarImageView.image = nil
            avatarLabel.isHidden = false
            if let user = viewModel.currentUser {
                updateAvatar(for: user.name)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func editAvatarTapped() {
        let pickerVC = ProfileImagePickerViewController()
        pickerVC.delegate = self
        pickerVC.hasExistingPhoto = (viewModel.profileImage != nil) // Pass whether user has photo
        pickerVC.modalPresentationStyle = .overFullScreen
        pickerVC.modalTransitionStyle = .crossDissolve
        present(pickerVC, animated: true)
    }
    
    @objc private func changePasswordTapped() {
        print("Change password tapped - attempting to navigate...")
        
        let changePasswordVC = ChangePasswordViewController()
        
        // Always try to present modally for consistency
        let navController = UINavigationController(rootViewController: changePasswordVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true) {
            print("✅ ChangePasswordViewController presented successfully")
        }
    }
    
    @objc private func logoutTapped() {
        showAlert(
            title: "Logout",
            message: "Are you sure you want to logout?",
            handlers: [
                UIAlertAction(title: "Cancel", style: .cancel),
                UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
                    self?.viewModel.performLogout()
                }
            ])
    }
    
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "This action cannot be undone. All your data will be permanently deleted.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.performAccountDeletion()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateToAuthentication() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showAuthentication(animated: true)
        }
    }
    
    // MARK: - Helper Methods
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ProfileImagePickerDelegate
extension AccountViewController: ProfileImagePickerDelegate {
    func didSelectImage(_ image: UIImage) {
        viewModel.setProfileImage(image)
    }
    
    func didRemoveImage() {
        viewModel.removeProfileImage()
    }
}

extension AccountViewController: AccountViewModelDelegate {
    func onUserDataUpdated(_ user: User?) {
        updateUI(with: user)
    }
    
    func onProfileImageUpdated(_ image: UIImage?) {
        updateProfileImage(image)
    }
    
    func onError(_ message: String) {
        showError(message: message)
    }
    
    func onLogoutSuccess() {
        navigateToAuthentication()
    }
    
    func onAccountDeleteSuccess() {
        let alert = UIAlertController(
            title: "Account Deleted",
            message: "Your account has been successfully deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToAuthentication()
        })
        present(alert, animated: true)
    }
}
