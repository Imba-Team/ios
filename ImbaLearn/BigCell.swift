//
//  BigCell.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 19.11.25.
//
import UIKit

class StudySetCell: UICollectionViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .color1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .color1
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .color2
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .color1
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .color2
        button.setTitleColor(.color1, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        contentView.addSubviews(iconImageView, nameLabel, progressView, percentageLabel, continueButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Percentage Label
            percentageLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            percentageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Continue Button
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            continueButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 120),
            continueButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with studySet: StudySet) {
        // Use SF Symbols for icons
        iconImageView.image = UIImage(systemName: studySet.iconName)
        nameLabel.text = studySet.name
        progressView.progress = studySet.progress
        percentageLabel.text = "\(Int(studySet.progress * 100))%"
        
        // Update button title based on progress
        if studySet.progress == 0 {
            continueButton.setTitle("Start", for: .normal)
        } else if studySet.progress == 1.0 {
            continueButton.setTitle("Completed", for: .normal)
            continueButton.backgroundColor = .systemGray4
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }
    }
}
