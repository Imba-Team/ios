//
//  LibraryViewController.swift
//  ImbaLearn
//

import UIKit

class LibraryViewController: BaseViewController {
    
    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Modules"
        label.textColor = .black
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Find module..."
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        textField.layer.shadowOpacity = 0.1
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray
        searchIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        rightView.addSubview(searchIcon)
        searchIcon.center = rightView.center
        
        textField.rightView = rightView
        textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        return textField
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let sortIcon = UIImage(systemName: "arrow.up.arrow.down", withConfiguration: configuration)
        
        button.setImage(sortIcon, for: .normal)
        button.tintColor = .pinkButton
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    private lazy var searchSortStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchTextField, sortButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(ModuleCell.self, forCellReuseIdentifier: "ModuleCell")
        return tableView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "notFound_cat")
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Not found"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .pinkButton
        return refreshControl
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .pinkButton
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    private var modules: [ModuleResponse] = []
    private var filteredModules: [ModuleResponse] = []
    private var isLoading = false
    private var termsCountCache: [String: Int] = [:] // Cache for terms count
    
    private let cellColors: [UIColor] = [
        .color3.withAlphaComponent(0.6),
        .color.withAlphaComponent(0.6),
        .gray.withAlphaComponent(0.2)
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
        loadModules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadModules()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(titleLabel)
        view.addSubview(searchSortStack)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Search & Sort Stack
            searchSortStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchSortStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            searchSortStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            searchSortStack.heightAnchor.constraint(equalToConstant: 50),
            
            sortButton.widthAnchor.constraint(equalToConstant: 50),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: searchSortStack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 200),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 0),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - API Methods
    private func loadModules() {
        guard !isLoading else { return }
        
        isLoading = true
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true
        
        // First, get current user ID if we don't have it
        if UserDefaults.standard.string(forKey: "currentUserId") == nil {
            fetchCurrentUserId { [weak self] userId in
                if let userId = userId {
                    UserDefaults.standard.set(userId, forKey: "currentUserId")
                    self?.loadModulesWithUserId(userId)
                } else {
                    self?.handleModulesLoadingError("Could not get user ID")
                }
            }
        } else {
            let userId = UserDefaults.standard.string(forKey: "currentUserId")!
            loadModulesWithUserId(userId)
        }
    }

    private func loadModulesWithUserId(_ userId: String) {
        NetworkManager.shared.getUserModules { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                switch result {
                case .success(let response):
                    if response.ok {
                        // Filter modules to show only the ones created by current user
                        let allModules = response.data ?? []
                        self.modules = allModules.filter { module in
                            module.userId == userId
                        }
                        
                        print("✅ Showing \(self.modules.count) user modules out of \(allModules.count) total")
                        
                        // Load terms count for all modules
                        self.loadTermsCountForAllModules()
                        
                        self.updateFilteredData()
                        self.tableView.reloadData()
                        self.updateEmptyState()
                        self.tableView.isHidden = false
                    } else {
                        self.showError(message: response.message)
                        self.updateEmptyState()
                    }
                    
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                    self.updateEmptyState()
                }
            }
        }
    }

    private func fetchCurrentUserId(completion: @escaping (String?) -> Void) {
        NetworkManager.shared.getUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.ok {
                        let userId = response.data.id
                        completion(userId)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    completion(nil)
                }
            }
        }
    }

    private func handleModulesLoadingError(_ message: String) {
        isLoading = false
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
        showError(message: message)
        updateEmptyState()
    }
    
    private func loadTermsCountForAllModules() {
        // Clear previous cache
        termsCountCache.removeAll()
        
        // Load terms count for each module
        for module in modules {
            loadTermsCount(for: module) { [weak self] count in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    // Cache the result
                    self.termsCountCache[module.id] = count ?? 0
                    
                    // Find the index of this module in filteredModules
                    if let index = self.filteredModules.firstIndex(where: { $0.id == module.id }) {
                        let indexPath = IndexPath(row: 0, section: index)
                        
                        // Update the cell if it's visible
                        if let cell = self.tableView.cellForRow(at: indexPath) as? ModuleCell {
                            let backgroundColor = self.getColorForIndex(index)
                            cell.configure(with: module, backgroundColor: backgroundColor, termsCount: count)
                        }
                    }
                }
            }
        }
    }
    
    private func loadTermsCount(for module: ModuleResponse, completion: @escaping (Int?) -> Void) {
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { result in
            switch result {
            case .success(let response):
                if response.ok {
                    let termsCount = response.data?.data.count ?? 0
                    completion(termsCount)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    // MARK: - Helper Methods
    @objc private func searchTextChanged() {
        updateFilteredData()
    }
    
    @objc private func sortButtonTapped() {
        showSortOptions()
    }
    
    @objc private func refreshData() {
        loadModules()
    }
    
    private func updateFilteredData() {
        let searchText = searchTextField.text?.lowercased() ?? ""
        
        if searchText.isEmpty {
            filteredModules = modules
        } else {
            filteredModules = modules.filter { module in
                module.title.lowercased().contains(searchText) ||
                (module.description?.lowercased().contains(searchText) ?? false)
            }
        }
        
        tableView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredModules.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if isEmpty {
            if modules.isEmpty {
                emptyStateLabel.text = "No modules yet"
            } else {
                emptyStateLabel.text = "No modules found"
            }
        }
    }
    
    private func showSortOptions() {
        let alert = UIAlertController(title: "Sort Modules", message: nil, preferredStyle: .actionSheet)
        
        let actions = [
            ("Date", {
                self.filteredModules.sort { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
                self.tableView.reloadData()
            }),
            ("Title A-Z", {
                self.filteredModules.sort { $0.title.lowercased() < $1.title.lowercased() }
                self.tableView.reloadData()
            }),
            ("Title Z-A", {
                self.filteredModules.sort { $0.title.lowercased() > $1.title.lowercased() }
                self.tableView.reloadData()
            })
        ]
        
        for (title, action) in actions {
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in action() })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func getColorForIndex(_ index: Int) -> UIColor {
        return cellColors[index % cellColors.count]
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
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredModules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleCell", for: indexPath) as! ModuleCell
        let module = filteredModules[indexPath.section]
        
        let backgroundColor = getColorForIndex(indexPath.section)
        
        // Get cached terms count or use progress data as fallback
        let termsCount = termsCountCache[module.id] ?? module.progress?.total ?? 0
        
        cell.configure(with: module, backgroundColor: backgroundColor, termsCount: termsCount)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let module = filteredModules[indexPath.section]
        
        print("🔍 Tapped module: \(module.title)")
        
        // Navigate to module detail
        let detailVC = ModuleDetailViewController()
        detailVC.module = module
        
        if let navController = navigationController {
            navController.pushViewController(detailVC, animated: true)
        } else if let parentNav = parent as? UINavigationController {
            parentNav.pushViewController(detailVC, animated: true)
        } else {
            detailVC.modalPresentationStyle = .fullScreen
            present(detailVC, animated: true)
        }
    }
}
