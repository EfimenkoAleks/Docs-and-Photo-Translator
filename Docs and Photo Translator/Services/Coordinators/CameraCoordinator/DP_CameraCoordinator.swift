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
    var eventHandler: Block<(UIImage?)>? { get set }
    var navigationController: UINavigationController? { get set }
    var navigationTabController: UINavigationController? { get set }
    func dp_start()
    func dp_eventOccurred(with type: DP_CameraCoordinatorEvent)
}

class DP_CameraCoordinator: DP_CameraCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    var eventHandler: Block<(UIImage?)>?
    
    var navigationController: UINavigationController?
    var navigationTabController: UINavigationController?
    private var controller: UIViewController?
    private var children: DP_PickerViewController?
    
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
            children = DP_PickerViewController()
            guard let children = children else { return }
//            child.modalPresentationStyle = .automatic
//            child.isModalInPresentation = true
         //   child.preferredContentSize = controller.view.frame.size
            controller.present(children, animated: true)
            children.eventHandlerBack = { [weak self] image in
                self?.eventHandler?(image)
                self?.dp_eventOccurred(with: .removeChild)
            }
            
        case .removeChild:
            guard let children = children else { return }
       //     controller.removeChild()
            children.dismiss(animated: true)
       
        case .back:
            DP_StartCoordinator.shared.dp_strart()
        }
    }
}
