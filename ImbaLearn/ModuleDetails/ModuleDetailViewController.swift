//
//  ModuleDetailViewController.swift
//  ImbaLearn
//

import UIKit

class ModuleDetailViewController: BaseViewController {
    
    // MARK: - Properties
    var module: ModuleResponse!
    private var terms: [TermResponse] = []
    private var filteredTerms: [TermResponse] = []
    private var showOnlyFavorites = false
    private var isLoading = false
    private var creatorInfo: UserInfo?
    
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
        imageView.backgroundColor = .lightGray
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
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .color.withAlphaComponent(0.3)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(cardsModeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Add card icon
        let cardIcon = UIImageView(image: UIImage(systemName: "rectangle.fill.on.rectangle.fill"))
        cardIcon.tintColor = .pinkButton
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
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
    
    // MARK: - API Methods
    private func loadModuleDetails() {
        guard !isLoading else { return }
        
        isLoading = true
        loadingIndicator.startAnimating()
        
        updateModuleInfo()
        
        // Load creator info
        loadCreatorInfo()
        
        // Load terms
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    if response.ok {
                        self.terms = response.data?.data ?? []
                        
                        // Filter terms by moduleId (in case backend returns all terms)
                        // Only filter if moduleId exists in term response
                        self.terms = self.terms.filter { term in
                            guard let termModuleId = term.moduleId else { return true }
                            return termModuleId == self.module.id
                        }
                        
                        print("✅ Showing \(self.terms.count) terms for module")
                        
                        self.updateFilteredTerms()
                        self.tableView.reloadData()
                        self.updateEmptyState()
                        
                        // Update terms count label with actual count
                        self.updateTermsCountLabel()
                        
                        // Update cards mode button state
                        self.updateCardsModeButton()
                    } else {
                        self.showError(message: response.message)
                    }
                    
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateModuleInfo() {
        titleLabel.text = module.title
        termsCountLabel.text = "Loading terms..."
    }
    
    private func updateTermsCountLabel() {
        let actualTermsCount = terms.count
        termsCountLabel.text = "\(actualTermsCount) term\(actualTermsCount == 1 ? "" : "s")"
    }
    
    private func updateCardsModeButton() {
        if showOnlyFavorites {
            // Show star icon when in Favorites mode
            if let starIcon = cardsModeButton.viewWithTag(999) as? UIImageView {
                starIcon.isHidden = false
                starIcon.tintColor = .gray
            }
            
            // Check if there are any favorites
            let favoriteTerms = terms.filter { $0.isStarred }
            if favoriteTerms.isEmpty {
                // Disable button if no favorites
                cardsModeButton.isEnabled = false
                cardsModeButton.alpha = 0.5
            } else {
                // Enable button if there are favorites
                cardsModeButton.isEnabled = true
                cardsModeButton.alpha = 1.0
            }
        } else {
            // Hide star icon when in All mode
            if let starIcon = cardsModeButton.viewWithTag(999) as? UIImageView {
                starIcon.isHidden = true
            }
            
            // Check if there are any terms
            if terms.isEmpty {
                cardsModeButton.isEnabled = false
                cardsModeButton.alpha = 0.5
            } else {
                cardsModeButton.isEnabled = true
                cardsModeButton.alpha = 1.0
            }
        }
    }
    
    private func loadCreatorInfo() {
        // Check if creator is current user
        if let currentUserId = UserDefaults.standard.string(forKey: "currentUserId"),
           module.userId == currentUserId {
            // Get current user info
            NetworkManager.shared.getUserProfile { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.ok {
                            self.creatorInfo = UserInfo(from: response.data, isCurrentUser: true)
                            self.updateCreatorUI()
                        } else {
                            // Set default creator info
                            self.creatorInfo = UserInfo(
                                id: self.module.userId,
                                name: "You",
                                avatarUrl: nil,
                                isCurrentUser: true
                            )
                            self.updateCreatorUI()
                        }
                    case .failure:
                        // Set default creator info
                        self.creatorInfo = UserInfo(
                            id: self.module.userId,
                            name: "You",
                            avatarUrl: nil,
                            isCurrentUser: true
                        )
                        self.updateCreatorUI()
                    }
                }
            }
        } else {
            // For other users, we need to fetch their profile
            // Since we don't have an endpoint for that yet, show placeholder
            self.creatorInfo = UserInfo(
                id: module.userId,
                name: "Creator",
                avatarUrl: nil,
                isCurrentUser: false
            )
            self.updateCreatorUI()
        }
    }
    
    private func updateCreatorUI() {
        guard let creatorInfo = creatorInfo else {
            creatorView.isHidden = true
            return
        }
        
        creatorView.isHidden = false
        creatorNameLabel.text = "Created by \(creatorInfo.name)"
        
        // Set avatar image
        if let avatarUrl = creatorInfo.avatarUrl, !avatarUrl.isEmpty {
            // Load image from URL - you should implement image loading/caching here
            // For now, use a placeholder
            creatorAvatarImageView.image = UIImage(systemName: "person.circle.fill")
            creatorAvatarImageView.tintColor = creatorInfo.isCurrentUser ? .pinkButton : .gray
        } else {
            // Use system icon
            creatorAvatarImageView.image = UIImage(systemName: "person.circle.fill")
            creatorAvatarImageView.tintColor = creatorInfo.isCurrentUser ? .pinkButton : .gray
        }
    }
    
    private func updateFilteredTerms() {
        if showOnlyFavorites {
            filteredTerms = terms.filter { $0.isStarred }
        } else {
            filteredTerms = terms
        }
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredTerms.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if isEmpty {
            if terms.isEmpty {
                emptyStateLabel.text = "No terms yet"
            } else if showOnlyFavorites {
                emptyStateLabel.text = "No favorite terms"
            }
        }
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
        print("🎯 Cards button tapped - Mode: \(showOnlyFavorites ? "Favorites" : "All")")
        
        // Get the terms to show based on current filter
        let termsToShow = showOnlyFavorites ? terms.filter { $0.isStarred } : terms
        
        // Check if there are terms to show
        if termsToShow.isEmpty {
            if showOnlyFavorites {
                // Show alert for no favorites
                let alert = UIAlertController(
                    title: "No Favorite Terms",
                    message: "You don't have any favorite terms in this module. Add some favorites first to use Cards Mode with favorites.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            } else {
                // Show alert for no terms at all
                let alert = UIAlertController(
                    title: "No Terms",
                    message: "This module doesn't have any terms yet. Add some terms first to use Cards Mode.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
            return
        }
        
        // Open cards mode with filtered terms
        let cardsVC = CardsModeViewController()
        cardsVC.module = module
        cardsVC.terms = termsToShow
        
        // Add callback to refresh terms when returning
        cardsVC.onFavoriteUpdate = { [weak self] in
            self?.loadModuleDetails() // Reload terms to get updated favorites
        }
        
        if let navController = navigationController {
            navController.pushViewController(cardsVC, animated: true)
        } else {
            cardsVC.modalPresentationStyle = .fullScreen
            present(cardsVC, animated: true)
        }
    }
    
    @objc private func filterChanged() {
        showOnlyFavorites = filterSegmentedControl.selectedSegmentIndex == 1
        updateFilteredTerms()
        tableView.reloadData()
        updateCardsModeButton() // Update button when filter changes
    }
    
    private func showModuleMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit Module", style: .default) { [weak self] _ in
            self?.editModule()
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
    
    private func editModule() {
        let editVC = EditModuleViewController()
        editVC.module = module
        editVC.terms = terms
        
        editVC.onModuleUpdated = { [weak self] updatedModule in
            self?.module = updatedModule
            self?.titleLabel.text = updatedModule.title
        }
        
        editVC.onTermsUpdated = { [weak self] updatedTerms in
            self?.terms = updatedTerms
            self?.updateFilteredTerms()
            self?.tableView.reloadData()
            self?.updateTermsCountLabel()
            self?.updateCardsModeButton()
        }
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
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
        
        NetworkManager.shared.deleteModule(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    if response.ok {
                        // Show success message
                        let alert = UIAlertController(
                            title: "Success",
                            message: "Module deleted successfully",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self.navigateBack()
                        })
                        self.present(alert, animated: true)
                    } else {
                        self.showError(message: response.message)
                    }
                    
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func toggleFavorite(for term: TermResponse, at indexPath: IndexPath) {
        let newFavoriteStatus = !term.isStarred
        
        print("⭐ Toggling favorite for term: \(term.term) to \(newFavoriteStatus)")
        
        // Update locally first for immediate UI feedback
        if let index = terms.firstIndex(where: { $0.id == term.id }) {
            terms[index].isStarred = newFavoriteStatus
            updateFilteredTerms()
            
            // Update the specific cell
            if let cell = tableView.cellForRow(at: indexPath) as? ModuleTermCell {
                cell.configure(with: terms[index])
            }
            
            // Update cards mode button state
            updateCardsModeButton()
        }
        
        // Call API to update on server
        NetworkManager.shared.updateTermFavorite(termId: term.id, isStarred: newFavoriteStatus) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTerm):
                    print("✅ Favorite updated successfully")
                    
                    // Update local data with server response
                    if let index = self?.terms.firstIndex(where: { $0.id == term.id }) {
                        self?.terms[index] = updatedTerm
                        self?.updateFilteredTerms()
                        self?.updateCardsModeButton()
                    }
                    
                case .failure(let error):
                    print("❌ Failed to update favorite: \(error)")
                    
                    // Revert local change if API call failed
                    if let index = self?.terms.firstIndex(where: { $0.id == term.id }) {
                        self?.terms[index].isStarred = term.isStarred // Revert to original
                        self?.updateFilteredTerms()
                        
                        // Update cell to show original state
                        if let cell = self?.tableView.cellForRow(at: indexPath) as? ModuleTermCell {
                            cell.configure(with: self!.terms[index])
                        }
                        
                        // Update cards mode button state
                        self?.updateCardsModeButton()
                        
                        // Show error to user
                        self?.showError(message: "Failed to update favorite: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func showError(message: String) {
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
        
        // If presented modally (from Library)
        if let navigationController = navigationController, navigationController.presentingViewController != nil {
            print("📱 Dismissing modally")
            navigationController.dismiss(animated: true)
        }
        // If pushed in a navigation stack
        else if let navController = navigationController {
            print("⬅️ Popping from navigation stack")
            navController.popViewController(animated: true)
        }
        // If directly presented
        else if presentingViewController != nil {
            print("📱 Dismissing directly")
            dismiss(animated: true)
        }
        // Fallback
        else {
            print("❌ Couldn't determine how to go back")
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate
extension ModuleDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTerms.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1  // Only one section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleTermCell", for: indexPath) as! ModuleTermCell
        let term = filteredTerms[indexPath.row]
        cell.configure(with: term)
        
        cell.onStarTapped = { [weak self] in
            self?.toggleFavorite(for: term, at: indexPath)
        }
        
        return cell
    }
    
    // Add space between cells
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0  // No section header
    }
    
    // This adds space between rows
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10  // Space between cells
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }
    
    // Make cells unselectable
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false  // Disable cell highlighting/selection
    }
    
    // Remove cell selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do nothing - cells are not selectable
    }
}
