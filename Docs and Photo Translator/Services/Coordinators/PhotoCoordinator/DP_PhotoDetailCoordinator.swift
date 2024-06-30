//
//  DP_PhotoDetailCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 27.06.2024.
//

import UIKit

enum DP_PhotoDetailCoordinatorEvent {
    case detail
    case back
}

protocol DP_PhotoDetailCoordinatorProtocol: DP_Coordinator {
    var handlerBback: (() -> Void)? { get set }
    func dp_start(model: URL)
    func dp_eventOccurred(with type: DP_PhotoDetailCoordinatorEvent)
}

class DP_PhotoDetailCoordinator: DP_PhotoDetailCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    
    var navigationController: UINavigationController?
    var handlerBback: (() -> Void)?
    private var controller: UIViewController?
    
    func dp_start(model: URL) {
        let vc = DP_PhotoDetailViewController(model: model)
        controller = vc
        vc.coordinator = self
        DP_StartCoordinator.shared.dp_startFlov(controller: vc)
  //      navigationController?.pushViewController(vc, animated: true)
    }
}

extension DP_PhotoDetailCoordinator {
    func dp_eventOccurred(with type: DP_PhotoDetailCoordinatorEvent) {
        switch type {
        case .detail:
           break
            
        case .back:
            break
//            guard let controller = controller else { return }
//            navigationController?.popToViewController(controller, animated: true)
//            cildren.removeLast()
        }
    }
}



