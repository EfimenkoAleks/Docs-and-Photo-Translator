//
//  DP_PhotoViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

typealias DP_PhotoViewControllerExtension = DP_PhotoViewController

class DP_PhotoViewController: DP_BaseViewController {
    
    @IBOutlet private weak var photoTableView: UITableView!

    var coordinator: DP_PhotoCoordinatorProtocol?
    private var photoManager: DP_PhotoTableManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
      super.viewWillAppear(animated)
    }
}

private extension DP_PhotoViewControllerExtension {
    
    func dp_configUI() {
        dp_createManager()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.coordinator?.dp_eventOccurred(with: .choiceLanguage)
            self.coordinator?.eventHandler = { [weak self] _ in
                guard let self = self else { return }
                self.photoManager?.dp_reloadTable()
            }
        }
    }
    
    func dp_createManager() {
        photoManager = DP_PhotoTableManager(photoTableView)
        photoManager?.eventHandler = { [weak self] url in
            self?.coordinator?.dp_eventOccurred(with: .detail(url))
        }
    }
}
