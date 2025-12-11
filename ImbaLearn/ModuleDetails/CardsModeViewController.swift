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
    var terms: [TermResponse] = []
    var onFavoriteUpdate: (() -> Void)? // Callback to update parent
    
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
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var currentCardView: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private lazy var previousCardView: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.alpha = 0.3
        card.transform = CGAffineTransform(translationX: -50, y: 0).scaledBy(x: 0.8, y: 0.8)
        return card
    }()
    
    private lazy var nextCardView: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.alpha = 0.3
        card.transform = CGAffineTransform(translationX: 50, y: 0).scaledBy(x: 0.8, y: 0.8)
        return card
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .pinkButton
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Private Properties
    private var currentIndex: Int = 0 {
        didSet {
            updateProgressLabel()
            updateAllCards()
        }
    }
    
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        
        // Show loading indicator
        loadingIndicator.startAnimating()
        
        // Load terms if module is provided but terms array is empty
        if let module = module, terms.isEmpty {
            loadTerms(for: module)
        } else {
            loadingIndicator.stopAnimating()
            updateAllCards()
            updateProgressLabel()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Notify parent that favorites might have changed
        onFavoriteUpdate?()
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        
        view.addSubview(closeButton)
        view.addSubview(progressLabel)
        view.addSubview(cardContainer)
        view.addSubview(loadingIndicator)
        
        // Add cards in order: previous (left), current (center), next (right)
        cardContainer.addSubview(previousCardView)
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
            
            // Current Card View (center)
            currentCardView.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            currentCardView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            currentCardView.widthAnchor.constraint(equalTo: cardContainer.widthAnchor, multiplier: 0.9),
            currentCardView.heightAnchor.constraint(equalTo: cardContainer.heightAnchor, multiplier: 0.8),
            
            // Previous Card View (left)
            previousCardView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            previousCardView.trailingAnchor.constraint(equalTo: currentCardView.leadingAnchor, constant: -20),
            previousCardView.widthAnchor.constraint(equalTo: currentCardView.widthAnchor, multiplier: 0.8),
            previousCardView.heightAnchor.constraint(equalTo: currentCardView.heightAnchor, multiplier: 0.8),
            
            // Next Card View (right)
            nextCardView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            nextCardView.leadingAnchor.constraint(equalTo: currentCardView.trailingAnchor, constant: 20),
            nextCardView.widthAnchor.constraint(equalTo: currentCardView.widthAnchor, multiplier: 0.8),
            nextCardView.heightAnchor.constraint(equalTo: currentCardView.heightAnchor, multiplier: 0.8),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        // Pan gesture for swiping left/right
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        currentCardView.addGestureRecognizer(panGesture)
        
        // Tap gesture for flipping
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        currentCardView.addGestureRecognizer(tapGesture)
        
        // Tap gestures for side cards
        let previousTapGesture = UITapGestureRecognizer(target: self, action: #selector(previousCardTapped))
        previousCardView.addGestureRecognizer(previousTapGesture)
        
        let nextTapGesture = UITapGestureRecognizer(target: self, action: #selector(nextCardTapped))
        nextCardView.addGestureRecognizer(nextTapGesture)
    }
    
    // MARK: - API Methods
    private func loadTerms(for module: ModuleResponse) {
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    if response.ok {
                        self.terms = response.data?.data ?? []
                        self.updateAllCards()
                        self.updateProgressLabel()
                        
                        print("✅ Loaded \(self.terms.count) terms for cards mode")
                    } else {
                        print("Failed to load terms: \(response.message)")
                        self.showEmptyState()
                    }
                case .failure(let error):
                    print("Error loading terms: \(error)")
                    self.showEmptyState()
                }
            }
        }
    }
    
    private func showEmptyState() {
        currentCardView.configure(term: "No terms", definition: "Add terms to this module to start studying", isFavorite: false)
        currentCardView.favoriteButton.isHidden = true
        previousCardView.isHidden = true
        nextCardView.isHidden = true
        progressLabel.text = "0 / 0"
    }
    
    // MARK: - Card Management
    private func updateAllCards() {
        guard !terms.isEmpty else {
            showEmptyState()
            return
        }
        
        // Update current card
        updateCurrentCard()
        
        // Update side cards
        updateSideCards()
    }
    
    private func updateCurrentCard() {
        guard currentIndex < terms.count else { return }
        
        let term = terms[currentIndex]
        configureCardView(currentCardView, with: term)
        currentCardView.favoriteButton.isHidden = false
        currentCardView.favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    private func updateSideCards() {
        // Show/hide previous card
        if currentIndex > 0 {
            previousCardView.isHidden = false
            configureCardView(previousCardView, with: terms[currentIndex - 1])
        } else {
            previousCardView.isHidden = true
        }
        
        // Show/hide next card
        if currentIndex < terms.count - 1 {
            nextCardView.isHidden = false
            configureCardView(nextCardView, with: terms[currentIndex + 1])
        } else {
            nextCardView.isHidden = true
        }
    }
    
    private func configureCardView(_ cardView: CardView, with term: TermResponse) {
        cardView.configure(
            term: term.term,
            definition: term.definition,
            isFavorite: term.isStarred
        )
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        currentCardView.flipCard()
    }
    
    @objc private func previousCardTapped() {
        if currentIndex > 0 {
            navigateToCard(at: currentIndex - 1, direction: .left)
        }
    }
    
    @objc private func nextCardTapped() {
        if currentIndex < terms.count - 1 {
            navigateToCard(at: currentIndex + 1, direction: .right)
        }
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
                    
                    // Update the callback to refresh parent
                    self?.onFavoriteUpdate?()
                    
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
        guard !terms.isEmpty else { return }

        let translation = gesture.translation(in: cardContainer)
        let velocity = gesture.velocity(in: cardContainer)

        switch gesture.state {

        case .began, .changed:
            var limitedTranslationX = translation.x

            // Prevent swiping left on first card
            if currentIndex == 0 && translation.x > 0 {
                limitedTranslationX = min(translation.x, 50)
            }

            // Prevent swiping right on last card
            if currentIndex == terms.count - 1 && translation.x < 0 {
                limitedTranslationX = max(translation.x, -50)
            }

            // Smooth, stutter-free dragging
            UIView.performWithoutAnimation {
                self.currentCardView.transform =
                    CGAffineTransform(translationX: limitedTranslationX, y: 0)
            }

            // Dim based on distance
            let swipePercentage = min(abs(translation.x) / 150, 1.0)
            currentCardView.alpha = 1.0 - (swipePercentage * 0.5)

        case .ended, .cancelled:
            let swipeThreshold: CGFloat = 100
            let velocityThreshold: CGFloat = 500

            let shouldSwipe = abs(translation.x) > swipeThreshold ||
                              abs(velocity.x) > velocityThreshold

            let canSwipeLeft = translation.x > 0 && currentIndex > 0
            let canSwipeRight = translation.x < 0 && currentIndex < terms.count - 1

            if shouldSwipe && (canSwipeLeft || canSwipeRight) {
                let direction: CGFloat = translation.x > 0 ? 1 : -1
                let throwDistance = direction * cardContainer.bounds.width

                // FAST + SMOOTH EXIT ANIMATION
                UIView.animate(
                    withDuration: 0.22,
                    delay: 0,
                    usingSpringWithDamping: 0.85,
                    initialSpringVelocity: 0.6,
                    options: [.curveEaseOut]
                ) {
                    self.currentCardView.transform = CGAffineTransform(
                        translationX: throwDistance,
                        y: 0
                    )
                    self.currentCardView.alpha = 0
                } completion: { _ in
                    let newIndex = direction > 0
                        ? self.currentIndex - 1
                        : self.currentIndex + 1

                    self.currentIndex = newIndex

                    // Reset instantly for next card
                    self.currentCardView.transform = .identity
                    self.currentCardView.alpha = 1
                }

            } else {
                // CANCEL SWIPE — snap back smoothly
                UIView.animate(
                    withDuration: 0.22,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0.4,
                    options: [.curveEaseOut]
                ) {
                    self.currentCardView.transform = .identity
                    self.currentCardView.alpha = 1
                }
            }

        default:
            break
        }
    }

    
    private enum NavigationDirection {
        case left, right
    }
    
    private func navigateToCard(at index: Int, direction: NavigationDirection) {
        guard index >= 0 && index < terms.count else { return }
        
        // Animate the transition
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut, animations: {
            // Move current card out
            let exitTransform = direction == .left ?
                CGAffineTransform(translationX: -self.cardContainer.bounds.width, y: 0) :
                CGAffineTransform(translationX: self.cardContainer.bounds.width, y: 0)
            self.currentCardView.transform = exitTransform
            self.currentCardView.alpha = 0
            
            // Bring new card in
            let entryTransform = direction == .left ?
                CGAffineTransform(translationX: self.cardContainer.bounds.width, y: 0) :
                CGAffineTransform(translationX: -self.cardContainer.bounds.width, y: 0)
            
            if direction == .left {
                self.previousCardView.transform = .identity
                self.previousCardView.alpha = 1
            } else {
                self.nextCardView.transform = .identity
                self.nextCardView.alpha = 1
            }
        }) { _ in
            // Update index
            self.currentIndex = index
            
            // Reset transforms
            self.currentCardView.transform = .identity
            self.currentCardView.alpha = 1
            self.currentCardView.resetToTermSide()
            
            // Update all cards for new position
            self.updateAllCards()
            
            // Reset side cards to their positions
            UIView.animate(withDuration: 0.2) {
                self.previousCardView.transform = CGAffineTransform(translationX: -50, y: 0).scaledBy(x: 0.8, y: 0.8)
                self.previousCardView.alpha = 0.3
                
                self.nextCardView.transform = CGAffineTransform(translationX: 50, y: 0).scaledBy(x: 0.8, y: 0.8)
                self.nextCardView.alpha = 0.3
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateProgressLabel() {
        progressLabel.text = "\(currentIndex + 1) / \(terms.count)"
    }
}
