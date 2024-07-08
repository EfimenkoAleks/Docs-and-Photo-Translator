//
//  DP_CameraCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit

enum DP_CameraCoordinatorEvent {
    case back
    case choise
    case removeChild
}

protocol DP_CameraCoordinatorProtocol: DP_Coordinator {
    var eventHandler: Block<()>? { get set }
    var navigationController: UINavigationController? { get set }
    var navigationTabController: UINavigationController? { get set }
    func dp_start()
    func dp_eventOccurred(with type: DP_CameraCoordinatorEvent)
}

class DP_CameraCoordinator: DP_CameraCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    var eventHandler: Block<()>?
    
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
        case .choise:
            guard let controller = controller else { return }
            let child = DP_ChoiceLanguageViewController(isSetCurrent: false)
            child.modalPresentationStyle = .fullScreen
            child.isModalInPresentation = true
            child.preferredContentSize = controller.view.frame.size
            controller.present(child, animated: true)
            child.eventHandlerBack = { [weak self] _ in
                self?.dp_eventOccurred(with: .removeChild)
                self?.eventHandler?(())
            }
            
        case .removeChild:
            guard let controller = controller else { return }
            controller.removeChild()
       
        case .back:
            DP_StartCoordinator.shared.dp_strart()
        }
    }
}
