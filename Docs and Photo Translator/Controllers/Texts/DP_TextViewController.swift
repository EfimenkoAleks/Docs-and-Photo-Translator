//
//  DP_TextViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit

typealias DP_TextViewControllerExtension = DP_TextViewController

class DP_TextViewController: DP_BaseViewController {
    
    var coordinator: DP_TextCoordinatorProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
      super.viewWillAppear(animated)
    }
}

private extension DP_TextViewControllerExtension {
    
    func dp_configUI() {
        view.backgroundColor = .systemMint
    }
}
