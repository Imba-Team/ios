// CreateSetViewModel.swift

import Foundation

protocol CreateSetViewModelDelegate: AnyObject {
    func onTermsUpdated() -> Void
    func onValidationError(_ message: String) -> Void
    func onModuleCreationStarted() -> Void
    func onModuleCreationSuccess(_ moduleId: String) -> Void
    func onModuleCreationFailure(_ message: String) -> Void
    func onTermsAdditionComplete(numberOfSuccess: Int, errors: [String]) -> Void
}

final class CreateSetViewModel {
    
    // MARK: - Properties
    private(set) var terms: [Term]
    var title: String = ""
    var description: String = ""
    var isPrivate: Bool = false
    
    weak var delegate: CreateSetViewModelDelegate?
    
    // MARK: - Initialization
    init() {
        self.terms = [
            Term(term: "", definition: ""),
            Term(term: "", definition: "")
        ]
    }
    
    // MARK: - Term Management
    func addTerm() {
        terms.append(Term(term: "", definition: ""))
        delegate?.onTermsUpdated()
    }
    
    func deleteTerm(at index: Int) {
        guard index >= 0 && index < terms.count else { return }
        terms.remove(at: index)
        delegate?.onTermsUpdated()
    }
    
    func update(term: String, at index: Int) {
        guard terms.indices.contains(index) else { return }
        terms[index].term = term
    }
    
    func update(definition: String, at index: Int) {
        guard terms.indices.contains(index) else { return }
        terms[index].definition = definition
    }
    
    func getValidTerms() -> [Term] {
        return terms.filter {
            !$0.term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !$0.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    // MARK: - Validation
    func validateForm() -> Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            delegate?.onValidationError("Please enter a title for your module")
            return false
        }
        
        guard !getValidTerms().isEmpty else {
            delegate?.onValidationError("Please add at least one term with both term and definition")
            return false
        }
        
        return true
    }
    
    // MARK: - Module Creation
    func createModule() {
        guard validateForm() else { return }
        
        delegate?.onModuleCreationStarted()
        
        let moduleRequest = CreateModuleRequest(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            isPrivate: isPrivate
        )
        
        print("📦 Step 1: Creating module...")
        
        NetworkManager.shared.createModule(request: moduleRequest) { [weak self] result in
            switch result {
            case .success(let response):
                if response.ok, let moduleId = response.data?.id {
                    print("✅ Module created! ID: \(moduleId)")
                    self?.delegate?.onModuleCreationSuccess(moduleId)
                } else {
                    self?.delegate?.onModuleCreationFailure(response.message)
                }
                
            case .failure(let error):
                self?.handleNetworkError(error)
            }
        }
    }
    
    func addTermsToModule(moduleId: String) {
        let validTerms = getValidTerms()
        print("📦 Step 2: Adding \(validTerms.count) terms to module \(moduleId)...")
        
        let dispatchGroup = DispatchGroup()
        var successfulTerms = 0
        var errors: [String] = []
        
        for (index, term) in validTerms.enumerated() {
            dispatchGroup.enter()
            
            let termRequest = term.toCreateTermRequest(moduleId: moduleId)
            
            NetworkManager.shared.createTerm(request: termRequest) { result in
                switch result {
                case .success(let response):
                    if response.ok {
                        print("✅ Term \(index + 1) added successfully")
                        successfulTerms += 1
                    } else {
                        errors.append("Term \(index + 1): \(response.message)")
                    }
                case .failure(let error):
                    errors.append("Term \(index + 1): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.delegate?.onTermsAdditionComplete(numberOfSuccess: successfulTerms, errors: errors)
        }
    }
    
    // MARK: - Form Reset
    func resetForm() {
        title = ""
        description = ""
        isPrivate = false
        terms = [
            Term(term: "", definition: ""),
            Term(term: "", definition: "")
        ]
        delegate?.onTermsUpdated()
    }
    
    // MARK: - Private Methods
    private func handleNetworkError(_ error: NetworkError) {
        let errorMessage: String
        switch error {
        case .unauthorized:
            errorMessage = "Session expired. Please login again."
        case .noData, .decodingError:
            errorMessage = "Server error. Please try again."
        case .networkError:
            errorMessage = "Network connection error. Please check your internet."
        default:
            errorMessage = error.localizedDescription
        }
        delegate?.onModuleCreationFailure(errorMessage)
    }
    
    // MARK: - Helper Properties
    var tableViewHeight: CGFloat {
        return CGFloat(terms.count) * 120
    }
    
    var canAddMoreTerms: Bool {
        return true
    }
}
