//
//  TermCell.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 29.11.25.
//
import UIKit

class TermCell: UITableViewCell {
    
     lazy var termTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Term"
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var definitionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Definition"
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("−", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .pinkButton
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var termTextChanged: ((String) -> Void)?
    var definitionTextChanged: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(termTextField)
        contentView.addSubview(definitionTextField)
        contentView.addSubview(deleteButton)
        
        // Add text field targets
        termTextField.addTarget(self, action: #selector(termTextDidChange), for: .editingChanged)
        definitionTextField.addTarget(self, action: #selector(definitionTextDidChange), for: .editingChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // This helps with constraint warnings
        contentView.layoutIfNeeded()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Delete Button - position it first
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Term Text Field
            termTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            termTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            termTextField.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            termTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Definition Text Field
            definitionTextField.topAnchor.constraint(equalTo: termTextField.bottomAnchor, constant: 10),
            definitionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            definitionTextField.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            definitionTextField.heightAnchor.constraint(equalToConstant: 40),
            definitionTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with term: Term, tag: Int) {
        termTextField.text = term.term
        definitionTextField.text = term.definition
        termTextField.tag = tag
        definitionTextField.tag = tag
    }
    
    @objc private func termTextDidChange() {
        let trimmedText = termTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        termTextChanged?(trimmedText)
    }
    
    @objc private func definitionTextDidChange() {
        let trimmedText = definitionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        definitionTextChanged?(trimmedText)
    }
}
