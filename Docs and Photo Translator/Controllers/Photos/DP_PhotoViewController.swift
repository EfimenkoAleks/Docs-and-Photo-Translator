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
    private var helper: DP_PhotoHelper = DP_PhotoHelper()
    private var segment: UISegmentedControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
      super.viewWillAppear(animated)
    }
    
    override func dp_choiseLang() {
        coordinator?.dp_eventOccurred(with: .choiceLanguage)
        coordinator?.eventHandler = { [weak self] _ in
            guard let self = self else { return }
            self.photoManager?.dp_reloadTable()
        }
    }
    
    override func dp_privacyPolicy() {
        guard let url = URL(string: "https://www.freeprivacypolicy.com/live/e86d37e0-acc5-43f9-af98-81d91a81e17d") else { return }
        coordinator?.dp_eventOccurred(with: .polisity(DP_PolisityModel(title: "Privacy Policy", url: url)))
    }
}

private extension DP_PhotoViewControllerExtension {
    
    func dp_configUI() {
        dp_createManager()
       
        if helper.dp_getStartLang() == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.dp_choiseLang()
            }
        }
        dp_createMenu()
        dp_createSegment()
    }
    
    func dp_createSegment() {
        segment = UISegmentedControl(items: ["Recent", "Pinned"])
        guard let segment = segment else { return }
            segment.sizeToFit()
            if #available(iOS 13.0, *) {
                segment.selectedSegmentTintColor = DP_Colors.blue.color
            } else {
               segment.tintColor = DP_Colors.blue.color
            }
            segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], for: .normal)
        segment.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
            self.navigationItem.titleView = segment
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
            switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                photoManager?.dp_reloadTableWithData(.recent)
            case 1:
                photoManager?.dp_reloadTableWithData(.pined)
            default:
                break
            }
        }
    
    func dp_createManager() {
        photoManager = DP_PhotoTableManager(photoTableView)
        photoManager?.eventHandler = { [weak self] url in
            self?.coordinator?.dp_eventOccurred(with: .detail(url))
        }
    }
}
