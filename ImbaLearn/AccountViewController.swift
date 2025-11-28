//
//  FlashcardsViewController.swift
//  ImbaLearn
//
//  Created by Leyla Aliyeva on 17.11.25.
//

import UIKit

class AccountViewController: UIViewController {
    
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Account"
        
        nameLabel.text = "John Doe" // Replace with actual user data
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        
        emailLabel.text = "john@example.com" // Replace with actual user data
        emailLabel.textAlignment = .center
        emailLabel.textColor = .gray
        
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        let padding: CGFloat = 20
        
        nameLabel.frame = CGRect(x: padding, y: 200,
                               width: view.frame.width - (padding * 2),
                               height: 30)
        
        emailLabel.frame = CGRect(x: padding, y: 240,
                                width: view.frame.width - (padding * 2),
                                height: 30)
        
        logoutButton.frame = CGRect(x: padding, y: 300,
                                  width: view.frame.width - (padding * 2),
                                  height: 50)
    }
    
    @objc private func logoutTapped() {
        // TODO: Implement logout logic
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showAuthentication()
        }
    }
}
