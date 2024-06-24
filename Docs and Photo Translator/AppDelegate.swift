//
//  AppDelegate.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 18.06.2024.
//

import UIKit

typealias SM_AppDelegateExtension = AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        setupRootViewController()
        
        return true
    }
}

private extension SM_AppDelegateExtension {
    func setupRootViewController() {
        
        guard let window = window else { return }
        
        DP_StartCoordinator.shared.window = window
        DP_StartCoordinator.shared.dp_strart()
        
        window.makeKeyAndVisible()
    }
}
