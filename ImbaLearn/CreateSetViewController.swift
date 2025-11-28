//
//  CreateSetViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 18.11.25.
//

import UIKit

class CreateSetViewController: BaseViewController {
    
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let createButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Create New Set"
        
        titleTextField.placeholder = "Set Title"
        titleTextField.borderStyle = .roundedRect
        
        descriptionTextField.placeholder = "Description (optional)"
        descriptionTextField.borderStyle = .roundedRect
        
        createButton.setTitle("Create Set", for: .normal)
        createButton.backgroundColor = .systemBlue
        createButton.setTitleColor(.white, for: .normal)
        createButton.layer.cornerRadius = 8
        createButton.addTarget(self, action: #selector(createSetTapped), for: .touchUpInside)
        
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(createButton)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        titleTextField.frame = CGRect(x: padding, y: 150,
                                    width: view.frame.width - (padding * 2),
                                    height: 50)
        
        descriptionTextField.frame = CGRect(x: padding, y: 220,
                                          width: view.frame.width - (padding * 2),
                                          height: 50)
        
        createButton.frame = CGRect(x: padding, y: 300,
                                  width: view.frame.width - (padding * 2),
                                  height: 50)
    }
    
    @objc private func createSetTapped() {
        // TODO: Implement set creation logic
        print("Creating set: \(titleTextField.text ?? "")")
    }
}
