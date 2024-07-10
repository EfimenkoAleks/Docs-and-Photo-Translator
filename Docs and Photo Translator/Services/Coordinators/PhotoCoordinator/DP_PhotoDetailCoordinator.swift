//
//  DP_PhotoDetailCoordinator.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 27.06.2024.
//

import UIKit

enum DP_PhotoDetailCoordinatorEvent {
    case back
    case choise
    case removeChild
    case share(UIImage?)
}

protocol DP_PhotoDetailCoordinatorProtocol: DP_Coordinator {
    var eventHandler: Block<()>? { get set }
    var handlerBback: (() -> Void)? { get set }
    func dp_start(model: URL)
    func dp_eventOccurred(with type: DP_PhotoDetailCoordinatorEvent)
}

class DP_PhotoDetailCoordinator: DP_PhotoDetailCoordinatorProtocol {
    var cildren: [DP_Coordinator] = []
    var eventHandler: Block<()>?
    
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
        case .share(let image):
            guard let image = image,
            let controller = controller else { return }
            
                let imageShare = [ image ]
                let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = controller.view
            controller.present(activityViewController, animated: true, completion: nil)
            
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



