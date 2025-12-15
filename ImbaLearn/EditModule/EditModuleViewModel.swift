//
//  EditModuleViewModel.swift
//  ImbaLearn
//

import Foundation
import UIKit

protocol EditModuleViewModelDelegate: AnyObject {
    func showValidationAlert(errors: [String])
    func showError(message: String)
    func showSuccessAndDismiss()
    func updateLoadingState(isLoading: Bool)
    func reloadTableView()
    func updateSaveButtonState(isEnabled: Bool)
}

class EditModuleViewModel {
    
    // MARK: - Properties
    var module: ModuleResponse!
    var originalModule: ModuleResponse!
    var terms: [TermResponse] = []
    var onModuleUpdated: ((ModuleResponse) -> Void)?
    var onTermsUpdated: (([TermResponse]) -> Void)?
    
    private(set) var editedTerms: [TermResponse] = []
    private(set) var deletedTermIds: Set<String> = []
    private(set) var newTerms: [Term] = []
    private(set) var hasChanges = false
    
    weak var delegate: EditModuleViewModelDelegate?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Data Loading
    func loadData() {
        // Create deep copies
        originalModule = module
        editedTerms = terms.map { $0 } // Create a copy
    }
    
    // MARK: - Module Data Management
    func updateModuleData(title: String?, description: String?, isPrivate: Bool) {
        // Update hasChanges based on module changes
        let moduleChanged = title != originalModule.title ||
                           description != originalModule.description ||
                           isPrivate != originalModule.isPrivate
        
        // Check if there are new valid terms (non-empty)
        let hasNewValidTerms = !newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }.isEmpty
        
        // Check if any terms were deleted
        let hasDeletedTerms = !deletedTermIds.isEmpty
        
        // Check if any existing terms were modified (excluding empty ones)
        var termsModified = false
        for (index, editedTerm) in editedTerms.enumerated() {
            if index < terms.count {
                let originalTerm = terms[index]
                
                // Skip if both term and definition are empty (should be deleted)
                let termText = editedTerm.term.trimmingCharacters(in: .whitespacesAndNewlines)
                let definitionText = editedTerm.definition.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if termText.isEmpty && definitionText.isEmpty {
                    continue
                }
                
                if editedTerm.term != originalTerm.term ||
                   editedTerm.definition != originalTerm.definition ||
                   editedTerm.isStarred != originalTerm.isStarred {
                    termsModified = true
                    break
                }
            }
        }
        
        hasChanges = moduleChanged || hasNewValidTerms || hasDeletedTerms || termsModified
        delegate?.updateSaveButtonState(isEnabled: true)
    }
    
    // MARK: - Term Management
    func addNewTerm() -> IndexPath {
        let newTerm = Term(term: "", definition: "", isStarred: false)
        newTerms.append(newTerm)
        updateHasChanges()
        return IndexPath(row: editedTerms.count + newTerms.count - 1, section: 0)
    }
    
    func updateTerm(at indexPath: IndexPath, term: String, definition: String) {
        if indexPath.row < editedTerms.count {
            // Update existing term
            editedTerms[indexPath.row].term = term
            editedTerms[indexPath.row].definition = definition
        } else {
            // Update new term
            let newTermIndex = indexPath.row - editedTerms.count
            newTerms[newTermIndex].term = term
            newTerms[newTermIndex].definition = definition
        }
        updateHasChanges()
    }
    
    func deleteTerm(at indexPath: IndexPath) {
        if indexPath.row < editedTerms.count {
            // Mark existing term for deletion
            let term = editedTerms[indexPath.row]
            deletedTermIds.insert(term.id)
            editedTerms.remove(at: indexPath.row)
        } else {
            // Remove new term
            let newTermIndex = indexPath.row - editedTerms.count
            newTerms.remove(at: newTermIndex)
        }
        updateHasChanges()
        delegate?.reloadTableView()
    }
    
    func getTerm(at indexPath: IndexPath) -> Any {
        if indexPath.row < editedTerms.count {
            return editedTerms[indexPath.row]
        } else {
            let newTermIndex = indexPath.row - editedTerms.count
            return newTerms[newTermIndex]
        }
    }
    
    func isNewTerm(at indexPath: IndexPath) -> Bool {
        return indexPath.row >= editedTerms.count
    }
    
    func numberOfTerms() -> Int {
        return editedTerms.count + newTerms.count
    }
    
    private func updateHasChanges() {
        // Update hasChanges flag (called from various update methods)
        delegate?.updateSaveButtonState(isEnabled: true)
    }
    
    // MARK: - Validation
    func validateAllInputs(title: String?, description: String?) -> Bool {
        var validationErrors: [String] = []
        
        // Validate module title
        let titleText = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if titleText.isEmpty {
            validationErrors.append("• Module title is required")
        }
        
        // Validate existing terms
        for (index, term) in editedTerms.enumerated() {
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if termText.isEmpty && definitionText.isEmpty {
                // Both empty - this term should be deleted, skip it
                continue
            } else if termText.isEmpty {
                validationErrors.append("• Term at position \(index + 1) is missing a term")
            } else if definitionText.isEmpty {
                validationErrors.append("• Definition for '\(termText)' is missing")
            }
        }
        
        // Validate new terms
        for (index, term) in newTerms.enumerated() {
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip completely empty terms
            if termText.isEmpty && definitionText.isEmpty {
                continue
            }
            
            // Check partial empty
            if termText.isEmpty {
                validationErrors.append("• New term at position \(index + 1) is missing a term")
            } else if definitionText.isEmpty {
                validationErrors.append("• Definition for new term '\(termText)' is missing")
            }
        }
        
        // Check if we have any valid terms after validation
        let validEditedTerms = editedTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        let validNewTerms = newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        let hasValidTerms = !validEditedTerms.isEmpty || !validNewTerms.isEmpty
        
        // Only require terms if module originally had terms or if user tried to add terms
        let userTriedToAddTerms = !newTerms.filter({
            !$0.term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !$0.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }).isEmpty
        
        if !hasValidTerms && (!terms.isEmpty || userTriedToAddTerms) {
            validationErrors.append("• Module must have at least one complete term")
        }
        
        // If there are validation errors, show them and return false
        if !validationErrors.isEmpty {
            delegate?.showValidationAlert(errors: validationErrors)
            return false
        }
        
        return true
    }
    
    // MARK: - Save Operations
    func saveChanges(title: String?, description: String?, isPrivate: Bool, completion: @escaping (Bool) -> Void) {
        guard validateAllInputs(title: title, description: description) else {
            completion(false)
            return
        }
        
        delegate?.updateLoadingState(isLoading: true)
        
        saveModuleChanges(title: title, description: description, isPrivate: isPrivate) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.saveTermChanges { success in
                    DispatchQueue.main.async {
                        self.delegate?.updateLoadingState(isLoading: false)
                        
                        if success {
                            self.updateLocalDataAndDismiss(title: title, description: description, isPrivate: isPrivate)
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.updateLoadingState(isLoading: false)
                    completion(false)
                }
            }
        }
    }
    
    private func saveModuleChanges(title: String?, description: String?, isPrivate: Bool, completion: @escaping (Bool) -> Void) {
        let titleText = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Check if module actually changed
        if titleText == originalModule.title &&
           descriptionText == originalModule.description &&
           isPrivate == originalModule.isPrivate {
            completion(true)
            return
        }
        
        let request = UpdateModuleRequest(
            title: titleText,
            description: descriptionText.isEmpty ? nil : descriptionText,
            isPrivate: isPrivate
        )
        
        NetworkManager.shared.updateModule(moduleId: module.id, request: request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.ok {
                        print("✅ Module updated successfully")
                        completion(true)
                    } else {
                        self?.delegate?.showError(message: response.message)
                        completion(false)
                    }
                case .failure(let error):
                    self?.delegate?.showError(message: error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    private func saveTermChanges(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var hasError = false
        
        // Filter valid edited terms
        let validEditedTerms = editedTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        // Filter valid new terms
        let validNewTerms = newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        // Update existing terms
        for editedTerm in validEditedTerms {
            // Find the original term to check if it was modified
            if let originalTerm = terms.first(where: { $0.id == editedTerm.id }) {
                // Check if term was modified
                if editedTerm.term != originalTerm.term ||
                   editedTerm.definition != originalTerm.definition ||
                   editedTerm.isStarred != originalTerm.isStarred {
                    
                    group.enter()
                    let request = UpdateTermRequest(
                        term: editedTerm.term,
                        definition: editedTerm.definition,
                        isStarred: editedTerm.isStarred
                    )
                    
                    NetworkManager.shared.updateTerm(termId: editedTerm.id, request: request) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let response):
                                if response.ok {
                                    print("✅ Term updated: \(editedTerm.term)")
                                } else {
                                    print("❌ Failed to update term: \(response.message)")
                                    hasError = true
                                }
                            case .failure(let error):
                                print("❌ Failed to update term: \(error)")
                                hasError = true
                            }
                            group.leave()
                        }
                    }
                }
            }
        }
        
        // Delete removed terms
        for termId in deletedTermIds {
            group.enter()
            NetworkManager.shared.deleteTerm(termId: termId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.ok {
                            print("✅ Term deleted: \(termId)")
                        } else {
                            print("❌ Failed to delete term: \(response.message)")
                            hasError = true
                        }
                    case .failure(let error):
                        print("❌ Failed to delete term: \(error)")
                        hasError = true
                    }
                    group.leave()
                }
            }
        }
        
        // Create new terms (only valid ones)
        for newTerm in validNewTerms {
            let termText = newTerm.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = newTerm.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            
            group.enter()
            let request = CreateTermRequest(
                moduleId: module.id,
                term: termText,
                definition: definitionText,
                isStarred: newTerm.isStarred
            )
            
            NetworkManager.shared.createTerm(request: request) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        if response.ok {
                            print("✅ New term created: \(termText)")
                        } else {
                            print("❌ Failed to create term: \(response.message)")
                            hasError = true
                        }
                    case .failure(let error):
                        print("❌ Failed to create term: \(error)")
                        hasError = true
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(!hasError)
        }
    }
    
    private func updateLocalDataAndDismiss(title: String?, description: String?, isPrivate: Bool) {
        // Get validated data
        let titleText = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Filter out empty terms
        let validEditedTerms = editedTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        let validNewTerms = newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }
        
        // Update the module with new data
        var updatedModule = module
        updatedModule?.title = titleText
        updatedModule?.description = descriptionText.isEmpty ? nil : descriptionText
        updatedModule?.isPrivate = isPrivate
        
        // Combine existing terms with new terms (only valid ones)
        let updatedTerms = validEditedTerms + validNewTerms.map { term in
            // Convert local Term to TermResponse
            return TermResponse(
                id: UUID().uuidString, // Temporary ID for new terms
                term: term.term,
                status: "not_started",
                definition: term.definition,
                isStarred: term.isStarred,
                createdAt: nil,
                updatedAt: nil,
                moduleId: module.id
            )
        }
        
        // Call callbacks
        onModuleUpdated?(updatedModule!)
        onTermsUpdated?(updatedTerms)
        
        // Show success and dismiss
        delegate?.showSuccessAndDismiss()
    }
    
    func hasUnsavedChanges(title: String?, description: String?, isPrivate: Bool) -> Bool {
        // Check module changes
        let moduleChanged = title != originalModule.title ||
                           description != originalModule.description ||
                           isPrivate != originalModule.isPrivate
        
        // Check if there are new valid terms (non-empty)
        let hasNewValidTerms = !newTerms.filter { term in
            let termText = term.term.trimmingCharacters(in: .whitespacesAndNewlines)
            let definitionText = term.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            return !termText.isEmpty && !definitionText.isEmpty
        }.isEmpty
        
        // Check if any terms were deleted
        let hasDeletedTerms = !deletedTermIds.isEmpty
        
        // Check if any existing terms were modified (excluding empty ones)
        var termsModified = false
        for (index, editedTerm) in editedTerms.enumerated() {
            if index < terms.count {
                let originalTerm = terms[index]
                
                // Skip if both term and definition are empty (should be deleted)
                let termText = editedTerm.term.trimmingCharacters(in: .whitespacesAndNewlines)
                let definitionText = editedTerm.definition.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if termText.isEmpty && definitionText.isEmpty {
                    continue
                }
                
                if editedTerm.term != originalTerm.term ||
                   editedTerm.definition != originalTerm.definition ||
                   editedTerm.isStarred != originalTerm.isStarred {
                    termsModified = true
                    break
                }
            }
        }
        
        return moduleChanged || hasNewValidTerms || hasDeletedTerms || termsModified
    }
}
