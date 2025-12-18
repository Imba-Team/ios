//
//  CreateSetViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 18.11.25.
//

import UIKit

class CreateSetViewController: BaseViewController {
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
    
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create New Module"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter module title"
        textField.borderStyle = .none
        textField.applyShadow()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(titleTextFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter description (optional)"
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.applyShadow()
        textField.layer.masksToBounds = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(descriptionTextFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var privacySwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false
        switchControl.onTintColor = .pinkButton
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(privacySwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var privacyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Private (only you can see)"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "Terms"
        label.textColor = .text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TermCell.self, forCellReuseIdentifier: "TermCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private lazy var addTermButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add another term", for: .normal)
        button.setTitleColor(.pinkButton, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTermTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save to Library", for: .normal)
        button.backgroundColor = .pinkButton
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private let viewModel = CreateSetViewModel()
    private var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTableView()
        setupTextFields()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Create New Module"
        
        view.addSubview(headerView)
        headerView.addSubview(headerTitleLabel)
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            titleLabel, titleTextField,
            descriptionLabel, descriptionTextField,
            privacyLabel, privacySwitch, privacyDescriptionLabel,
            termsLabel, tableView, addTermButton, saveButton
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupTextFields() {
        let textFields = [titleTextField, descriptionTextField]
        textFields.forEach { textField in
            textField.delegate = self
        }
        setupKeyboardAvoidance(with: scrollView)
    }
    
    private func bindViewModel() {
        viewModel.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = headerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = headerView.bounds
        }
        updateTableViewHeight()
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        let fieldHeight: CGFloat = 60
        let labelHeight: CGFloat = 20
        let headerHeight: CGFloat = 140
        let switchHeight: CGFloat = 31
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 20),
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: padding),
            headerTitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -padding),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            titleTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descriptionLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descriptionTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            privacyLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 20),
            privacyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            privacyLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            privacySwitch.centerYAnchor.constraint(equalTo: privacyLabel.centerYAnchor),
            privacySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            privacySwitch.heightAnchor.constraint(equalToConstant: switchHeight),
            
            privacyDescriptionLabel.topAnchor.constraint(equalTo: privacyLabel.bottomAnchor, constant: 4),
            privacyDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            privacyDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            privacyDescriptionLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            termsLabel.topAnchor.constraint(equalTo: privacyDescriptionLabel.bottomAnchor, constant: 20),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            termsLabel.heightAnchor.constraint(equalToConstant: labelHeight),
            
            tableView.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            tableView.heightAnchor.constraint(equalToConstant: viewModel.tableViewHeight),
            
            addTermButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            addTermButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            addTermButton.heightAnchor.constraint(equalToConstant: 30),
            
            saveButton.topAnchor.constraint(equalTo: addTermButton.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: fieldHeight),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    @objc private func addTermTapped() {
        viewModel.addTerm()
        
        // Scroll to the new term
        let lastIndex = IndexPath(row: viewModel.terms.count - 1, section: 0)
        tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let cell = self.tableView.cellForRow(at: lastIndex) as? TermCell {
                cell.termTextField.becomeFirstResponder()
            }
        }
    }
    
    @objc private func saveTapped() {
        viewModel.createModule()
    }
    
    @objc private func deleteTermTapped(_ sender: UIButton) {
        viewModel.deleteTerm(at: sender.tag)
    }
    
    @objc private func titleTextFieldChanged(_ textField: UITextField) {
        viewModel.title = textField.text ?? ""
    }
    
    @objc private func descriptionTextFieldChanged(_ textField: UITextField) {
        viewModel.description = textField.text ?? ""
    }
    
    @objc private func privacySwitchChanged(_ switchControl: UISwitch) {
        viewModel.isPrivate = switchControl.isOn
    }
    
    // MARK: - UI Updates
    private func updateTableViewHeight() {
        tableView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = viewModel.tableViewHeight
            }
        }
        view.layoutIfNeeded()
    }
    
    private func resetUI() {
        titleTextField.text = ""
        descriptionTextField.text = ""
        privacySwitch.isOn = false
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        view.endEditing(true)
    }
    
    private func showLoadingIndicator(_ show: Bool) {
        if show {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
            
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.center = view.center
            indicator.startAnimating()
            view.addSubview(indicator)
            activityIndicator = indicator
        } else {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
            
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(
            title: "Success!",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CreateSetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.terms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TermCell", for: indexPath) as! TermCell
        let term = viewModel.terms[indexPath.row]
        cell.configure(with: term, tag: indexPath.row)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteTermTapped), for: .touchUpInside)
        
        cell.termTextChanged = { [weak self] text in
            self?.viewModel.update(term: text, at: indexPath.row)
        }
        
        cell.definitionTextChanged = { [weak self] text in
            self?.viewModel.update(definition: text, at: indexPath.row)
        }
        return cell
    }
}

extension CreateSetViewController: CreateSetViewModelDelegate {
    func onTermsUpdated() {
        
        self.updateTableViewHeight()
        self.tableView.reloadData()
    }
    
    func onValidationError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(message: message)
        }
    }
    
    func onModuleCreationStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.showLoadingIndicator(true)
        }
    }
    
    func onModuleCreationSuccess(_ moduleId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.addTermsToModule(moduleId: moduleId)
        }
    }
    
    func onModuleCreationFailure(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showLoadingIndicator(false)
            self?.showAlert(message: message)
        }
    }
    
    func onTermsAdditionComplete(numberOfSuccess successfulTerms: Int, errors: [String]) {
        DispatchQueue.main.async { [weak self] in
            self?.showLoadingIndicator(false)
            
            if errors.isEmpty {
                let message = "✅ Module created with \(successfulTerms) terms!"
                self?.showSuccessAlert(message: message)
                self?.viewModel.resetForm()
                self?.resetUI()
            } else {
                let errorMessage = "Module created but \(errors.count) terms failed:\n" + errors.joined(separator: "\n")
                self?.showAlert(message: errorMessage)
                self?.viewModel.resetForm()
                self?.resetUI()
            }
        }
    }
}

