import Foundation

class HomeViewModel {
    
    // MARK: - Properties
    private(set) var continueLearningSets: [ModuleResponse] = []
    private(set) var allModules: [ModuleResponse] = []
    private(set) var isLoading = false
    private var termsCountCache: [String: Int] = [:] // Cache for terms count
    
    // MARK: - Callbacks
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onNavigateToModuleDetail: ((ModuleResponse) -> Void)?
    
    // MARK: - Data Methods
    func loadModules() {
        guard !isLoading else { return }
        
        isLoading = true
        
        NetworkManager.shared.getUserModules { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.ok {
                        self.processModules(response.data ?? [])
                    } else {
                        self.onError?(response.message)
                    }
                    
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    private func processModules(_ modules: [ModuleResponse]) {
        // Clear previous cache
        termsCountCache.removeAll()
        
        // All modules
        allModules = modules
        
        // For Continue Learning, show modules that are started (has progress > 0)
        if modules.isEmpty {
            continueLearningSets = []
        } else {
            let modulesStarted = modules.filter { ($0.progress?.completed ?? 0) > 0 }
            
            if !modulesStarted.isEmpty {
                continueLearningSets = modulesStarted
            } else {
                let randomModules = modules.shuffled().prefix(3)
                continueLearningSets = Array(randomModules)
            }
        }
        
        // Load terms count for all modules (similar to Library)
        loadTermsCountForAllModules()
    }
    
    private func loadTermsCountForAllModules() {
        // Load terms count for each module
        for module in allModules {
            loadTermsCount(for: module) { [weak self] count in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    // Cache the result
                    self.termsCountCache[module.id] = count ?? 0
                    
                    // Notify that data is updated
                    self.onDataUpdated?()
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
    
    // Get terms count for a module
    func getTermsCount(for moduleId: String) -> Int {
        return termsCountCache[moduleId] ?? 0
    }
    
    // MARK: - Navigation Methods
    func navigateToModuleDetail(with module: ModuleResponse) {
        onNavigateToModuleDetail?(module)
    }
    
    func getModuleForSection(_ section: Int) -> ModuleResponse? {
        let hasContinueLearning = !continueLearningSets.isEmpty
        let moduleIndex: Int
        
        if hasContinueLearning {
            moduleIndex = section - 1
        } else {
            moduleIndex = section
        }
        
        if moduleIndex >= 0 && moduleIndex < allModules.count {
            return allModules[moduleIndex]
        }
        return nil
    }
    
    // MARK: - Section Calculations
    func numberOfSections() -> Int {
        let hasContinueLearning = !continueLearningSets.isEmpty
        return (hasContinueLearning ? 1 : 0) + allModules.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        let hasContinueLearning = !continueLearningSets.isEmpty
        
        if hasContinueLearning && section == 0 {
            // Continue Learning section - always 1 row (the collection view cell)
            return 1
        } else {
            // All Modules sections - each module gets its own section with 1 row
            return 1
        }
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let hasContinueLearning = !continueLearningSets.isEmpty
        
        if hasContinueLearning && indexPath.section == 0 {
            return continueLearningSets.isEmpty ? 0 : 260
        } else {
            return 90 // Height for each module cell
        }
    }
    
    func titleForHeader(in section: Int) -> String {
        let hasContinueLearning = !continueLearningSets.isEmpty
        
        if hasContinueLearning {
            if section == 0 {
                return "Continue Learning"
            } else if section == 1 {
                return "All Modules"
            } else {
                return ""
            }
        } else {
            if section == 0 {
                return "All Modules"
            } else {
                return ""
            }
        }
    }
    
    func heightForHeader(in section: Int) -> CGFloat {
        let hasContinueLearning = !continueLearningSets.isEmpty
        
        if hasContinueLearning {
            if section == 0 {
                return continueLearningSets.isEmpty ? 0 : 60
            } else if section == 1 {
                return 60 // Height for "All Modules" header
            } else {
                return 2 // SPACE BETWEEN CELLS
            }
        } else {
            if section == 0 {
                return 60 // Height for "All Modules" header
            } else {
                return 2 // SPACE BETWEEN CELLS
            }
        }
    }
    
    func shouldHandleTap(at indexPath: IndexPath) -> Bool {
        let hasContinueLearning = !continueLearningSets.isEmpty
        // Don't handle taps on Continue Learning section (it has its own button)
        return !(hasContinueLearning && indexPath.section == 0)
    }
    
    func handleCellSelection(at indexPath: IndexPath) {
        guard shouldHandleTap(at: indexPath) else { return }
        
        if let module = getModuleForSection(indexPath.section) {
            print("Selected module: \(module.title)")
            navigateToModuleDetail(with: module)
        }
    }
    
    func handleContinueButtonTap(at index: Int) {
        guard index < continueLearningSets.count else { return }
        let module = continueLearningSets[index]
        print("Continue button tapped for: \(module.title)")
        navigateToModuleDetail(with: module)
    }
}
