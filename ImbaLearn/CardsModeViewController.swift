//
//  CardsModeViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 18.11.25.
//

import UIKit

class CardsModeViewController: BaseViewController {
    
    // MARK: - Properties
    var module: ModuleResponse?
    var terms: [TermResponse] = []  // REAL API DATA
    
    // MARK: - UI Elements
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .text
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "1 / 0"
        label.textColor = .text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var currentCardView: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private lazy var nextCardView: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.alpha = 0
        return card
    }()
    
    // MARK: - Private Properties
    private var currentIndex: Int = 0 {
        didSet {
            updateProgressLabel()
            updateCards()
        }
    }
    
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        
        // Load terms if module is provided but terms array is empty
        if let module = module, terms.isEmpty {
            loadTerms(for: module)
        } else {
            updateCards()
            updateProgressLabel()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        title = "Cards Mode"
        
        view.addSubview(closeButton)
        view.addSubview(progressLabel)
        view.addSubview(cardContainer)
        
        cardContainer.addSubview(nextCardView)
        cardContainer.addSubview(currentCardView)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            // Close Button - top left
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Progress Label - top center
            progressLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Card Container
            cardContainer.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 40),
            cardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            cardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            cardContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            // Current Card View
            currentCardView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            currentCardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            currentCardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            currentCardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            
            // Next Card View
            nextCardView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            nextCardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            nextCardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            nextCardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor)
        ])
    }
    
    private func setupGestures() {
        // Pan gesture for swiping
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        currentCardView.addGestureRecognizer(panGesture)
        
        // Tap gesture for flipping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        currentCardView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - API Methods
    private func loadTerms(for module: ModuleResponse) {
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.ok {
                      //  self.terms = response.data ?? []
                        self.updateCards()
                        self.updateProgressLabel()
                    } else {
                        print("Failed to load terms: \(response.message)")
                    }
                case .failure(let error):
                    print("Error loading terms: \(error)")
                }
            }
        }
    }
    
    private func toggleFavorite(for termId: String, isFavorite: Bool) {
        // TODO: Implement API call to update favorite status
        print("Toggle favorite for term: \(termId) to \(isFavorite)")
        // NetworkManager.shared.updateTermFavorite(termId: termId, isFavorite: isFavorite) { ... }
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        currentCardView.flipCard()
    }
    
    @objc private func favoriteTapped() {
        guard currentIndex < terms.count else { return }
        
        let term = terms[currentIndex]
        let newFavoriteStatus = !term.isStarred
        
        print("⭐ Cards mode: Toggling favorite for term: \(term.term) to \(newFavoriteStatus)")
        
        // Update locally first
        terms[currentIndex].isStarred = newFavoriteStatus
        
        // Update UI immediately
        currentCardView.updateFavoriteButton(isFavorited: newFavoriteStatus)
        
        // Call API to update on server
        NetworkManager.shared.updateTermFavorite(termId: term.id, isStarred: newFavoriteStatus) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTerm):
                    print("✅ Cards mode: Favorite updated successfully")
                    // Update local data with server response
                    if let currentIndex = self?.currentIndex {
                        self?.terms[currentIndex] = updatedTerm
                    }
                    
                case .failure(let error):
                    print("❌ Cards mode: Failed to update favorite: \(error)")
                    
                    // Revert local change
                    if let currentIndex = self?.currentIndex {
                        self?.terms[currentIndex].isStarred = term.isStarred // Revert
                        self?.currentCardView.updateFavoriteButton(isFavorited: term.isStarred)
                        
                        // Show error
                        let alert = UIAlertController(
                            title: "Error",
                            message: "Failed to update favorite",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: cardContainer)
        let velocity = gesture.velocity(in: cardContainer)
        
        switch gesture.state {
        case .began, .changed:
            // Move card with finger
            currentCardView.transform = CGAffineTransform(translationX: translation.x, y: 0)
            
            // Calculate rotation based on swipe distance
            let rotationAngle = translation.x / cardContainer.bounds.width * 0.4
            currentCardView.transform = currentCardView.transform.rotated(by: rotationAngle)
            
            // Show/hide next card based on direction
            if translation.x > 0 {
                // Swiping right - show previous card
                if currentIndex > 0 {
                    configureCardView(nextCardView, with: terms[currentIndex - 1])
                    nextCardView.alpha = min(abs(translation.x) / 100, 1.0)
                    nextCardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            } else {
                // Swiping left - show next card
                if currentIndex < terms.count - 1 {
                    configureCardView(nextCardView, with: terms[currentIndex + 1])
                    nextCardView.alpha = min(abs(translation.x) / 100, 1.0)
                    nextCardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }
            }
            
        case .ended, .cancelled:
            let swipeThreshold: CGFloat = 100
            let velocityThreshold: CGFloat = 500
            
            let shouldSwipe = abs(translation.x) > swipeThreshold || abs(velocity.x) > velocityThreshold
            
            if shouldSwipe {
                // Swipe completed - throw card away
                let direction: CGFloat = translation.x > 0 ? 1 : -1
                let throwDistance = direction * view.bounds.width * 1.5
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                    self.currentCardView.transform = CGAffineTransform(translationX: throwDistance, y: 0)
                        .rotated(by: direction * 0.4)
                    self.currentCardView.alpha = 0
                } completion: { _ in
                    self.performSwipe(direction: direction)
                }
            } else {
                // Return to center
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: []) {
                    self.currentCardView.transform = .identity
                    self.currentCardView.alpha = 1
                    self.nextCardView.alpha = 0
                    self.nextCardView.transform = .identity
                }
            }
            
        default:
            break
        }
    }
    
    private func performSwipe(direction: CGFloat) {
        if direction > 0 {
            // Swipe right - go to previous card
            if currentIndex > 0 {
                currentIndex -= 1
            }
        } else {
            // Swipe left - go to next card
            if currentIndex < terms.count - 1 {
                currentIndex += 1
            }
        }
        
        // Reset card positions and prepare for next swipe
        resetCardPositions()
    }
    
    private func resetCardPositions() {
        // Reset current card
        currentCardView.transform = .identity
        currentCardView.alpha = 1
        currentCardView.resetToTermSide()
        
        // Reset next card
        nextCardView.transform = .identity
        nextCardView.alpha = 0
        nextCardView.resetToTermSide()
        
        // Update pan gesture to new current card
        panGesture.view?.removeGestureRecognizer(panGesture)
        currentCardView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Helper Methods
    private func updateProgressLabel() {
        progressLabel.text = "\(currentIndex + 1) / \(terms.count)"
    }
    
    private func updateCards() {
        guard !terms.isEmpty, currentIndex < terms.count else {
            // If no terms, show empty state
            currentCardView.configure(term: "No terms", definition: "Add terms to this module to start studying", isFavorite: false)
            currentCardView.favoriteButton.isHidden = true
            return
        }
        
        let term = terms[currentIndex]
        configureCardView(currentCardView, with: term)
        currentCardView.favoriteButton.isHidden = false
        currentCardView.favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        
        // Prepare next card (if any)
        if currentIndex < terms.count - 1 {
            configureCardView(nextCardView, with: terms[currentIndex + 1])
        } else if currentIndex > 0 {
            configureCardView(nextCardView, with: terms[currentIndex - 1])
        }
    }
    
    private func configureCardView(_ cardView: CardView, with term: TermResponse) {
        cardView.configure(
            term: term.term,
            definition: term.definition,
            isFavorite: term.isStarred
        )
    }
}
