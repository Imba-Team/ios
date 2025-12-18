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
        tableView.showsVerticalScrollIndicator = false
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
    private let viewModel = LibraryViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
        setupViewModelCallbacks()
        loadModules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshData()
    }
    
    // MARK: - Setup Methods
    
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
    }
    
    private func setupViewModelCallbacks() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func searchTextChanged() {
        viewModel.searchModules(with: searchTextField.text ?? "")
    }
    
    @objc private func sortButtonTapped() {
        showSortOptions()
    }
    
    @objc private func refreshData() {
        viewModel.refreshData()
    }
    
    // MARK: - Helper Methods
    
    private func loadModules() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true
        
        viewModel.loadModules()
    }
    
    private func updateEmptyState(shouldShow: Bool, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.tableView.isHidden = shouldShow
            self.emptyStateView.isHidden = !shouldShow
            self.emptyStateLabel.text = message
            
            // Always stop loading indicators when updating empty state
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func showSortOptions() {
        let alert = UIAlertController(title: "Sort Modules", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Date", style: .default) { [weak self] _ in
            self?.viewModel.sortModules(by: .date)
        })
        
        alert.addAction(UIAlertAction(title: "Title A-Z", style: .default) { [weak self] _ in
            self?.viewModel.sortModules(by: .titleAscending)
        })
        
        alert.addAction(UIAlertAction(title: "Title Z-A", style: .default) { [weak self] _ in
            self?.viewModel.sortModules(by: .titleDescending)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        loadingIndicator.stopAnimating()
        refreshControl.endRefreshing()
        
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToModuleDetail(with module: ModuleResponse) {
        print("🔍 Tapped module: \(module.title)")
        
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

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleCell", for: indexPath) as! ModuleCell
        
        if let module = viewModel.getModule(at: indexPath) {
            let termsCount = viewModel.getTermsCount(for: module.id)
            cell.configure(with: module, backgroundColor: .white, termsCount: termsCount)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let module = viewModel.getModule(at: indexPath) {
            // Call the delegate directly
            viewModel.delegate?.onNavigateToModuleDetail(module)
        }
    }
}

// MARK: - LibraryViewModelDelegate
extension LibraryViewController: LibraryViewModelDelegate {
    func onDataUpdated() {
        tableView.reloadData()
    }
    
    func onError(_ message: String) {
        showError(message: message)
    }
    
    func onNavigateToModuleDetail(_ moduleResponse: ModuleResponse) {
        navigateToModuleDetail(with: moduleResponse)
    }
    
    func onUpdateEmptyState(_ isEmpty: Bool, message: String) {
        updateEmptyState(shouldShow: isEmpty, message: message)
    }
}
