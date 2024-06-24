//
//  DP_CameraCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit

enum DP_CameraCoordinatorEvent {
    case back
    case detail
}

protocol DP_CameraCoordinatorProtocol: DP_Coordinator {
    var navigationController: UINavigationController? { get set }
    var navigationTabController: UINavigationController? { get set }
    func dp_start()
    func dp_eventOccurred(with type: DP_CameraCoordinatorEvent)
}

class DP_CameraCoordinator: DP_CameraCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    
    var navigationController: UINavigationController?
    var navigationTabController: UINavigationController?
    private var controller: UIViewController?
    
    func dp_start() {
        let vc = DP_CameraViewController()
        vc.coordinator = self
        controller = vc
        navigationTabController?.pushViewController(vc, animated: true)
    }
}

extension DP_CameraCoordinator {
    func dp_eventOccurred(with type: DP_CameraCoordinatorEvent) {
        switch type {
        case .detail:
            break
       
        case .back:
            DP_StartCoordinator.shared.dp_strart()
        }
    }
}

