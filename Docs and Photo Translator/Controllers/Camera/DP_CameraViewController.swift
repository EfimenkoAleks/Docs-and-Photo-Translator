//
//  DP_CameraViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit
import AVFoundation
import Vision

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
    private let photoHelper: DP_PhotoHelper = DP_PhotoHelper()
    private var urlPhoto: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
   
        dp_stopSessino()
    }

    override func dp_backButtonAction() {
        handleDismiss()
    }
    
    @IBAction func didTapCameraButton(_ sender: UIButton) {
        
        if #available(iOS 9.0, *) {
                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
            } else {
                AudioServicesPlaySystemSound(1108)
            }
 
        dp_addLoader()
        guard let image = cameraImage.image,
              let data = image.jpegData(compressionQuality: 0.7) else { return }
        
        urlPhoto = helper.dp_saveNewPhoto(data: data)
        
        dp_stopSessino()
        let normImg = photoHelper.dp_scaleAndOrient(image: image)
        dp_recognizeText(in: normImg) { [weak self] in
            self?.dp_removeLoader()
            self?.dp_addNavButtons()
        }
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
    
    func dp_addNavButtons() {
        guard let path = urlPhoto else { return }
        self.navigationItem.rightBarButtonItems = []
        dp_createRightNavBarItems(image: "square.and.arrow.up", action: #selector(dp_didTapShare))
        var pinStr = "pin"
        if photoHelper.dp_ifContainsPinedPhoto(url: path) {
            pinStr = "pin.fill"
        }
        dp_createRightNavBarItems(image: pinStr, action: #selector(dp_didTapPin))
    }

    @objc func dp_didTapPin() {
        guard let path = urlPhoto else { return }
        if photoHelper.dp_ifContainsPinedPhoto(url: path) {
            photoHelper.dp_deletePinedPhoto(url: path)
            dp_addNavButtons()
        } else {
            photoHelper.dp_savePinedPhoto(url: path)
            dp_addNavButtons()
        }
    }
    
    @objc func dp_didTapShare() {
        guard let image = cameraImage.image else { return }
            let imageShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
    }
    
    func dp_stopSessino() {
        client.stopSession()
    }

    func handleDismiss() {
        DP_StartCoordinator.shared.dp_strart()
    }
    
    func dp_recognizeText(in image: UIImage, completion: @escaping () -> Void) {
        guard let cgImage = image.cgImage else { return }
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        
        let size = CGSize(width: cgImage.width, height: cgImage.height) // note, in pixels from `cgImage`; this assumes you have already rotate, too
        let bounds = CGRect(origin: .zero, size: size)
        // Create a new request to recognize text.
        
        
        let request = VNRecognizeTextRequest { [self] request, error in
            guard
                let results = request.results as? [VNRecognizedTextObservation],
                error == nil
            else { return }
            
            let rects = results.map {
                photoHelper.dp_convert(boundingBox: $0.boundingBox, to: CGRect(origin: .zero, size: size))
            }
            
            let string = results.compactMap {
                $0.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            let strings = results.compactMap({$0.topCandidates(1).first?.string})
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let final = UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
                image.draw(in: bounds)
                UIColor.white.withAlphaComponent(0.95).setFill()
                for rect in rects {
                    let path = UIBezierPath(rect: rect)
                    path.fill()
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else { return }
                self.cameraImage.image = final
                print(string)
                
                for (i, model) in strings.enumerated() {
                    
                    //                    let img = self.blurEffect(in: rects[i], from: final)
                    //                    self.photoImage.image = img
                    
                    
                    DP_TranslateManager.shared.getText(model) { rezText in
                        switch rezText {
                        case .success(let rezText):
                            let rectLb = rects[i]
                            let screen = self.cameraImage.frame
                            let width = screen.width / bounds.width
                            let height = screen.height / bounds.height
                            
                            let lbX = rectLb.minX.rounded() * width
                            let lbY = rectLb.minY.rounded() * height
                            
                            let lbHeight = rectLb.height * height
                            let lbWidth = rectLb.width * width
                            
                            let lb = UILabel(frame: CGRect(x: lbX, y: lbY, width: lbWidth, height: lbHeight))
                            lb.textColor = .black
                            lb.textAlignment = .center
                            lb.text = rezText
                            lb.font = lb.font.withSize(lb.frame.height / 2)
                            
                            self.cameraImage.addSubview(lb)
                        case .noLanguage:
                            break
                        }
                    }
                }
                completion()
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform([request])
            } catch {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
}
