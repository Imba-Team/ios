//
//  ModuleDetailViewModel.swift
//  ImbaLearn
//

import UIKit

protocol ModuleDetailViewModelDelegate: AnyObject {
    func onDataUpdated() -> Void
    func onError(_ message: String) -> Void
    func onModuleDeleted() -> Void
    func onNavigateToEditModule(_ module: ModuleResponse, terms: [TermResponse]) -> Void
    func onNavigateToCardsMode(_ module: ModuleResponse, terms: [TermResponse]) -> Void
    func onNavigateBack() -> Void
    func onUpdateCardsButtonState(_ isEnabled: Bool) -> Void
    func onUpdateEmptyState(_ isEmpty: Bool, message: String) -> Void
}

class ModuleDetailViewModel {
    
    // MARK: - Properties
    var module: ModuleResponse!
    private(set) var terms: [TermResponse] = []
    private(set) var filteredTerms: [TermResponse] = []
    private(set) var showOnlyFavorites = false
    private(set) var isLoading = false
    private(set) var creatorInfo: UserInfo?
    
    weak var delegate: ModuleDetailViewModelDelegate?
      
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
                        self.delegate?.onError(response.message)
                    }
                    
                case .failure(let error):
                    self.delegate?.onError(error.localizedDescription)
                }
            }
        }
    }
    
    func toggleFavoriteFilter() {
        showOnlyFavorites.toggle()
        updateFilteredTerms()
        delegate?.onDataUpdated()
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
        
        // IMPORTANT: Update filteredTerms based on the new state
        if showOnlyFavorites && !newFavoriteStatus {
            // If we're in favorites mode and user unfavorites, remove from filtered
            if let filteredIndex = filteredTerms.firstIndex(where: { $0.id == termId }) {
                filteredTerms.remove(at: filteredIndex)
            }
        } else if showOnlyFavorites && newFavoriteStatus {
            // If we're in favorites mode and user favorites, add to filtered
            filteredTerms.append(terms[termIndex])
        } else {
            // In "All" mode, just update the filtered terms
            if let filteredIndex = filteredTerms.firstIndex(where: { $0.id == termId }) {
                filteredTerms[filteredIndex].isStarred = newFavoriteStatus
            }
        }
        
        // Immediately notify delegate to update UI
        delegate?.onDataUpdated()
        
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
                        
                        // Update filtered terms too
                        if let filteredIndex = self?.filteredTerms.firstIndex(where: { $0.id == termId }) {
                            self?.filteredTerms[filteredIndex] = updatedTerm
                        }
                        
                        // Notify UI of the update
                        self?.delegate?.onDataUpdated()
                        self?.updateCardsModeButtonState()
                    }
                    
                case .failure(let error):
                    print("❌ Failed to update favorite: \(error)")
                    
                    // Revert local change if API call fails
                    if let index = self?.terms.firstIndex(where: { $0.id == termId }) {
                        self?.terms[index].isStarred = term.isStarred // Revert to original
                        
                        // Also revert in filteredTerms
                        if let filteredIndex = self?.filteredTerms.firstIndex(where: { $0.id == termId }) {
                            self?.filteredTerms[filteredIndex].isStarred = term.isStarred
                        }
                        
                        // Notify UI to revert
                        self?.delegate?.onDataUpdated()
                        self?.updateCardsModeButtonState()
                        
                        // Show error to user
                        self?.delegate?.onError("Failed to update favorite: \(error.localizedDescription)")
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
                        self.delegate?.onModuleDeleted()
                    } else {
                        self.delegate?.onError(response.message)
                    }
                    
                case .failure(let error):
                    self.delegate?.onError(error.localizedDescription)
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
            
            delegate?.onError(message)
            return
        }
        
        delegate?.onNavigateToCardsMode(module, terms: termsToShow)
    }
    
    func editModule() {
        delegate?.onNavigateToEditModule(module, terms: terms)
    }
    
    func updateModule(_ updatedModule: ModuleResponse) {
        module = updatedModule
        delegate?.onDataUpdated()
    }
    
    func updateTerms(_ updatedTerms: [TermResponse]) {
        terms = updatedTerms
        updateFilteredTerms()
        updateCardsModeButtonState()
        updateEmptyState()
        delegate?.onDataUpdated()
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
        guard let creatorInfo = creatorInfo else {
            print("⚠️ No creator info available")
            return nil
        }
        
        print("🔄 Getting avatar URL for creator: \(creatorInfo.name)")
        print("📸 Avatar path: \(creatorInfo.avatarUrl ?? "nil")")
        
        // Try the computed property first
        if let url = creatorInfo.fullAvatarUrl {
            print("✅ Created URL: \(url.absoluteString)")
            return url
        }
        
        // Fallback: Try to construct URL manually
        if let avatarPath = creatorInfo.avatarUrl, !avatarPath.isEmpty {
            let baseURL = "https://imba-server.up.railway.app"
            let fullUrlString = baseURL + avatarPath
            print("🔧 Manually constructing URL: \(fullUrlString)")
            return URL(string: fullUrlString)
        }
        
        print("❌ Could not create avatar URL for creator")
        return nil
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
        delegate?.onDataUpdated()
    }
    
    private func updateFilteredTerms() {
        if showOnlyFavorites {
            filteredTerms = terms.filter { $0.isStarred }
        } else {
            filteredTerms = terms
        }
    }
    
    private func loadCreatorInfo() {
        print("🔄 Loading creator info - Assuming current user")
        
        // ALWAYS assume it's the current user
        // Get from wherever we have user data
        
        // Method 1: Check UserDefaults
        if let savedUserData = UserDefaults.standard.data(forKey: "currentUser"),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            print("✅ Using current user from UserDefaults: \(savedUser.name)")
            self.creatorInfo = UserInfo(
                id: savedUser.id,
                name: savedUser.name,
                avatarUrl: savedUser.profilePicture,
                isCurrentUser: true
            )
        }
        // Method 2: If we just fetched modules, the user data might be in the module response
        else if let currentUserId = UserDefaults.standard.string(forKey: "currentUserId") {
            print("✅ Using current user ID: \(currentUserId)")
            self.creatorInfo = UserInfo(
                id: currentUserId,
                name: "You",  // Default name
                avatarUrl: nil,
                isCurrentUser: true
            )
        }
        // Method 3: Fallback
        else {
            print("⚠️ Couldn't find user info, using fallback")
            self.creatorInfo = UserInfo(
                id: module.userId,
                name: "You",
                avatarUrl: nil,
                isCurrentUser: true
            )
        }
        
        self.delegate?.onDataUpdated()
    }
    
    private func updateModuleInfo() {
        // This would update any UI info if needed
        delegate?.onDataUpdated()
    }
    
    private func updateCardsModeButtonState() {
        let termsToShow = showOnlyFavorites ? terms.filter { $0.isStarred } : terms
        let isEnabled = !termsToShow.isEmpty
        delegate?.onUpdateCardsButtonState(isEnabled)
    }
    
    private func updateEmptyState() {
        let isEmpty = filteredTerms.isEmpty
        
        if isEmpty {
            if terms.isEmpty {
                delegate?.onUpdateEmptyState(true, message: "No terms yet")
            } else if showOnlyFavorites {
                delegate?.onUpdateEmptyState(true, message: "No favorite terms")
            } else {
                delegate?.onUpdateEmptyState(false, message: "")
            }
        } else {
            delegate?.onUpdateEmptyState(false, message: "")
        }
    }
}
