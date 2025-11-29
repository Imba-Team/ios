//
//  BaseViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 28.11.25.
//

// BaseViewController.swift
import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Keyboard Handling
    private var scrollView: UIScrollView?
    private var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        setupTapGesture()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    // Call this method in your child view controllers to enable keyboard avoidance
    func setupKeyboardAvoidance(with scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let scrollView = scrollView,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let activeField = activeField else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 20, right: 0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Scroll to make the active field visible
        var visibleRect = activeField.convert(activeField.bounds, to: scrollView)
        visibleRect = visibleRect.insetBy(dx: 0, dy: -20) // Add some padding
        
        scrollView.scrollRectToVisible(visibleRect, animated: true)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let scrollView = scrollView else { return }
        
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

// UITextFieldDelegate extension to track active field
extension BaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
