//
//  LibraryViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 17.11.25.
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
        
        // Add search icon
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
        
        // Create up/down arrows icon
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
        
        // You can replace this with your actual cat image
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
    
    // MARK: - Properties
    private var studySets: [StudySett] = [
        StudySett(title: "Spanish Vocabulary", cardCount: 45, createdAt: Date().addingTimeInterval(-86400)), // 1 day ago
        StudySett(title: "Math Formulas", cardCount: 32, createdAt: Date().addingTimeInterval(-172800)), // 2 days ago
        StudySett(title: "History Dates", cardCount: 28, createdAt: Date().addingTimeInterval(-259200)), // 3 days ago
        StudySett(title: "Science Terms", cardCount: 56, createdAt: Date().addingTimeInterval(-345600)), // 4 days ago
        StudySett(title: "French Verbs", cardCount: 23, createdAt: Date().addingTimeInterval(-432000)) // 5 days ago
    ]
    
    private var filteredStudySets: [StudySett] = []
    private var currentSortOption: SortOption = .date
    
    // Define your three colors here
    private let cellColors: [UIColor] = [
        .color3.withAlphaComponent(0.6),    // Replace with your first color
        .color.withAlphaComponent(0.6),    // Replace with your second color
        .gray.withAlphaComponent(0.2)     // Replace with your third color
    ]
    // MARK: - Sort Options
    private enum SortOption: String, CaseIterable {
        case date = "Date"
        case title = "Title"
        case cardCount = "Card Count"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
        updateFilteredData()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(titleLabel)
        view.addSubview(searchSortStack)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
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
            
            // Sort Button width - smaller for icon
            sortButton.widthAnchor.constraint(equalToConstant: 50),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: searchSortStack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
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
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Actions
    @objc private func searchTextChanged() {
        updateFilteredData()
    }
    
    @objc private func sortButtonTapped() {
        showSortOptions()
    }
    
    // MARK: - Helper Methods
    private func updateFilteredData() {
        let searchText = searchTextField.text?.lowercased() ?? ""
        
        if searchText.isEmpty {
            filteredStudySets = studySets
        } else {
            filteredStudySets = studySets.filter { $0.title.lowercased().contains(searchText) }
        }
        
        applySort()
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func applySort() {
        switch currentSortOption {
        case .date:
            filteredStudySets.sort { $0.createdAt > $1.createdAt } // Newest first
        case .title:
            filteredStudySets.sort { $0.title < $1.title } // Alphabetical
        case .cardCount:
            filteredStudySets.sort { $0.cardCount > $1.cardCount } // Most cards first
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredStudySets.isEmpty
        tableView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
    }
    
    private func showSortOptions() {
        let alert = UIAlertController(title: "Sort Modules", message: nil, preferredStyle: .actionSheet)
        
        for option in SortOption.allCases {
            let action = UIAlertAction(title: option.rawValue, style: .default) { [weak self] _ in
                self?.currentSortOption = option
                self?.updateFilteredData()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // Helper method to get color for specific index
    private func getColorForIndex(_ index: Int) -> UIColor {
        return cellColors[index % cellColors.count]
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredStudySets.count // Each cell is in its own section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // One row per section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleCell", for: indexPath) as! ModuleCell
        let studySet = filteredStudySets[indexPath.section] // Use section instead of row
        
        // Get the color for this cell based on its position
        let backgroundColor = getColorForIndex(indexPath.section)
        cell.configure(with: studySet, backgroundColor: backgroundColor)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8 // Space between cells
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let studySet = filteredStudySets[indexPath.section] // Use section instead of row
        // TODO: Navigate to set detail view
        print("Selected: \(studySet.title)")
    }
}

// MARK: - ModuleCell


// MARK: - StudySet Model
struct StudySett {
    let title: String
    let cardCount: Int
    let createdAt: Date
}
