//
//  EditModuleViewController.swift
//  ImbaLearn
//

import UIKit

class EditModuleViewController: BaseViewController {
    
    // MARK: - Properties
    var module: ModuleResponse!
    var originalModule: ModuleResponse!
    var terms: [TermResponse] = []
    var onModuleUpdated: ((ModuleResponse) -> Void)?
    var onTermsUpdated: (([TermResponse]) -> Void)?
    
    private var editedTerms: [TermResponse] = []
    private var deletedTermIds: Set<String> = []
    private var newTerms: [Term] = []
    private var hasChanges = false
    
    // MARK: - UI Elements
    // Header
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Module"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.pinkButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Module Info Section
    private lazy var moduleInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Module Info"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Module Title"
        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var descriptionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Description (optional)"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var privacyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "Privacy"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var privacySwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .pinkButton
        toggle.addTarget(self, action: #selector(privacySwitchChanged), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private lazy var privateLabel: UILabel = {
        let label = UILabel()
        label.text = "Private"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Terms Section
    private lazy var termsLabel: UILabel = {
        let label = UILabel()
        label.text = "Terms"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addTermButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add New Term", for: .normal)
        button.setTitleColor(.pinkButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(addTermTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(EditTermCell.self, forCellReuseIdentifier: "EditTermCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
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
        loadData()
        setupKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .background
        
        // Header
        view.addSubview(cancelButton)
        view.addSubview(titleLabel)
        view.addSubview(saveButton)
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Module Info
        contentView.addSubview(moduleInfoLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        contentView.addSubview(privacyStack)
        
        privacyStack.addArrangedSubview(privacyLabel)
        privacyStack.addArrangedSubview(privacySwitch)
        privacyStack.addArrangedSubview(privateLabel)
        
        // Terms
        contentView.addSubview(termsLabel)
        contentView.addSubview(addTermButton)
        contentView.addSubview(tableView)
        
        // Loading Indicator
        view.addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Header
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            cancelButton.widthAnchor.constraint(equalToConstant: 70),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            saveButton.widthAnchor.constraint(equalToConstant: 70),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Module Info
            moduleInfoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            moduleInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            moduleInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            titleTextField.topAnchor.constraint(equalTo: moduleInfoLabel.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 8),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 8),
            
            privacyStack.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            privacyStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            privacyStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -padding),
            
            // Terms
            termsLabel.topAnchor.constraint(equalTo: privacyStack.bottomAnchor, constant: 30),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            addTermButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 12),
            addTermButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            addTermButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            addTermButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: addTermButton.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 350),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        // Create deep copies
        originalModule = module
        editedTerms = terms.map { $0 } // Create a copy
        
        // Set up UI with initial data
        titleTextField.text = module.title
        descriptionTextView.text = module.description
        descriptionPlaceholderLabel.isHidden = !(module.description?.isEmpty ?? true)
        privacySwitch.isOn = module.isPrivate
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        if hasChanges {
            showDiscardChangesAlert()
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func saveButtonTapped() {
        view.endEditing(true)
        saveChanges()
    }
    
    @objc private func addTermTapped() {
        view.endEditing(true)
        
        let newTerm = Term(term: "", definition: "", isStarred: false)
        newTerms.append(newTerm)
        
        tableView.reloadData()
        
        // Scroll to the new term
        let indexPath = IndexPath(row: editedTerms.count + newTerms.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // Start editing the new term
        if let cell = tableView.cellForRow(at: indexPath) as? EditTermCell {
            cell.termTextField.becomeFirstResponder()
        }
        
        updateHasChanges()
    }
    
    @objc private func textFieldDidChange() {
        updateHasChanges()
    }
    
    @objc private func privacySwitchChanged() {
        updateHasChanges()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeTextField = findFirstResponder() else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll to active text field
        var visibleRect = activeTextField.convert(activeTextField.bounds, to: scrollView)
        visibleRect = visibleRect.insetBy(dx: 0, dy: -20) // Add some padding
        scrollView.scrollRectToVisible(visibleRect, animated: true)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    private func findFirstResponder() -> UIView? {
        // Check title text field
        if titleTextField.isFirstResponder {
            return titleTextField
        }
        
        // Check description text view
        if descriptionTextView.isFirstResponder {
            return descriptionTextView
        }
        
        // Check term cells
        for cell in tableView.visibleCells {
            if let termCell = cell as? EditTermCell {
                if termCell.termTextField.isFirstResponder {
                    return termCell.termTextField
                }
                if termCell.definitionTextView.isFirstResponder {
                    return termCell.definitionTextView
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Change Management
    private func updateHasChanges() {
        // Check module changes
        let moduleChanged = titleTextField.text != originalModule.title ||
                           descriptionTextView.text != originalModule.description ||
                           privacySwitch.isOn != originalModule.isPrivate
        
        // Check if there are new valid terms (non-empty)
        let hasNewValidTerms = !newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }.isEmpty
        
        // Check if any terms were deleted
        let hasDeletedTerms = !deletedTermIds.isEmpty
        
        // Check if any existing terms were modified (excluding empty ones)
        var termsModified = false
        for (index, editedTerm) in editedTerms.enumerated() {
            if index < terms.count {
                let originalTerm = terms[index]
                
                // Skip if both term and definition are empty (should be deleted)
                let termText = editedTerm.term.trimmingCharacters(in: .whitespacesAndNewlines)
                let definitionText = editedTerm.definition.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if termText.isEmpty && definitionText.isEmpty {
                    continue
                }
                
                if editedTerm.term != originalTerm.term ||
                   editedTerm.definition != originalTerm.definition ||
                   editedTerm.isStarred != originalTerm.isStarred {
                    termsModified = true
                    break
                }
            }
        }
        
        hasChanges = moduleChanged || hasNewValidTerms || hasDeletedTerms || termsModified
    }
    
    private func showDiscardChangesAlert() {
            let alert = UIAlertController(
                title: "Discard Changes?",
                message: "You have unsaved changes. Are you sure you want to discard them?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            
            present(alert, animated: true)
        }
        
    
    // MARK: - Save Logic
    private func saveChanges() {
        guard hasChanges else {
            dismiss(animated: true)
            return
        }
        
        // Validate all inputs first
        guard validateAllInputs() else {
            return // Don't proceed with saving, just show alert
        }
        
        // If validation passes, proceed with saving
        loadingIndicator.startAnimating()
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
        
        // Save changes in sequence
        saveModuleChanges { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.saveTermChanges { [weak self] success in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        
                        if success {
                            self.updateLocalDataAndDismiss()
                        } else {
                            // Re-enable buttons if save failed
                            self.saveButton.isEnabled = true
                            self.cancelButton.isEnabled = true
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    self.cancelButton.isEnabled = true
                }
            }
        }
    }

    // MARK: - Validation
    private func validateAllInputs() -> Bool {
        var validationErrors: [String] = []
        
        // Validate module title
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if title.isEmpty {
            validationErrors.append("• Module title is required")
        }
        
        // Validate existing terms
        for (index, term) in editedTerms.enumerated() {
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if termText.isEmpty && definitionText.isEmpty {
                // Both empty - this term should be deleted, skip it
                continue
            } else if termText.isEmpty {
                validationErrors.append("• Term at position \(index + 1) is missing a term")
            } else if definitionText.isEmpty {
                validationErrors.append("• Definition for '\(termText)' is missing")
            }
        }
        
        // Validate new terms
        for (index, term) in newTerms.enumerated() {
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip completely empty terms
            if termText.isEmpty && definitionText.isEmpty {
                continue
            }
            
            // Check partial empty
            if termText.isEmpty {
                validationErrors.append("• New term at position \(index + 1) is missing a term")
            } else if definitionText.isEmpty {
                validationErrors.append("• Definition for new term '\(termText)' is missing")
            }
        }
        
        // Check if we have any valid terms after validation
        let validEditedTerms = editedTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        let validNewTerms = newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        let hasValidTerms = !validEditedTerms.isEmpty || !validNewTerms.isEmpty
        
        // Only require terms if module originally had terms or if user tried to add terms
        let userTriedToAddTerms = !newTerms.filter({
            !$0.term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !$0.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }).isEmpty
        
        if !hasValidTerms && (!terms.isEmpty || userTriedToAddTerms) {
            validationErrors.append("• Module must have at least one complete term")
        }
        
        // If there are validation errors, show them and return false
        if !validationErrors.isEmpty {
            showValidationAlert(errors: validationErrors)
            return false
        }
        
        return true
    }

    private func showValidationAlert(errors: [String]) {
        let errorMessage = "Please fix the following issues:\n\n" + errors.joined(separator: "\n")
        
        let alert = UIAlertController(
            title: "Cannot Save",
            message: errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Save Success
    private func updateLocalDataAndDismiss() {
        // Get validated data
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Filter out empty terms
        let validEditedTerms = editedTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        let validNewTerms = newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        // Update the module with new data
        var updatedModule = module
        updatedModule?.title = title
        updatedModule?.description = description.isEmpty ? nil : description
        updatedModule?.isPrivate = privacySwitch.isOn
        
        // Combine existing terms with new terms (only valid ones)
        let updatedTerms = validEditedTerms + validNewTerms.map { term in
            // Convert local Term to TermResponse
            return TermResponse(
                id: UUID().uuidString, // Temporary ID for new terms
                term: term.term,
                status: "not_started",
                definition: term.definition,
                isStarred: term.isStarred,
                createdAt: nil,
                updatedAt: nil,
                moduleId: module.id
            )
        }
        
        // Call callbacks
        onModuleUpdated?(updatedModule!)
        onTermsUpdated?(updatedTerms)
        
        // Show success and dismiss
        showSuccessAndDismiss()
    }

    private func saveModuleChanges(completion: @escaping (Bool) -> Void) {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isPrivate = privacySwitch.isOn
        
        // Check if module actually changed
        if title == originalModule.title &&
           description == originalModule.description &&
           isPrivate == originalModule.isPrivate {
            completion(true)
            return
        }
        
        let request = UpdateModuleRequest(
            title: title,
            description: description.isEmpty ? nil : description,
            isPrivate: isPrivate
        )
        
        NetworkManager.shared.updateModule(moduleId: module.id, request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.ok {
                        print("✅ Module updated successfully")
                        completion(true)
                    } else {
                        self.showError(message: response.message)
                        completion(false)
                    }
                case .failure(let error):
                    self.showError(message: error.localizedDescription)
                    completion(false)
                }
            }
        }
    }

    private func saveTermChanges(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var hasError = false
        
        // Filter valid edited terms
        let validEditedTerms = editedTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        // Filter valid new terms
        let validNewTerms = newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        // Update existing terms
        for editedTerm in validEditedTerms {
            // Find the original term to check if it was modified
            if let originalTerm = terms.first(where: { $0.id == editedTerm.id }) {
                // Check if term was modified
                if editedTerm.term != originalTerm.term ||
                   editedTerm.definition != originalTerm.definition ||
                   editedTerm.isStarred != originalTerm.isStarred {
                    
                    group.enter()
                    let request = UpdateTermRequest(
                        term: editedTerm.term,
                        definition: editedTerm.definition,
                        isStarred: editedTerm.isStarred
                    )
                    
                    NetworkManager.shared.updateTerm(termId: editedTerm.id, request: request) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                if response.ok {
                                    print("✅ Term updated: \(editedTerm.term)")
                                } else {
                                    print("❌ Failed to update term: \(response.message)")
                                    hasError = true
                                }
                            case .failure(let error):
                                print("❌ Failed to update term: \(error)")
                                hasError = true
                            }
                            group.leave()
                        }
                    }
                }
            }
        }
        
        // Delete removed terms
        for termId in deletedTermIds {
            group.enter()
            NetworkManager.shared.deleteTerm(termId: termId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.ok {
                            print("✅ Term deleted: \(termId)")
                        } else {
                            print("❌ Failed to delete term: \(response.message)")
                            hasError = true
                        }
                    case .failure(let error):
                        print("❌ Failed to delete term: \(error)")
                        hasError = true
                    }
                    group.leave()
                }
            }
        }
        
        // Create new terms (only valid ones)
        for newTerm in validNewTerms {
            let termText = newTerm.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = newTerm.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            group.enter()
            let request = CreateTermRequest(
                moduleId: module.id,
                term: termText,
                definition: definitionText,
                isStarred: newTerm.isStarred
            )
            
            NetworkManager.shared.createTerm(request: request) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.ok {
                            print("✅ New term created: \(termText)")
                        } else {
                            print("❌ Failed to create term: \(response.message)")
                            hasError = true
                        }
                    case .failure(let error):
                        print("❌ Failed to create term: \(error)")
                        hasError = true
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(!hasError)
        }
    }
    
    private func showSuccessAndDismiss() {
        let alert = UIAlertController(
            title: "Success",
            message: "Module updated successfully",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
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
extension EditModuleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editedTerms.count + newTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTermCell", for: indexPath) as! EditTermCell
        
        if indexPath.row < editedTerms.count {
            // Existing term
            let term = editedTerms[indexPath.row]
            cell.configure(with: term, isNew: false)
        } else {
            // New term
            let newTermIndex = indexPath.row - editedTerms.count
            let term = newTerms[newTermIndex]
            cell.configure(with: term, isNew: true)
        }
        
        cell.onTermChanged = { [weak self] newTerm, newDefinition in
            guard let self = self else { return }
            
            if indexPath.row < self.editedTerms.count {
                // Update existing term
                self.editedTerms[indexPath.row].term = newTerm
                self.editedTerms[indexPath.row].definition = newDefinition
            } else {
                // Update new term
                let newTermIndex = indexPath.row - self.editedTerms.count
                self.newTerms[newTermIndex].term = newTerm
                self.newTerms[newTermIndex].definition = newDefinition
            }
            
            self.updateHasChanges()
        }
        
        cell.onDeleteTapped = { [weak self] in
            guard let self = self else { return }
            
            if indexPath.row < self.editedTerms.count {
                // Mark existing term for deletion
                let term = self.editedTerms[indexPath.row]
                self.deletedTermIds.insert(term.id)
                self.editedTerms.remove(at: indexPath.row)
            } else {
                // Remove new term
                let newTermIndex = indexPath.row - self.editedTerms.count
                self.newTerms.remove(at: newTermIndex)
            }
            
            self.tableView.reloadData()
            self.updateHasChanges()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITextViewDelegate
extension EditModuleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholderLabel.isHidden = !textView.text.isEmpty
        updateHasChanges()
    }
}


