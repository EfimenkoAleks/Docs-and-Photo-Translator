//
//  AppDelegate.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 18.06.2024.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        _ = DP_TabCoordinator(with: window)
        
        return true
    }
}
