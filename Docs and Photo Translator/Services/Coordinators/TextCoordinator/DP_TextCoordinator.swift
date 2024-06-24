//
//  DP_TextCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit

enum DP_TextCoordinatorEvent {
    case back
    case detail
}

protocol DP_TextCoordinatorProtocol: DP_Coordinator {
    var navigationController: UINavigationController? { get set }
    var navigationTabController: UINavigationController? { get set }
    func dp_start()
    func dp_eventOccurred(with type: DP_TextCoordinatorEvent)
}

class DP_TextCoordinator: DP_TextCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    
    var navigationController: UINavigationController?
    var navigationTabController: UINavigationController?
    private var controller: UIViewController?
    
    func dp_start() {
        let vc = DP_TextViewController()
        vc.coordinator = self
        controller = vc
        navigationTabController?.pushViewController(vc, animated: true)
    }
}

extension DP_TextCoordinator {
    func dp_eventOccurred(with type: DP_TextCoordinatorEvent) {
        switch type {
        case .detail:
//            var detailCoordinator: SM_MusikLibraryCoordinatorProtocol = SM_MusikLibraryCoordinator()
//            detailCoordinator.navigationController = navigationController
//            cildren.append(detailCoordinator)
//            detailCoordinator.sm_start()
//            detailCoordinator.handlerBback = { [unowned self] in
//                self.sm_eventOccurred(with: .back)
//            }
            break
       
        case .back:
            DP_StartCoordinator.shared.dp_strart()
        }
    }
}
