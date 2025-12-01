////
////  TermCellSmall.swift
////  ImbaLearn
////
////  Created by Leyla Aliyeva on 01.12.25.
////
//
//import UIKit
//
//class TermCellSmall: UITableViewCell {
//    
//    // MARK: - UI Elements
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .cellBackground
//        view.layer.cornerRadius = 12
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.systemGray5.cgColor
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let termLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.textColor = .text
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let definitionLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .systemGray
//        label.numberOfLines = 0
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let favoriteButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "star"), for: .normal)
//        button.tintColor = .systemGray
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    var favoriteButtonTapped: (() -> Void)?
//    
//    // MARK: - Initialization
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//        setupConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Setup
//    private func setupCell() {
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//        selectionStyle = .none
//        
//        contentView.addSubview(containerView)
//        containerView.addSubview(termLabel)
//        containerView.addSubview(definitionLabel)
//        containerView.addSubview(favoriteButton)
//        
//        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Container View
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
//            
//            // Favorite Button
//            favoriteButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
//            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
//            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
//            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
//            
//            // Term Label
//            termLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
//            termLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            termLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
//            
//            // Definition Label
//            definitionLabel.topAnchor.constraint(equalTo: termLabel.bottomAnchor, constant: 8),
//            definitionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            definitionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            definitionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
//        ])
//    }
//    
//    @objc private func favoriteButtonPressed() {
//        favoriteButtonTapped?()
//    }
//    
//    // MARK: - Configuration
//    func configure(with term: Term) {
//        termLabel.text = term.term
//        definitionLabel.text = term.definition
//        
//        if term.isFavorite {
//            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
//            favoriteButton.tintColor = .systemYellow
//        } else {
//            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
//            favoriteButton.tintColor = .systemGray
//        }
//    }
//}
