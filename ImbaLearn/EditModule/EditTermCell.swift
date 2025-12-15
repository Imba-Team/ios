//
//  EditTermCell.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 12.12.25.
//
import UIKit

class EditTermCell: UITableViewCell {
    
    var onTermChanged: ((String, String) -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onValidationChanged: ((Bool) -> Void)? // New callback for validation
    
    // MARK: - UI Elements
    lazy var termTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Term"
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.addTarget(self, action: #selector(termDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var definitionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 6
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termTextField, definitionTextView, errorLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(stackView)
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            
            termTextField.heightAnchor.constraint(equalToConstant: 40),
            definitionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    // MARK: - Configuration
    func configure(with term: Term, isNew: Bool) {
        termTextField.text = term.term
        definitionTextView.text = term.definition
        deleteButton.isHidden = false
        updateValidation()
    }
    
    func configure(with term: TermResponse, isNew: Bool) {
        termTextField.text = term.term
        definitionTextView.text = term.definition
        deleteButton.isHidden = false
        updateValidation()
    }
    
    private func updateValidation() {
        let termText = termTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let definitionText = definitionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if termText.isEmpty && definitionText.isEmpty {
            // Both empty - no error (will be filtered out)
            errorLabel.isHidden = true
            updateBorderColors(isValid: true)
            onValidationChanged?(true)
        } else if termText.isEmpty {
            errorLabel.text = "Term cannot be empty"
            errorLabel.isHidden = false
            updateBorderColors(isValid: false)
            onValidationChanged?(false)
        } else if definitionText.isEmpty {
            errorLabel.text = "Definition cannot be empty"
            errorLabel.isHidden = false
            updateBorderColors(isValid: false)
            onValidationChanged?(false)
        } else {
            errorLabel.isHidden = true
            updateBorderColors(isValid: true)
            onValidationChanged?(true)
        }
    }
    
    private func updateBorderColors(isValid: Bool) {
        let borderColor = isValid ? UIColor.lightGray.cgColor : UIColor.systemRed.cgColor
        termTextField.layer.borderColor = borderColor
        definitionTextView.layer.borderColor = borderColor
    }
    
    // MARK: - Actions
    @objc private func termDidChange() {
        let termText = termTextField.text ?? ""
        let definitionText = definitionTextView.text!
        
        onTermChanged?(termText, definitionText)
        updateValidation()
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}

// MARK: - UITextViewDelegate for EditTermCell
extension EditTermCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let termText = termTextField.text ?? ""
        let definitionText = textView.text!
        
        onTermChanged?(termText, definitionText)
        updateValidation()
        
        // Adjust text view height
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = max(60, size.height)
            }
        }
        layoutIfNeeded()
    }
}
