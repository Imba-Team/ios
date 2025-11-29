////
////  AllModulesCell.swift
////  ImbaLearn
////
////  Created by Leyla Aliyeva on 19.11.25.
////
//
//import UIKit
//
//class AllModulesCell: UICollectionViewCell {
//    
//    private lazy var iconContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = .color2
//        view.layer.cornerRadius = 12
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private lazy var iconImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = .color1
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private lazy var nameLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .color1
//        label.font = UIFont.boldSystemFont(ofSize: 18)
//        label.numberOfLines = 2
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private lazy var cardsCountLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .systemGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupCell()
//        setupConstraints()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupCell() {
//        backgroundColor = .white
//        layer.cornerRadius = 12
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowRadius = 4
//        layer.shadowOpacity = 0.1
//        
//        contentView.addSubviews(iconImageView, nameLabel)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            // Icon
//            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
//            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
//            iconImageView.widthAnchor.constraint(equalToConstant: 40),
//            iconImageView.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Name Label
//            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
//            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
//            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
//            
//            // Progress View
//        ])
//    }
//    
//    
//}


//  AllModulesCell.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 19.11.25.
//

import UIKit

class AllModulesCell: UICollectionViewCell {
    
    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .color3
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .pinkButton
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardsCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
        
        contentView.addSubviews(iconContainer, nameLabel, cardsCountLabel)
        iconContainer.addSubview(iconImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Icon Container (left side)
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // Icon Image View (centered in container)
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Name Label (right side of icon)
            nameLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            
            // Cards Count Label (below name)
            cardsCountLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            cardsCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardsCountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            cardsCountLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with studySet: StudySet) {
        iconImageView.image = UIImage(systemName: studySet.iconName)
        nameLabel.text = studySet.name
        cardsCountLabel.text = "\(studySet.cardCount) cards"
    }
}
