//
//  DP_StartCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

enum DP_StartCoordinatorEvent {
    case back
}

protocol DP_StartCoordinatorProtocol: DP_Coordinator {
    func dp_strart()
    func dp_startFlov(controller: UIViewController)
    func dp_eventOccurred(with type: DP_StartCoordinatorEvent)
}

class DP_StartCoordinator: DP_StartCoordinatorProtocol {
    
    static let shared: DP_StartCoordinator = DP_StartCoordinator()

    var cildren: [DP_Coordinator] = []
    var navigationController: UINavigationController?
    var window: UIWindow?
    var selectedTab: DP_TabBarSelectedItem = .photo
    private var controller: UIViewController?
    
    func dp_strart() {
        navigationController = UINavigationController()
        let vc = DP_TabBarController(coordinator: self, selectedTab: selectedTab)
        vc.setSelectedTab()
        window?.rootViewController = vc
    }

    func dp_startFlov(controller: UIViewController) {
        self.controller = controller
        controller.view.backgroundColor = .systemPink
        navigationController = UINavigationController(rootViewController: controller)
        guard let navigationController = navigationController else {return}
        window?.rootViewController = navigationController
    }
}

extension DP_StartCoordinator {
    func dp_eventOccurred(with type: DP_StartCoordinatorEvent) {
        switch type {
            
        case .back:
            guard let controller = controller else { return }
            navigationController?.popToViewController(controller, animated: true)
            cildren.removeLast()
        }
    }
}

