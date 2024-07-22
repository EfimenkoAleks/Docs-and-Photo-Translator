//
//  DP_CameraViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 20.06.2024.
//

import UIKit
import AVFoundation
import Vision
import MLKitTranslate

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
    private var currentImage: UIImage?
    private var context = CIContext(options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
        dp_setGradient()
      super.viewWillAppear(animated)
        sm_addVideo()
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
        currentImage = photoHelper.dp_scaleAndOrient(image: image)
        guard let currentImage = currentImage else { return }
        dp_startRecognizedText(image: currentImage)
    }
    
    override func dp_actionHandler(alert: UIAlertAction) {
        coordinator?.dp_eventOccurred(with: .choise)
        coordinator?.eventHandler = { [weak self] _ in
            guard let self = self,
                  let currentImage = self.currentImage else { return }
            self.dp_startRecognizedText(image: currentImage)
        }
    }
}

private extension DP_CameraViewControllerExtension {
    
    func dp_configUI() {
    //    sm_addVideo()
        
        cameraButton.layer.cornerRadius = 12
        cameraButton.layer.masksToBounds = true
        cameraButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    func sm_getBuferForView(bufer: CMSampleBuffer) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.enqueue(bufer)
        }
    }
    
    func dp_startRecognizedText(image: UIImage) {
        dp_recognizeText(in: image) { [weak self] in
            self?.dp_removeLoader()
            self?.dp_addNavButtons()
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
        DP_TextRecognizedManager.shared.dp_textRecognized(in: image) { [weak self] model in
            guard let self = self else { return }
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1

            self.photoHelper.dp_getTextForScaningLang(arrLangs: model.texts) { [weak self] lang in
                guard let self = self else { return }
                if lang == DP_TranslateLangError.translateError.events {
                    self.dp_presentAlert(title: DP_TranslateLangError.cantRecognizeLang.events)
                    completion()
                }
                
                let originalLanguage = TranslateLanguage(rawValue: lang)
                let currentLang = DP_TranslateManager.shared.currentLanguages
                if !DP_TranslateManager.shared.isLanguageDownloaded(originalLanguage) {
                    DP_TranslateManager.shared.dp_translateTag(lang: originalLanguage) { [weak self] rezOrigin in
                        guard let self = self else { return }
                        self.dp_presentAlertWithTwoButtons(title: "The text uses - \(rezOrigin) language, to translate you need to download the \(rezOrigin) language")
                    }
                    completion()
                } else {
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let self = self else { return }
         
                        for (i, str) in model.texts.enumerated() {
                       
                            DP_TranslateManager.shared.getText(str, originalLanguage: originalLanguage) { [weak self] rezText in
                                guard let self = self else { return }
                                switch rezText {
                                case .success(let rezText):
                                
                                    let lb = self.photoHelper.dp_createViewImage(rect: model.rects[i], bounds: model.imageBounds, viewFrame: self.cameraImage.frame, text: rezText, inputImage: image)

                                    self.cameraImage.addSubview(lb)
                                case .noLanguage:
                                    self.dp_presentAlert(title: DP_TranslateLangError.cantRecognizeLang.events)
                                }
                            }
                        }
                        completion()
                    }
                }
            }
        }
    }
}
