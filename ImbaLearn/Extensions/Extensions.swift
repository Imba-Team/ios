//
//  Untitled.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 19.11.25.
//

import UIKit

// MARK: - UIView Extension
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

extension UITextField {
    func applyShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false
    }
}
