//
//  DP_TabBarController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

typealias DP_TabBarControllerExtension = DP_TabBarController

class DP_TabBarController: DP_BaseViewController {
    
    var selectedTab: DP_TabBarSelectedItem?
    var coordinator: DP_StartCoordinatorProtocol?
    var tabBarItemTypes: [DP_TabBarItemType] {
        return []
    }
    
    var availableTabBarItemTypes: [DP_TabBarItemType] {
        return [.photo, .camera, .text]
    }
    private var embedTabBar: SM_CustomTabBar = SM_CustomTabBar()
    private var embedViewControllers: [DP_TabBarItemType: UINavigationController] = [:]
    private var curentSelectedItemType: DP_TabBarItemType?
    private var curentTabBarItem: UITabBarItem?
    
    // MARK: Life cycle
    
    init(coordinator: DP_StartCoordinatorProtocol, selectedTab:  DP_TabBarSelectedItem?) {
        self.selectedTab = selectedTab
        self.coordinator = coordinator
        super.init()
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dp_initialSetup()
    }
    
    // MARK: Publik func
    
    func setSelectedTab() {
        guard let selectedTab = selectedTab else { return }
        embedTabBar.selectedItem = embedTabBar.items?[selectedTab.selected]
        dp_updateSelectedViewController()
    }
}

// MARK: Private

private extension DP_TabBarControllerExtension {
    
     func dp_initialSetup() {
        
        embedTabBar.delegate = self
        embedTabBar.barTintColor = DP_Colors.tabBar.color
        availableTabBarItemTypes.forEach({embedViewControllers[$0] = dp_childViewControllers(itemForVC: $0)})
        embedTabBar.tabAppearance = { [weak self] _ in
            self?.dp_updateSelectedViewController()
        }
        embedTabBar.items = availableTabBarItemTypes.map { $0.item }
        embedTabBar.isTranslucent = false
        view.backgroundColor = .white
        view.addSubview(embedTabBar)
        embedTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: embedTabBar.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: embedTabBar.trailingAnchor),
            self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: embedTabBar.bottomAnchor)
        ])
         guard let selectedTab = selectedTab else { return }
         embedTabBar.selectedItem = embedTabBar.items?[selectedTab.selected]
        dp_updateSelectedViewController()
        embedTabBar.didTapButton = { [unowned self] _ in
                    self.dp_selectDevice()
                }
    }
   
    private func dp_selectDevice() {
        
        DP_StartCoordinator.shared.dp_startFlov(controller: DP_PhotoViewController())
        
        dp_updateSelectedViewController()
    }
    
    // MARK: Child viewControllers
    
    func dp_childViewControllers(itemForVC: DP_TabBarItemType) -> UINavigationController {
        
        switch itemForVC {
        case .photo:
            var firstCoordinator: DP_PhotoCoordinatorProtocol = DP_PhotoCoordinator()
            let navController = UINavigationController()
            firstCoordinator.navigationTabController = navController
            firstCoordinator.navigationController = self.coordinator?.navigationController
            firstCoordinator.dp_start(color: .systemMint)
            navController.tabBarItem = itemForVC.item
            return navController
        case .camera:
            var firstCoordinator: DP_PhotoCoordinatorProtocol = DP_PhotoCoordinator()
            let navController = UINavigationController()
            firstCoordinator.navigationTabController = navController
            firstCoordinator.navigationController = self.coordinator?.navigationController
            firstCoordinator.dp_start(color: .yellow)
            navController.tabBarItem = itemForVC.item
            return navController
        case .text:
            var firstCoordinator: DP_PhotoCoordinatorProtocol = DP_PhotoCoordinator()
            let navController = UINavigationController()
            firstCoordinator.navigationTabController = navController
            firstCoordinator.navigationController = self.coordinator?.navigationController
            firstCoordinator.dp_start(color: .systemRed)
            navController.tabBarItem = itemForVC.item
            return navController
        }
    }
    
    func dp_updateSelectedViewController() {
        guard let item = embedTabBar.selectedItem,
              let itemType = DP_TabBarItemType(rawValue: item.tag) else { return }
        
        if let item: DP_TabBarItemType = curentSelectedItemType,
           let vc: UIViewController = embedViewControllers[item] {
            vc.willMove(toParent: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParent()
        }
        if itemType == curentSelectedItemType,
           let selectedVC: UINavigationController = embedViewControllers[itemType],
           selectedVC.viewControllers.count > 1 {
            selectedVC.popViewController(animated: true)
        }
        curentSelectedItemType = itemType
        curentTabBarItem = embedTabBar.selectedItem
        if let selectedVC: UIViewController = embedViewControllers[itemType] {
            selectedVC.additionalSafeAreaInsets.bottom = embedTabBar.bounds.height
            addChild(selectedVC)
            selectedVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            selectedVC.view.frame = view.bounds
            view.addSubview(selectedVC.view)
            selectedVC.didMove(toParent: self)
        }
        view.bringSubviewToFront(embedTabBar)
    }
}

// MARK: UITabBarDelegate

extension DP_TabBarControllerExtension: UITabBarDelegate {
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       
        if item.title != DP_TabBarItemType.camera.item.title {
            dp_updateSelectedViewController()
        }
        
        switch item.tag {
                     case 0:
            DP_StartCoordinator.shared.selectedTab = DP_TabBarSelectedItem.photo
                     case 1:
            DP_StartCoordinator.shared.selectedTab = DP_TabBarSelectedItem.text
        default:
            break
        }
    }
}
