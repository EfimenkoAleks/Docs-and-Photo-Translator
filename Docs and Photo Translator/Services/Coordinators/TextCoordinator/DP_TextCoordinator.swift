//
//  DP_TextCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit

enum DP_TextCoordinatorEvent {
    case back
    case share(String?)
    case choiceLanguage
    case removeChild
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
        case .share(let str):
            guard let text = str, text != "",
            let controller = controller else { return }
                let textShare = [ text ]
                let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = controller.view
            controller.present(activityViewController, animated: true, completion: nil)

        case .choiceLanguage:
            guard let controller = controller else { return }
            let child = DP_ChoiceLanguageViewController(isSetCurrent: true)
            child.modalPresentationStyle = .fullScreen
            child.isModalInPresentation = true
            child.preferredContentSize = controller.view.frame.size
            controller.present(child, animated: true)
            child.eventHandlerBack = { [weak self] _ in
                self?.dp_eventOccurred(with: .removeChild)
            }
            
        case .removeChild:
            guard let controller = controller else { return }
            controller.removeChild()
       
        case .back:
            DP_StartCoordinator.shared.dp_strart()
        }
    }
}
