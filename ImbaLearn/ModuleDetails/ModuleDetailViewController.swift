import UIKit

class ModuleDetailViewController: BaseViewController {
    
    // MARK: - UI Elements
    // Header
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Module Info
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var creatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var creatorAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        return imageView
    }()
    
    private lazy var creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var termsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Study Modes Section
    private lazy var studyModesLabel: UILabel = {
        let label = UILabel()
        label.text = "Study Modes"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardsModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cards", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .pinkButton
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(cardsModeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add card icon
        let cardIcon = UIImageView(image: UIImage(systemName: "rectangle.fill.on.rectangle.fill"))
        cardIcon.tintColor = .white
        cardIcon.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(cardIcon)
        
        // Add star icon (initially hidden)
        let starIcon = UIImageView(image: UIImage(systemName: "star.fill"))
        starIcon.tintColor = .gray
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        starIcon.isHidden = true
        starIcon.tag = 999 // Tag to identify the star icon
        button.addSubview(starIcon)
        
        NSLayoutConstraint.activate([
            cardIcon.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            cardIcon.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            cardIcon.widthAnchor.constraint(equalToConstant: 24),
            cardIcon.heightAnchor.constraint(equalToConstant: 24),
            
            starIcon.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
            starIcon.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -12),
            starIcon.widthAnchor.constraint(equalToConstant: 16),
            starIcon.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return button
    }()
    
    // Terms Filter
    private lazy var filterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["All", "Favorites"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    // Terms Table
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(TermCell.self, forCellReuseIdentifier: "TermCell")
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No terms yet"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .pinkButton
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    var module: ModuleResponse!
    private let viewModel = ModuleDetailViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
        setupViewModelCallbacks()
        
        // Set module in ViewModel and load data
        viewModel.module = module
        loadModuleDetails()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .background
        
        // Header
        view.addSubview(backButton)
        view.addSubview(menuButton)
        
        // Module Info
        view.addSubview(titleLabel)
        view.addSubview(creatorView)
        view.addSubview(termsCountLabel)
        
        // Add subviews to creatorView
        creatorView.addSubview(creatorAvatarImageView)
        creatorView.addSubview(creatorNameLabel)
        
        // Study Modes
        view.addSubview(studyModesLabel)
        view.addSubview(cardsModeButton)
        
        // Terms Filter
        view.addSubview(filterSegmentedControl)
        
        // Terms Table
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)
        
        emptyStateView.addSubview(emptyStateLabel)
        
        // Hide creator view initially
        creatorView.isHidden = true
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Header buttons
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            menuButton.widthAnchor.constraint(equalToConstant: 40),
            menuButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Module Info
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Creator View
            creatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            creatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            creatorView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -padding),
            creatorView.heightAnchor.constraint(equalToConstant: 30),
            
            creatorAvatarImageView.leadingAnchor.constraint(equalTo: creatorView.leadingAnchor),
            creatorAvatarImageView.centerYAnchor.constraint(equalTo: creatorView.centerYAnchor),
            creatorAvatarImageView.widthAnchor.constraint(equalToConstant: 30),
            creatorAvatarImageView.heightAnchor.constraint(equalToConstant: 30),
            
            creatorNameLabel.leadingAnchor.constraint(equalTo: creatorAvatarImageView.trailingAnchor, constant: 8),
            creatorNameLabel.trailingAnchor.constraint(equalTo: creatorView.trailingAnchor),
            creatorNameLabel.centerYAnchor.constraint(equalTo: creatorView.centerYAnchor),
            
            termsCountLabel.topAnchor.constraint(equalTo: creatorView.bottomAnchor, constant: 8),
            termsCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            termsCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Study Modes
            studyModesLabel.topAnchor.constraint(equalTo: termsCountLabel.bottomAnchor, constant: 30),
            studyModesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            studyModesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            cardsModeButton.topAnchor.constraint(equalTo: studyModesLabel.bottomAnchor, constant: 12),
            cardsModeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            cardsModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            cardsModeButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Terms Filter
            filterSegmentedControl.topAnchor.constraint(equalTo: cardsModeButton.bottomAnchor, constant: 30),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            // Terms Table
            tableView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Empty State
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ModuleTermCell.self, forCellReuseIdentifier: "ModuleTermCell")
    }
    
    private func setupViewModelCallbacks() {
        viewModel.delegate = self
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        titleLabel.text = viewModel.getModuleTitle()
        termsCountLabel.text = viewModel.getTermsCountText()
        
        // Update creator view
        if viewModel.hasCreatorInfo {
            creatorView.isHidden = false
            creatorNameLabel.text = "Created by \(viewModel.getCreatorName() ?? "Unknown")"
            
            // Load avatar if available
            if let avatarUrl = viewModel.getCreatorAvatarUrl() {
                loadProfileImage(from: avatarUrl, for: viewModel.creatorInfo!)
            } else {
                setPlaceholderAvatar(for: viewModel.creatorInfo!)
            }
        } else {
            creatorView.isHidden = true
        }
        
        tableView.reloadData()
        loadingIndicator.stopAnimating()
    }
    
    private func updateCardsModeButton(_ isEnabled: Bool) {
        if viewModel.shouldShowOnlyFavorites {
            // Show star icon when in Favorites mode
            if let starIcon = cardsModeButton.viewWithTag(999) as? UIImageView {
                starIcon.isHidden = false
                starIcon.tintColor = .gray
            }
        } else {
            // Hide star icon when in All mode
            if let starIcon = cardsModeButton.viewWithTag(999) as? UIImageView {
                starIcon.isHidden = true
            }
        }
        
        cardsModeButton.isEnabled = isEnabled
        cardsModeButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    private func updateEmptyState(shouldShow: Bool, message: String) {
        tableView.isHidden = shouldShow
        emptyStateView.isHidden = !shouldShow
        emptyStateLabel.text = message
    }
    
    // MARK: - API Methods
    private func loadModuleDetails() {
        loadingIndicator.startAnimating()
        viewModel.loadModuleDetails()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        print("🔙 Back button tapped")
        navigateBack()
    }
    
    @objc private func menuButtonTapped() {
        showModuleMenu()
    }
    
    @objc private func cardsModeTapped() {
        print("🎯 Cards button tapped")
        viewModel.navigateToCardsMode()
    }
    
    @objc private func filterChanged() {
        viewModel.toggleFavoriteFilter()
        filterSegmentedControl.selectedSegmentIndex = viewModel.shouldShowOnlyFavorites ? 1 : 0
    }
    
//    // MARK: - Navigation Methods
//    private func navigateToCardsMode(_ module: ModuleResponse, terms: [TermResponse]) {
//        let cardsVC = CardsModeViewController()
//        cardsVC.module = module
//        cardsVC.terms = terms
//        
//        // Add callback to refresh terms when returning
//        cardsVC.onFavoriteUpdate = { [weak self] in
//            self?.loadModuleDetails()
//        }
//        
//        if let navController = navigationController {
//            navController.pushViewController(cardsVC, animated: true)
//        } else {
//            cardsVC.modalPresentationStyle = .fullScreen
//            present(cardsVC, animated: true)
//        }
//    }
    
    private func navigateToCardsMode(_ module: ModuleResponse, terms: [TermResponse]) {
        let viewModel = CardsModeViewModel(module: module, terms: terms)
        let cardsVC = CardsModeViewController(viewModel: viewModel)
        
        // Add callback to refresh terms when returning
        cardsVC.onFavoriteUpdate = { [weak self] in
            self?.loadModuleDetails()
        }
        
        if let navController = navigationController {
            navController.pushViewController(cardsVC, animated: true)
        } else {
            cardsVC.modalPresentationStyle = .fullScreen
            present(cardsVC, animated: true)
        }
    }
    
    private func navigateToEditModule(_ module: ModuleResponse, terms: [TermResponse]) {
        let editVC = EditModuleViewController()
        editVC.module = module
        editVC.terms = terms
        
        editVC.onModuleUpdated = { [weak self] updatedModule in
            self?.viewModel.updateModule(updatedModule)
        }
        
        editVC.onTermsUpdated = { [weak self] updatedTerms in
            self?.viewModel.updateTerms(updatedTerms)
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func showModuleMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit Module", style: .default) { [weak self] _ in
            self?.viewModel.editModule()
        }
        
        let deleteAction = UIAlertAction(title: "Delete Module", style: .destructive) { [weak self] _ in
            self?.deleteModule()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func deleteModule() {
        let alert = UIAlertController(
            title: "Delete Module",
            message: "Are you sure you want to delete '\(module.title)'? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.confirmDeleteModule()
        })
        
        present(alert, animated: true)
    }
    
    private func confirmDeleteModule() {
        loadingIndicator.startAnimating()
        viewModel.deleteModule()
    }
    
    private func showModuleDeletedSuccess() {
        loadingIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Success",
            message: "Module deleted successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateBack()
        })
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        loadingIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateBack() {
        print("🔙 Navigating back")
        
        if let navigationController = navigationController, navigationController.presentingViewController != nil {
            print("📱 Dismissing modally")
            navigationController.dismiss(animated: true)
        } else if let navController = navigationController {
            print("⬅️ Popping from navigation stack")
            navController.popViewController(animated: true)
        } else if presentingViewController != nil {
            print("📱 Dismissing directly")
            dismiss(animated: true)
        } else {
            print("❌ Couldn't determine how to go back")
            dismiss(animated: true)
        }
    }
    
    // MARK: - Avatar Methods (Keep these in VC since they're UI-specific)
    // MARK: - Avatar Methods (Keep these in VC since they're UI-specific)
    private func loadProfileImage(from url: URL, for creatorInfo: UserInfo) {
        print("🔄 Loading profile image for creator: \(creatorInfo.name)")
        print("🔗 URL: \(url.absoluteString)")
        
        // Show placeholder first
        setPlaceholderAvatar(for: creatorInfo)
        
        // Check cache first - IMPORTANT: Use same cache key as AccountViewController
        let cacheKey = "profileImage_\(creatorInfo.id)"
        if let cachedImageData = UserDefaults.standard.data(forKey: cacheKey),
           let cachedImage = UIImage(data: cachedImageData) {
            creatorAvatarImageView.image = cachedImage
            creatorAvatarImageView.tintColor = nil
            print("✅ Loaded creator avatar from cache: \(creatorInfo.name)")
            return
        }
        
        // Download image
        print("🌐 Downloading avatar from server...")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error loading creator avatar: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.setPlaceholderAvatar(for: creatorInfo)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("❌ Invalid image data for creator avatar")
                DispatchQueue.main.async {
                    self.setPlaceholderAvatar(for: creatorInfo)
                }
                return
            }
            
            DispatchQueue.main.async {
                print("✅ Successfully loaded creator avatar for: \(creatorInfo.name)")
                
                // Set the actual image
                self.creatorAvatarImageView.image = image
                self.creatorAvatarImageView.tintColor = nil
                
                // Cache the image - USE SAME KEY AS ACCOUNT VIEW
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    UserDefaults.standard.set(imageData, forKey: cacheKey)
                    UserDefaults.standard.synchronize()
                    print("✅ Creator avatar cached with key: \(cacheKey)")
                }
            }
        }.resume()
    }
    
    private func setPlaceholderAvatar(for creatorInfo: UserInfo) {
        print("🖼️ Setting placeholder for: \(creatorInfo.name)")
        
        if creatorInfo.isCurrentUser {
            creatorAvatarImageView.image = UIImage(systemName: "person.circle.fill")
            creatorAvatarImageView.tintColor = .pinkButton
        } else {
            // Try to get from cache first with correct key
            let cacheKey = "profileImage_\(creatorInfo.id)"
            if let cachedImageData = UserDefaults.standard.data(forKey: cacheKey),
               let cachedImage = UIImage(data: cachedImageData) {
                creatorAvatarImageView.image = cachedImage
                creatorAvatarImageView.tintColor = nil
                print("✅ Found cached avatar for placeholder")
                return
            }
            
            // If no cached image, create initial-based placeholder
            if let firstLetter = creatorInfo.name.first {
                let label = UILabel()
                label.text = String(firstLetter).uppercased()
                label.textAlignment = .center
                label.font = .systemFont(ofSize: 12, weight: .bold)
                label.textColor = .white
                label.backgroundColor = .gray
                label.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                label.layer.cornerRadius = 15
                label.layer.masksToBounds = true
                
                UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
                label.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                creatorAvatarImageView.image = image
                creatorAvatarImageView.tintColor = nil
                print("📝 Created initial-based placeholder for: \(creatorInfo.name)")
            } else {
                creatorAvatarImageView.image = UIImage(systemName: "person.circle.fill")
                creatorAvatarImageView.tintColor = .gray
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension ModuleDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTerms
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleTermCell", for: indexPath) as! ModuleTermCell
        
        if let term = viewModel.getTerm(at: indexPath) {
            cell.configure(with: term)
            
            cell.onStarTapped = { [weak self] in
                self?.viewModel.toggleFavorite(for: term.id)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do nothing - cells are not selectable
    }
}


extension ModuleDetailViewController: ModuleDetailViewModelDelegate {
    func onDataUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
    
    func onError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showError(message: message)
        }
    }
    
    func onModuleDeleted() {
        DispatchQueue.main.async { [weak self] in
            self?.showModuleDeletedSuccess()
        }
    }
    
    func onNavigateToEditModule(_ module: ModuleResponse, terms: [TermResponse]) {
        DispatchQueue.main.async { [weak self] in
            self?.navigateToEditModule(module, terms: terms)
        }
    }
    
    func onNavigateToCardsMode(_ module: ModuleResponse, terms: [TermResponse]) {
        DispatchQueue.main.async { [weak self] in
            self?.navigateToCardsMode(module, terms: terms)
        }
    }
    
    func onNavigateBack() {
        DispatchQueue.main.async { [weak self] in
            self?.navigateBack()
        }
    }
    
    func onUpdateCardsButtonState(_ isEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.updateCardsModeButton(isEnabled)
        }
    }
    
    func onUpdateEmptyState(_ isEmpty: Bool, message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.updateEmptyState(shouldShow: isEmpty, message: message)
        }
    }
    
}
