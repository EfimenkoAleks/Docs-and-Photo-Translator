//
//  DP_TabCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

enum DP_TabCoordinatorEvent {
    case detail
    case back
}

protocol DP_TabCoordinatorProtocol: Coordinator {
    func dp_strart()
    func dp_eventOccurred(with type: DP_TabCoordinatorEvent)
}

class DP_TabCoordinator: DP_TabCoordinatorProtocol {
    
    init(with window: UIWindow?) {
        self.window = window
        
        dp_strart()
    }
    
    var cildren: [Coordinator] = []
    var navigationController: UINavigationController?
    private var window: UIWindow?
    
    func dp_strart() {
        navigationController = UINavigationController()
        let vc = UIViewController() // tab
  //      vc.setSelectedTab()
        window?.rootViewController = vc
    }
}

extension DP_TabCoordinator {
    
    func dp_eventOccurred(with type: DP_TabCoordinatorEvent) {
        switch type {
        case .detail:
            break
            
        case .back:
            break
        }
    }
}
