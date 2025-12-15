//
//  ModuleDetailViewModel.swift
//  ImbaLearn
//

import UIKit

class ModuleDetailViewModel {
    
    // MARK: - Properties
    var module: ModuleResponse!
    private(set) var terms: [TermResponse] = []
    private(set) var filteredTerms: [TermResponse] = []
    private(set) var showOnlyFavorites = false
    private(set) var isLoading = false
    private(set) var creatorInfo: UserInfo?
    
    // MARK: - Callbacks
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onModuleDeleted: (() -> Void)?
    var onNavigateToEditModule: ((ModuleResponse, [TermResponse]) -> Void)?
    var onNavigateToCardsMode: ((ModuleResponse, [TermResponse]) -> Void)?
    var onNavigateBack: (() -> Void)?
    var onUpdateCardsButtonState: ((Bool) -> Void)?
    var onUpdateEmptyState: ((Bool, String) -> Void)?
    
    // MARK: - Public Methods
    
    func loadModuleDetails() {
        guard !isLoading else { return }
        
        isLoading = true
        
        updateModuleInfo()
        loadCreatorInfo()
        
        // Load terms
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.ok {
                        self.processTerms(response.data?.data ?? [])
                    } else {
                        self.onError?(response.message)
                    }
                    
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func toggleFavoriteFilter() {
        showOnlyFavorites.toggle()
        updateFilteredTerms()
        onDataUpdated?()
        updateCardsModeButtonState()
        updateEmptyState()
    }
    
    func toggleFavorite(for termId: String) {
        guard let term = terms.first(where: { $0.id == termId }),
              let termIndex = terms.firstIndex(where: { $0.id == termId }) else { return }
        
        let newFavoriteStatus = !term.isStarred
        
        print("⭐ Toggling favorite for term: \(term.term) to \(newFavoriteStatus)")
        
        // Update locally first for immediate UI feedback
        terms[termIndex].isStarred = newFavoriteStatus
        updateFilteredTerms()
        
        // Update cards mode button state
        updateCardsModeButtonState()
        
        // Call API to update on server
        NetworkManager.shared.updateTermFavorite(termId: termId, isStarred: newFavoriteStatus) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTerm):
                    print("✅ Favorite updated successfully")
                    
                    // Update local data with server response
                    if let index = self?.terms.firstIndex(where: { $0.id == termId }) {
                        self?.terms[index] = updatedTerm
                        self?.updateFilteredTerms()
                        self?.updateCardsModeButtonState()
                    }
                    
                case .failure(let error):
                    print("❌ Failed to update favorite: \(error)")
                    
                    // Revert local change if API call failed
                    if let index = self?.terms.firstIndex(where: { $0.id == termId }) {
                        self?.terms[index].isStarred = term.isStarred // Revert to original
                        self?.updateFilteredTerms()
                        self?.updateCardsModeButtonState()
                        
                        // Show error to user
                        self?.onError?("Failed to update favorite: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func deleteModule() {
        isLoading = true
        
        NetworkManager.shared.deleteModule(moduleId: module.id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.ok {
                        self.onModuleDeleted?()
                    } else {
                        self.onError?(response.message)
                    }
                    
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func navigateToCardsMode() {
        let termsToShow = showOnlyFavorites ? terms.filter { $0.isStarred } : terms
        
        if termsToShow.isEmpty {
            let message = showOnlyFavorites ?
                "You don't have any favorite terms in this module. Add some favorites first to use Cards Mode with favorites." :
                "This module doesn't have any terms yet. Add some terms first to use Cards Mode."
            
            onError?(message)
            return
        }
        
        onNavigateToCardsMode?(module, termsToShow)
    }
    
    func editModule() {
        onNavigateToEditModule?(module, terms)
    }
    
    func updateModule(_ updatedModule: ModuleResponse) {
        module = updatedModule
        onDataUpdated?()
    }
    
    func updateTerms(_ updatedTerms: [TermResponse]) {
        terms = updatedTerms
        updateFilteredTerms()
        updateCardsModeButtonState()
        updateEmptyState()
        onDataUpdated?()
    }
    
    // MARK: - UI Helpers
    
    func getModuleTitle() -> String {
        return module.title
    }
    
    func getTermsCountText() -> String {
        let actualTermsCount = terms.count
        return "\(actualTermsCount) term\(actualTermsCount == 1 ? "" : "s")"
    }
    
    func getCreatorName() -> String? {
        return creatorInfo?.name
    }
    
    func getCreatorAvatarUrl() -> URL? {
        return creatorInfo?.fullAvatarUrl
    }
    
    func getTerm(at indexPath: IndexPath) -> TermResponse? {
        guard indexPath.row < filteredTerms.count else { return nil }
        return filteredTerms[indexPath.row]
    }
    
    var numberOfTerms: Int {
        return filteredTerms.count
    }
    
    var shouldShowOnlyFavorites: Bool {
        return showOnlyFavorites
    }
    
    var hasCreatorInfo: Bool {
        return creatorInfo != nil
    }
    
    // MARK: - Private Methods
    
    private func processTerms(_ termsData: [TermResponse]) {
        terms = termsData.filter { term in
            guard let termModuleId = term.moduleId else { return true }
            return termModuleId == module.id
        }
        
        print("✅ Showing \(terms.count) terms for module")
        
        updateFilteredTerms()
        updateCardsModeButtonState()
        updateEmptyState()
        onDataUpdated?()
    }
    
    private func updateFilteredTerms() {
        if showOnlyFavorites {
            filteredTerms = terms.filter { $0.isStarred }
        } else {
            filteredTerms = terms
        }
    }
    
    private func loadCreatorInfo() {
        // Check if creator is current user
        if let currentUserId = UserDefaults.standard.string(forKey: "currentUserId"),
           module.userId == currentUserId {
            // Get current user info
            NetworkManager.shared.getUserProfile { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.ok {
                            self.creatorInfo = UserInfo(from: response.data, isCurrentUser: true)
                        } else {
                            // Set default creator info
                            self.creatorInfo = UserInfo(
                                id: self.module.userId,
                                name: "You",
                                avatarUrl: nil,
                                isCurrentUser: true
                            )
                        }
                        self.onDataUpdated?()
                        
                    case .failure:
                        // Set default creator info
                        self.creatorInfo = UserInfo(
                            id: self.module.userId,
                            name: "You",
                            avatarUrl: nil,
                            isCurrentUser: true
                        )
                        self.onDataUpdated?()
                    }
                }
            }
        } else {
            // For other users, show placeholder
            self.creatorInfo = UserInfo(
                id: module.userId,
                name: "Creator",
                avatarUrl: nil,
                isCurrentUser: false
            )
            self.onDataUpdated?()
        }
    }
    
    private func updateModuleInfo() {
        // This would update any UI info if needed
        onDataUpdated?()
    }
    
    private func updateCardsModeButtonState() {
        let termsToShow = showOnlyFavorites ? terms.filter { $0.isStarred } : terms
        let isEnabled = !termsToShow.isEmpty
        onUpdateCardsButtonState?(isEnabled)
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredTerms.isEmpty
        
        if isEmpty {
            if terms.isEmpty {
                onUpdateEmptyState?(true, "No terms yet")
            } else if showOnlyFavorites {
                onUpdateEmptyState?(true, "No favorite terms")
            } else {
                onUpdateEmptyState?(false, "")
            }
        } else {
            onUpdateEmptyState?(false, "")
        }
    }
}
