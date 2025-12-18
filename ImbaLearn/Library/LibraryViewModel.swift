//
//  LibraryViewModel.swift
//  ImbaLearn
//

import Foundation

protocol LibraryViewModelDelegate: AnyObject{
    func onDataUpdated() -> Void
    func onError(_ message: String) -> Void
    func onNavigateToModuleDetail(_ moduleResponse: ModuleResponse) -> Void
    func onUpdateEmptyState(_ isEmpty: Bool, message: String) -> Void
}

class LibraryViewModel {
    
    // MARK: - Properties
    private(set) var modules: [ModuleResponse] = []
    private(set) var filteredModules: [ModuleResponse] = []
    private(set) var isLoading = false
    private var termsCountCache: [String: Int] = [:]
    
    weak var delegate: LibraryViewModelDelegate?
    
    // MARK: - Public Methods
    
    func loadModules() {
        guard !isLoading else { return }
        
        isLoading = true
        
        // First, get current user ID if we don't have it
        if UserDefaults.standard.string(forKey: "currentUserId") == nil {
            fetchCurrentUserId { [weak self] userId in
                if let userId = userId {
                    UserDefaults.standard.set(userId, forKey: "currentUserId")
                    self?.loadModulesWithUserId(userId)
                } else {
                    self?.handleModulesLoadingError("Could not get user ID")
                }
            }
        } else {
            let userId = UserDefaults.standard.string(forKey: "currentUserId")!
            loadModulesWithUserId(userId)
        }
    }
    
    func refreshData() {
        loadModules()
    }
    
    func searchModules(with query: String) {
        let searchText = query.lowercased()
        
        if searchText.isEmpty {
            filteredModules = modules
        } else {
            filteredModules = modules.filter { module in
                module.title.lowercased().contains(searchText) ||
                (module.description?.lowercased().contains(searchText) ?? false)
            }
        }
        
        delegate?.onDataUpdated()
        updateEmptyState()
    }
    
    func sortModules(by option: SortOption) {
        switch option {
        case .date:
            filteredModules.sort { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        case .titleAscending:
            filteredModules.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .titleDescending:
            filteredModules.sort { $0.title.lowercased() > $1.title.lowercased() }
        }
        
        delegate?.onDataUpdated()
    }
    
    func getModule(at indexPath: IndexPath) -> ModuleResponse? {
        guard indexPath.section < filteredModules.count else { return nil }
        return filteredModules[indexPath.section]
    }
    
    func getTermsCount(for moduleId: String) -> Int {
        return termsCountCache[moduleId] ?? 0
    }
    
    // MARK: - Table View Helpers
    
    var numberOfSections: Int {
        return filteredModules.count
    }
    
    func shouldShowEmptyState() -> (Bool, String) {
        let isEmpty = filteredModules.isEmpty
        
        if isEmpty {
            if modules.isEmpty {
                return (true, "No modules yet")
            } else {
                return (true, "No modules found")
            }
        }
        return (false, "")
    }
    
    // MARK: - Private Methods
    
    private func loadModulesWithUserId(_ userId: String) {
        NetworkManager.shared.getUserModules { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.ok {
                        let allModules = response.data ?? []
                        
                        // Filter modules to show only the ones created by current user
                        self.modules = allModules.filter { module in
                            module.userId == userId
                        }
                        
                        print("✅ Showing \(self.modules.count) user modules out of \(allModules.count) total")
                        
                        // If no modules after filtering, show all
                        if self.modules.isEmpty && !allModules.isEmpty {
                            print("⚠️ WARNING: Filtered out all modules! Showing all modules instead.")
                            self.modules = allModules
                        }
                        
                        self.filteredModules = self.modules
                        
                        // Load terms count for all modules
                        self.loadTermsCountForAllModules()
                        
                        self.delegate?.onDataUpdated()
                        self.updateEmptyState()
                        
                    } else {
                        self.delegate?.onError(response.message)
                        self.updateEmptyState()
                    }
                    
                case .failure(let error):
                    self.delegate?.onError(error.localizedDescription)
                    self.updateEmptyState()
                }
            }
        }
    }
    
    private func fetchCurrentUserId(completion: @escaping (String?) -> Void) {
        NetworkManager.shared.getUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.ok {
                        let userId = response.data.id
                        completion(userId)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    completion(nil)
                }
            }
        }
    }
    
    private func handleModulesLoadingError(_ message: String) {
        isLoading = false
        delegate?.onError(message)
        updateEmptyState()
    }
    
    private func loadTermsCountForAllModules() {
        termsCountCache.removeAll()
        
        for module in modules {
            loadTermsCount(for: module) { [weak self] count in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.termsCountCache[module.id] = count ?? 0
                    self.delegate?.onDataUpdated()
                }
            }
        }
    }
    
    private func loadTermsCount(for module: ModuleResponse, completion: @escaping (Int?) -> Void) {
        NetworkManager.shared.getModuleTerms(moduleId: module.id) { result in
            switch result {
            case .success(let response):
                if response.ok {
                    let termsCount = response.data?.data.count ?? 0
                    completion(termsCount)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    private func updateEmptyState() {
        let (shouldShow, message) = shouldShowEmptyState()
        delegate?.onUpdateEmptyState(shouldShow, message: message)
    }
}

// MARK: - Sort Options
enum SortOption {
    case date
    case titleAscending
    case titleDescending
}
