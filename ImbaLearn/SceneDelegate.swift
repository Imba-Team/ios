//
//
//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = CardsModeViewController()
//        window?.makeKeyAndVisible()
//    }
//
//    
//
//}

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if user is logged in (you'll replace this with actual auth check)
        let isLoggedIn = false // Change this based on your auth state
        
        if isLoggedIn {
            showMainApp()
        } else {
            showAuthentication()
        }
        
        window?.makeKeyAndVisible()
    }
    
    func showAuthentication() {
        let loginVC = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = navController
    }
    
    func showMainApp() {
        let tabBarController = UITabBarController()
        
        // Create view controllers for each tab
        let homeVC = HomeViewController()
        let createSetVC = CreateSetViewController()
        let libraryVC = LibraryViewController()
        let accountVC = AccountViewController()
        
        // Configure tab bar items
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        createSetVC.tabBarItem = UITabBarItem(title: "Create", image: UIImage(systemName: "plus.circle"), tag: 1)
        libraryVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical"), tag: 2)
        accountVC.tabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person"), tag: 3)
        
        // Set up tab bar controller
        tabBarController.viewControllers = [homeVC, createSetVC, libraryVC, accountVC]
        tabBarController.selectedIndex = 0
        
        window?.rootViewController = tabBarController
    }
}
