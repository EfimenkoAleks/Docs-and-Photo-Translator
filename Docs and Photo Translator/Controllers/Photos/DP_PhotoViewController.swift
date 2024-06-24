//
//  DP_PhotoViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import UIKit

typealias DP_PhotoViewControllerExtension = DP_PhotoViewController

class DP_PhotoViewController: DP_BaseViewController {
    
    var coordinator: DP_PhotoCoordinatorProtocol?

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.view.backgroundColor = .systemRed
        }
    }
}
