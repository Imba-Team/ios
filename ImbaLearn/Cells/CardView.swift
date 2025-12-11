//
//  CardView.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 30.11.25.
//

import UIKit

class CardView: UIView {
    
    // MARK: - UI Elements
    private lazy var termLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .text
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isShowingTerm = true
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        
        addSubview(termLabel)
        addSubview(definitionLabel)
        addSubview(favoriteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Term Label
            termLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            termLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            termLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Definition Label
            definitionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            definitionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            definitionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Favorite Button
            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Configuration
    func configure(term: String, definition: String, isFavorite: Bool) {
        termLabel.text = term
        definitionLabel.text = definition
        updateFavoriteButton(isFavorited: isFavorite)
    }
    
    // MARK: - UI Updates
    func updateFavoriteButton(isFavorited: Bool) {
        let imageName = isFavorited ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = isFavorited ? .systemYellow : .gray
    }
    
    func flipCard() {
        isShowingTerm.toggle()
        
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: self, duration: 0.5, options: transitionOptions, animations: {
            if self.isShowingTerm {
                self.termLabel.isHidden = false
                self.definitionLabel.isHidden = true
            } else {
                self.termLabel.isHidden = true
                self.definitionLabel.isHidden = false
            }
        })
    }
    
    func resetToTermSide() {
        isShowingTerm = true
        termLabel.isHidden = false
        definitionLabel.isHidden = true
    }
}
