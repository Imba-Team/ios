import UIKit

class HomeViewController: BaseViewController {
    
    // MARK: - Properties
    private var viewModel = HomeViewModel()
    private var refreshControl = UIRefreshControl()
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ContinueLearningTableCell.self, forCellReuseIdentifier: "ContinueLearningTableCell")
        tableView.register(AllModulesCell.self, forCellReuseIdentifier: "AllModulesCell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .greenButton
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No modules yet. Create your first module!"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "notFound_cat")
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRefreshControl()
        setupViewModelCallbacks()
        
        // Show empty state initially
        updateEmptyState()
        
        // Then load modules
        loadModules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when coming back from other screens
        if !viewModel.isLoading {
            loadModules()
        }
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .greenButton
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        loadModules()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Home"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateView)
        emptyStateView.addSubviews(emptyStateLabel, emptyStateImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Empty State Image
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Empty State Label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 0),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupViewModelCallbacks() {
        viewModel.delegate = self
    }
    
    // MARK: - Helper Methods
    private func stopAllLoaders() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - API Methods
    private func loadModules() {
        guard !viewModel.isLoading else { return }
        
        if !refreshControl.isRefreshing {
            loadingIndicator.startAnimating()
        }
        
        viewModel.loadModules()
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.allModules.isEmpty
        
        // Hide everything and show empty state when no modules
        if isEmpty {
            tableView.isHidden = true
            emptyStateView.isHidden = false
            emptyStateLabel.text = "Not found"
        } else {
            tableView.isHidden = false
            emptyStateView.isHidden = true
        }
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.stopAllLoaders() // Stop both indicator and refresh control
            
            // If it's a "no modules" type error, show empty state
            if message.contains("No modules") || message.contains("no data") {
                self.updateEmptyState()
            } else {
                let alert = UIAlertController(
                    title: "Error",
                    message: message,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                    self?.loadModules()
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Navigation Methods
    private func navigateToModuleDetail(with module: ModuleResponse) {
        loadingIndicator.startAnimating()
        
        NetworkManager.shared.getModuleById(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    if response.ok, let module = response.data {
                        self.openModuleDetail(module: module)
                    } else {
                        self.showError(message: response.message)
                    }
                    
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func openModuleDetail(module: ModuleResponse) {
        let detailVC = ModuleDetailViewController()
        detailVC.module = module
        
        // Configure based on how your navigation is set up
        if let navigationController = navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else {
            // If you don't have a navigation controller, present modally
            let navController = UINavigationController(rootViewController: detailVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hasContinueLearning = !viewModel.continueLearningSets.isEmpty
        
        if hasContinueLearning && indexPath.section == 0 {
            // Continue Learning section
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContinueLearningTableCell", for: indexPath) as! ContinueLearningTableCell
            cell.configure(with: viewModel.continueLearningSets, viewModel: viewModel)
            cell.continueButtonTapped = { [weak self] index in
                self?.viewModel.handleContinueButtonTap(at: index)
            }
            return cell
            
        } else {
            // All Modules sections
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllModulesCell", for: indexPath) as! AllModulesCell
            
            if let module = viewModel.getModuleForSection(indexPath.section) {
                let termsCount = viewModel.getTermsCount(for: module.id)
                cell.configure(with: module, termsCount: termsCount)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")
        header?.contentView.backgroundColor = .background
        
        // Remove any existing labels
        header?.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.textColor = .text
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        header?.contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: header!.contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: header!.contentView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: header!.contentView.bottomAnchor, constant: -8)
        ])
        
        let title = viewModel.titleForHeader(in: section)
        titleLabel.text = title
        
        if title.isEmpty {
            header?.isHidden = true
        } else {
            header?.isHidden = false
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.handleCellSelection(at: indexPath)
    }
}

// MARK: - HomePageViewModelDelegate
extension HomeViewController: HomePageViewModelDelegate {
    func onDataUpdated() {
        tableView.reloadData()
        updateEmptyState()
        stopAllLoaders() // Stop refresh control when data is updated
    }
    
    func onError(_ message: String) {
        showError(message: message)
    }
    
    func onNavigateToModuleDetail(_ moduleResponse: ModuleResponse) {
        navigateToModuleDetail(with: moduleResponse)
    }
}
