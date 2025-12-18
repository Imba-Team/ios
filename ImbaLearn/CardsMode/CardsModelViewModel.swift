//
//  CardsModeViewModel.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 18.11.25.
//

import Foundation

protocol CardsModeViewModelDelegate: AnyObject {
    func didLoadTerms(terms: [TermResponse])
    func didFailToLoadTerms(error: String)
    func didUpdateFavoriteStatus(at index: Int, isStarred: Bool)
    func didFailToUpdateFavorite(error: String)
}

class CardsModeViewModel {
    
    // MARK: - Properties
    weak var delegate: CardsModeViewModelDelegate?
    private(set) var module: ModuleResponse?
    private(set) var terms: [TermResponse] = []
    private(set) var currentIndex: Int = 0 {
        didSet {
            onCurrentIndexChange?(currentIndex)
        }
    }
    
    // MARK: - Callbacks
    var onFavoriteUpdate: (() -> Void)?
    var onCurrentIndexChange: ((Int) -> Void)?
    var onTermsEmpty: (() -> Void)?
    
    // MARK: - Computed Properties
    var currentTerm: TermResponse? {
        guard currentIndex >= 0 && currentIndex < terms.count else { return nil }
        return terms[currentIndex]
    }
    
    var previousTerm: TermResponse? {
        guard currentIndex > 0 else { return nil }
        return terms[currentIndex - 1]
    }
    
    var nextTerm: TermResponse? {
        guard currentIndex < terms.count - 1 else { return nil }
        return terms[currentIndex + 1]
    }
    
    var progressText: String {
        return "\(currentIndex + 1) / \(terms.count)"
    }
    
    var canNavigateLeft: Bool {
        return currentIndex > 0
    }
    
    var canNavigateRight: Bool {
        return currentIndex < terms.count - 1
    }
    
    var isEmptyState: Bool {
        return terms.isEmpty
    }
    
    // MARK: - Initialization
    init(module: ModuleResponse? = nil, terms: [TermResponse] = []) {
        self.module = module
        self.terms = terms
    }
    
    // MARK: - API Methods
    func loadTerms() {
        guard let module = module else {
            delegate?.didFailToLoadTerms(error: "No module provided")
            return
        }
        
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.ok {
                        self.terms = response.data?.data ?? []
                        if self.terms.isEmpty {
                            self.onTermsEmpty?()
                        }
                        self.delegate?.didLoadTerms(terms: self.terms)
                    } else {
                        self.delegate?.didFailToLoadTerms(error: response.message)
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadTerms(error: error.localizedDescription)
                }
            }
        }
    }
    
    func toggleFavoriteForCurrentTerm() {
        guard let term = currentTerm else { return }
        
        let newFavoriteStatus = !term.isStarred
        
        // Update locally first
        terms[currentIndex].isStarred = newFavoriteStatus
        
        // Notify delegate
        delegate?.didUpdateFavoriteStatus(at: currentIndex, isStarred: newFavoriteStatus)
        
        // Call API to update on server
        NetworkManager.shared.updateTermFavorite(termId: term.id, isStarred: newFavoriteStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTerm):
                    // Update local data with server response
                    if self.currentIndex < self.terms.count {
                        self.terms[self.currentIndex] = updatedTerm
                    }
                    
                    // Notify about favorite update
                    self.onFavoriteUpdate?()
                    
                case .failure(let error):
                    // Revert local change
                    if self.currentIndex < self.terms.count {
                        self.terms[self.currentIndex].isStarred = term.isStarred // Revert
                        self.delegate?.didUpdateFavoriteStatus(at: self.currentIndex, isStarred: term.isStarred)
                    }
                    
                    // Notify about error
                    self.delegate?.didFailToUpdateFavorite(error: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation Methods
    func navigateToPrevious() -> Bool {
        guard canNavigateLeft else { return false }
        currentIndex -= 1
        return true
    }
    
    func navigateToNext() -> Bool {
        guard canNavigateRight else { return false }
        currentIndex += 1
        return true
    }
    
    func navigateToCard(at index: Int) -> Bool {
        guard index >= 0 && index < terms.count else { return false }
        currentIndex = index
        return true
    }
    
    func navigateLeft() -> Bool {
        return navigateToPrevious()
    }
    
    func navigateRight() -> Bool {
        return navigateToNext()
    }
    
    // MARK: - Card Data Methods
    func getTerm(at index: Int) -> TermResponse? {
        guard index >= 0 && index < terms.count else { return nil }
        return terms[index]
    }
    
    func updateTerm(at index: Int, with term: TermResponse) {
        guard index >= 0 && index < terms.count else { return }
        terms[index] = term
    }
    
    // MARK: - Gesture Helper Methods
    func calculateSwipeParameters(translation: CGFloat, velocity: CGFloat, cardContainerWidth: CGFloat) -> (shouldSwipe: Bool, direction: CGFloat?) {
        guard !terms.isEmpty else { return (false, nil) }
        
        let swipeThreshold: CGFloat = 100
        let velocityThreshold: CGFloat = 500
        
        let shouldSwipe = abs(translation) > swipeThreshold || abs(velocity) > velocityThreshold
        
        let canSwipeLeft = translation > 0 && canNavigateLeft
        let canSwipeRight = translation < 0 && canNavigateRight
        
        if shouldSwipe && (canSwipeLeft || canSwipeRight) {
            let direction: CGFloat = translation > 0 ? 1 : -1
            return (true, direction)
        }
        
        return (false, nil)
    }
    
    func calculateLimitedTranslation(_ translation: CGFloat) -> CGFloat {
        var limitedTranslation = translation
        
        // Prevent swiping left on first card
        if currentIndex == 0 && translation > 0 {
            limitedTranslation = min(translation, 50)
        }
        
        // Prevent swiping right on last card
        if currentIndex == terms.count - 1 && translation < 0 {
            limitedTranslation = max(translation, -50)
        }
        
        return limitedTranslation
    }
    
    func calculateAlpha(for translation: CGFloat) -> CGFloat {
        let swipePercentage = min(abs(translation) / 150, 1.0)
        return 1.0 - (swipePercentage * 0.5)
    }
    
    func getThrowDistance(for direction: CGFloat, cardContainerWidth: CGFloat) -> CGFloat {
        return direction * cardContainerWidth
    }
}
