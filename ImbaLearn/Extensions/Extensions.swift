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
