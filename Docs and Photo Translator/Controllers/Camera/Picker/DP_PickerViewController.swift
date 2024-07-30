//
//  DP_PickerViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 28.07.2024.
//

import UIKit

typealias DP_PickerViewControllerExtension = DP_PickerViewController

class DP_PickerViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var crossButton: UIButton!
    
    private var choiceImage: UIImage?
    private let helper: DP_CameraHelper = DP_CameraHelper()
    
  //  var eventHandler: Block<URL?>?
    var eventHandlerBack: Block<(UIImage?)>?
    var collectionManager: DP_PickerManager?
    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configure()
    }
    
    @IBAction func dp_didTapCrossButton(_ sender: UIButton) {
        eventHandlerBack?((choiceImage))
    }
}

private extension DP_PickerViewControllerExtension {
    
    func dp_configure() {
        dp_createManager()
        view.backgroundColor = UIColor(hexString: "#373737")
    }
    
    func dp_createManager() {
        if collectionManager == nil {
            collectionManager = DP_PickerManager(collectionView)
            collectionManager?.eventHandler = { [weak self] value in
                guard let self = self,
                      let url = value.image,
                      let image = self.helper.dp_getImageFromUrl(path: url) else { return }
                
                self.eventHandlerBack?((image))
            }
        }
    }
}
