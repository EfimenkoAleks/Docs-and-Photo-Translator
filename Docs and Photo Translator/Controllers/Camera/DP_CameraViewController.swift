//
//  DP_CameraViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit
import AVFoundation

typealias DP_CameraViewControllerExtension = DP_CameraViewController

class DP_CameraViewController: DP_BaseViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var coordinator: DP_CameraCoordinatorProtocol?
    private let photoOutput = AVCapturePhotoOutput()
    private let layer = AVSampleBufferDisplayLayer()
    private lazy var client = DP_VideoManager()
    private let liveManager: DP_BroadCastLiveManager = DP_BroadCastLiveManager()
    private let helper: DP_CameraHelper = DP_CameraHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
   
        client.stopSession()
    }

    override func dp_backButtonAction() {
        handleDismiss()
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
 
        guard let image = cameraImage.image,
              let data = image.jpegData(compressionQuality: 0.7) else { return }
        
        helper.dp_saveNewPhoto(data: data)
    }
}

private extension DP_CameraViewControllerExtension {
    
    func dp_configUI() {
        sm_addVideo()
    }
    
    func sm_getBuferForView(bufer: CMSampleBuffer) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.enqueue(bufer)
        }
    }
    
    func sm_addVideo() {
        do {
            try  client.startSendingVideoToServer()
        } catch {
        }
       
        client.handlerBufer = { [weak self] bufer in
            guard let self = self else { return }
            
            self.sm_getBuferForView(bufer: bufer)
            guard let image = self.liveManager.sm_getBuferForWrite(bufer: bufer) else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.cameraImage.image = image
            }
        }
    }

    func handleDismiss() {
        DP_StartCoordinator.shared.dp_strart()
    }
}
