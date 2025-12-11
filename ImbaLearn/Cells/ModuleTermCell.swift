//
//  ModuleTermCell.swift
//  ImbaLearn
//

import UIKit

class ModuleTermCell: UITableViewCell {
    
    var onStarTapped: (() -> Void)?
    
    // MARK: - Container View (adds spacing)
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    // MARK: - UI Elements
    private lazy var termLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var starButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(starButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [termLabel, definitionLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear   // IMPORTANT for spacing
        
        contentView.addSubview(containerView)
        containerView.addSubview(labelsStack)
        containerView.addSubview(starButton)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            // Container with spacing above & below
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            // Labels Stack
            labelsStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            labelsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            labelsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            labelsStack.trailingAnchor.constraint(equalTo: starButton.leadingAnchor, constant: -8),
            
            // Star Button
            starButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            starButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            starButton.widthAnchor.constraint(equalToConstant: 30),
            starButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    // MARK: - Configure
    func configure(with term: TermResponse) {
        termLabel.text = term.term
        definitionLabel.text = term.definition
        
        let starImage = term.isStarred
            ? UIImage(systemName: "star.fill")
            : UIImage(systemName: "star")
        
        starButton.setImage(starImage, for: .normal)
        starButton.tintColor = term.isStarred ? .systemYellow : .gray
    }
    
    
    // MARK: - Actions
    @objc private func starButtonTapped() {
        onStarTapped?()
    }
}
