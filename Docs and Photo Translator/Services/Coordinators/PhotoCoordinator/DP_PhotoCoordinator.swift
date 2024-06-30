//
//  DP_PhotoCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

enum DP_PhotoCoordinatorEvent {
    case back
    case detail(URL)
}

protocol DP_PhotoCoordinatorProtocol: DP_Coordinator {
    var navigationController: UINavigationController? { get set }
    var navigationTabController: UINavigationController? { get set }
    func dp_start()
    func dp_eventOccurred(with type: DP_PhotoCoordinatorEvent)
}

class DP_PhotoCoordinator: DP_PhotoCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    
    var navigationController: UINavigationController?
    var navigationTabController: UINavigationController?
    private var controller: UIViewController?
    
    func dp_start() {
        let vc = DP_PhotoViewController()
        vc.coordinator = self
        controller = vc
        navigationTabController?.pushViewController(vc, animated: true)
    }
}

extension DP_PhotoCoordinator {
    func dp_eventOccurred(with type: DP_PhotoCoordinatorEvent) {
        switch type {
        case .detail(let model):
            var detailCoordinator: DP_PhotoDetailCoordinatorProtocol = DP_PhotoDetailCoordinator()
            detailCoordinator.navigationController = navigationController
            cildren.append(detailCoordinator)
            detailCoordinator.dp_start(model: model)
            detailCoordinator.handlerBback = { [unowned self] in
                self.dp_eventOccurred(with: .back)
            }
        
        case .back:
            DP_StartCoordinator.shared.dp_strart()
        }
    }
}

