import UIKit

class EditModuleViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel = EditModuleViewModel()
    var module: ModuleResponse! {
        didSet {
            viewModel.module = module
        }
    }
    var terms: [TermResponse] = [] {
        didSet {
            viewModel.terms = terms
        }
    }
    var onModuleUpdated: ((ModuleResponse) -> Void)? {
        didSet {
            viewModel.onModuleUpdated = onModuleUpdated
        }
    }
    var onTermsUpdated: (([TermResponse]) -> Void)? {
        didSet {
            viewModel.onTermsUpdated = onTermsUpdated
        }
    }
    
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
        setupViewModel()
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
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
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
        viewModel.loadData()
        
        // Set up UI with initial data
        titleTextField.text = module.title
        descriptionTextView.text = module.description
        descriptionPlaceholderLabel.isHidden = !(module.description?.isEmpty ?? true)
        privacySwitch.isOn = module.isPrivate
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        if viewModel.hasUnsavedChanges(
            title: titleTextField.text,
            description: descriptionTextView.text,
            isPrivate: privacySwitch.isOn
        ) {
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
        
        let indexPath = viewModel.addNewTerm()
        tableView.reloadData()
        
        // Scroll to the new term
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // Start editing the new term
        if let cell = tableView.cellForRow(at: indexPath) as? EditTermCell {
            cell.termTextField.becomeFirstResponder()
        }
    }
    
    @objc private func textFieldDidChange() {
        viewModel.updateModuleData(
            title: titleTextField.text,
            description: descriptionTextView.text,
            isPrivate: privacySwitch.isOn
        )
    }
    
    @objc private func privacySwitchChanged() {
        viewModel.updateModuleData(
            title: titleTextField.text,
            description: descriptionTextView.text,
            isPrivate: privacySwitch.isOn
        )
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
        viewModel.saveChanges(
            title: titleTextField.text,
            description: descriptionTextView.text,
            isPrivate: privacySwitch.isOn
        ) { [weak self] success in
            if !success {
                // Re-enable buttons if save failed
                self?.saveButton.isEnabled = true
                self?.cancelButton.isEnabled = true
            }
        }
    }
}

// MARK: - EditModuleViewModelDelegate
extension EditModuleViewController: EditModuleViewModelDelegate {
    func showValidationAlert(errors: [String]) {
        let errorMessage = "Please fix the following issues:\n\n" + errors.joined(separator: "\n")
        
        let alert = UIAlertController(
            title: "Cannot Save",
            message: errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccessAndDismiss() {
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
    
    func updateLoadingState(isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            saveButton.isEnabled = false
            cancelButton.isEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            saveButton.isEnabled = true
            cancelButton.isEnabled = true
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func updateSaveButtonState(isEnabled: Bool) {
        // You can update UI based on save button state if needed
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension EditModuleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTerms()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditTermCell", for: indexPath) as! EditTermCell
        
        let term = viewModel.getTerm(at: indexPath)
      //  let isNew = viewModel.isNewTerm(at: indexPath)
        
        if let termResponse = term as? TermResponse {
            cell.configure(with: termResponse, isNew: false)
        } else if let localTerm = term as? Term {
            cell.configure(with: localTerm, isNew: true)
        }
        
        cell.onTermChanged = { [weak self] newTerm, newDefinition in
            self?.viewModel.updateTerm(at: indexPath, term: newTerm, definition: newDefinition)
        }
        
        cell.onDeleteTapped = { [weak self] in
            self?.viewModel.deleteTerm(at: indexPath) // in one closure
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
        viewModel.updateModuleData(
            title: titleTextField.text,
            description: descriptionTextView.text,
            isPrivate: privacySwitch.isOn
        )
    }
}
