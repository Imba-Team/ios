
import UIKit

class CardsModeViewController: BaseViewController {
    
    // MARK: - Properties
    private var viewModel: CardsModeViewModel
    var onFavoriteUpdate: (() -> Void)? {
        get { viewModel.onFavoriteUpdate }
        set { viewModel.onFavoriteUpdate = newValue }
    }
    
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
    private var panGesture: UIPanGestureRecognizer!
    
    // MARK: - Initialization
    init(viewModel: CardsModeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewModelBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(module: ModuleResponse? = nil, terms: [TermResponse] = []) {
        let viewModel = CardsModeViewModel(module: module, terms: terms)
        self.init(viewModel: viewModel)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
        
        // Show loading indicator
        loadingIndicator.startAnimating()
        
        // Load terms if module is provided but terms array is empty
        if viewModel.module != nil && viewModel.isEmptyState {
            viewModel.loadTerms()
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
    
    // MARK: - Setup Methods
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
    
    private func setupViewModelBindings() {
        viewModel.delegate = self
        viewModel.onCurrentIndexChange = { [weak self] _ in
            self?.updateProgressLabel()
            self?.updateAllCards()
        }
        viewModel.onTermsEmpty = { [weak self] in
            self?.showEmptyState()
        }
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
    
    // MARK: - Card Management
    private func updateAllCards() {
        guard !viewModel.isEmptyState else {
            showEmptyState()
            return
        }
        
        // Update current card
        updateCurrentCard()
        
        // Update side cards
        updateSideCards()
    }
    
    private func updateCurrentCard() {
        guard let term = viewModel.currentTerm else { return }
        
        configureCardView(currentCardView, with: term)
        currentCardView.favoriteButton.isHidden = false
        currentCardView.favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    private func updateSideCards() {
        // Show/hide previous card
        if let previousTerm = viewModel.previousTerm {
            previousCardView.isHidden = false
            configureCardView(previousCardView, with: previousTerm)
        } else {
            previousCardView.isHidden = true
        }
        
        // Show/hide next card
        if let nextTerm = viewModel.nextTerm {
            nextCardView.isHidden = false
            configureCardView(nextCardView, with: nextTerm)
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
    
    private func showEmptyState() {
        currentCardView.configure(term: "No terms", definition: "Add terms to this module to start studying", isFavorite: false)
        currentCardView.favoriteButton.isHidden = true
        previousCardView.isHidden = true
        nextCardView.isHidden = true
        progressLabel.text = "0 / 0"
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        currentCardView.flipCard()
    }
    
    @objc private func previousCardTapped() {
        if viewModel.navigateLeft() {
            navigateToCard(direction: .left)
        }
    }
    
    @objc private func nextCardTapped() {
        if viewModel.navigateRight() {
            navigateToCard(direction: .right)
        }
    }
    
    @objc private func favoriteTapped() {
        viewModel.toggleFavoriteForCurrentTerm()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !viewModel.isEmptyState else { return }
        
        let translation = gesture.translation(in: cardContainer)
        let velocity = gesture.velocity(in: cardContainer)
        
        switch gesture.state {
        case .began, .changed:
            let limitedTranslationX = viewModel.calculateLimitedTranslation(translation.x)
            
            // Smooth, stutter-free dragging
            UIView.performWithoutAnimation {
                self.currentCardView.transform =
                CGAffineTransform(translationX: limitedTranslationX, y: 0)
            }
            
            // Dim based on distance
            let alpha = viewModel.calculateAlpha(for: limitedTranslationX)
            currentCardView.alpha = alpha
            
        case .ended, .cancelled:
            let (shouldSwipe, direction) = viewModel.calculateSwipeParameters(
                translation: translation.x,
                velocity: velocity.x,
                cardContainerWidth: cardContainer.bounds.width
            )
            
            if shouldSwipe, let direction = direction {
                let throwDistance = viewModel.getThrowDistance(
                    for: direction,
                    cardContainerWidth: cardContainer.bounds.width
                )
                
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
                    // Navigate based on direction
                    if direction > 0 {
                        _ = self.viewModel.navigateLeft()
                    } else {
                        _ = self.viewModel.navigateRight()
                    }
                    
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
    
    private func navigateToCard(direction: NavigationDirection) {
        // Animate the transition
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut, animations: {
            // Move current card out
            let exitTransform = direction == .left ?
            CGAffineTransform(translationX: -self.cardContainer.bounds.width, y: 0) :
            CGAffineTransform(translationX: self.cardContainer.bounds.width, y: 0)
            self.currentCardView.transform = exitTransform
            self.currentCardView.alpha = 0
            
            // Bring new card in
            if direction == .left {
                self.previousCardView.transform = .identity
                self.previousCardView.alpha = 1
            } else {
                self.nextCardView.transform = .identity
                self.nextCardView.alpha = 1
            }
        }) { _ in
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
        progressLabel.text = viewModel.progressText
    }
}

// MARK: - CardsModeViewModelDelegate
extension CardsModeViewController: CardsModeViewModelDelegate {
    func didLoadTerms(terms: [TermResponse]) {
        loadingIndicator.stopAnimating()
        updateAllCards()
        updateProgressLabel()
        print("✅ Loaded \(terms.count) terms for cards mode")
    }
    
    func didFailToLoadTerms(error: String) {
        loadingIndicator.stopAnimating()
        showEmptyState()
        print("Failed to load terms: \(error)")
    }
    
    func didUpdateFavoriteStatus(at index: Int, isStarred: Bool) {
        // Update UI immediately
        if let currentTerm = viewModel.currentTerm, index == viewModel.currentIndex {
            currentCardView.updateFavoriteButton(isFavorited: currentTerm.isStarred)
        }
    }
    
    func didFailToUpdateFavorite(error: String) {
        // Show error
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to update favorite",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
