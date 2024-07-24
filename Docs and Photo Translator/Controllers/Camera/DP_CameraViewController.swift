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
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var containerReset: DP_ViewVithGradient!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerPhoto: DP_ViewVithGradient!
   
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
    private var popapMenuView: DP_PopUpLangView?
    private var resetButton: UIButton?
    private var photoButton: UIButton?
    private var rotateNavButton: CGFloat = CGFloat.pi * 2
    private var isSessionStart: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
        dp_setGradient()
      super.viewWillAppear(animated)
        dp_addVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
   
        dp_stopSessino()
    }

    override func dp_backButtonAction() {
        dp_handleDismiss()
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
        dp_createNavTitle(rotate: rotateNavButton)
        dp_addNavButtons()
        dp_addTapView()
        dp_configureUI()
    }
    
    func dp_configureUI() {
        resetButton = DP_BilderElements.shared.dp_buttonWithImage("reset")
        dp_addButton(button: resetButton, conteiner: containerReset)
        resetButton?.addTarget(self, action: #selector(dp_resetCamera), for: .touchUpInside)
        photoButton = DP_BilderElements.shared.dp_buttonWithImage("cameraIcon")
        dp_addButton(button: photoButton, conteiner: containerPhoto)
        photoButton?.addTarget(self, action: #selector(dp_didTapCameraButton), for: .touchUpInside)
        containerView.gradientBorder(colors: [UIColor(hexString: "#0B4EFF"), UIColor(hexString: "#3E73FF")])
    }
    
    func dp_addTapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dp_didTapPreview))
        previewView.addGestureRecognizer(tap)
    }
    
    func dp_createNavTitle(rotate: CGFloat) {
       var navImage = UIImage(named: "More")
        navImage = navImage?.rotate(radians: rotate)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(navImage, for: .normal)
            button.addTarget(self, action: #selector(dp_didTapTitle), for: .touchUpInside)
            self.navigationItem.titleView = button
    }
    
    @objc func dp_didTapTitle() {
        popapMenuView == nil ? dp_createPopapMenuView() : dp_removePopapMenuView()
        rotateNavButton = rotateNavButton == CGFloat.pi ? CGFloat.pi * 2 : CGFloat.pi
        dp_createNavTitle(rotate: rotateNavButton)
    }
    
    @objc func dp_didTapPreview() {
        
    }
    
    func dp_getBuferForView(bufer: CMSampleBuffer) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.enqueue(bufer)
        }
    }
    
    func dp_startRecognizedText(image: UIImage) {
        dp_recognizeText(in: image) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dp_removeLoader()
                self.dp_createPopapMenuView()
            }
        }
    }
    
    func dp_addVideo() {
            do {
                try  client.startSendingVideoToServer()
      //          isSessionStart = true
            } catch {
            }
       
        client.handlerBufer = { [weak self] bufer in
            guard let self = self else { return }
            
            self.dp_getBuferForView(bufer: bufer)
            guard let image = self.liveManager.sm_getBuferForWrite(bufer: bufer) else { return }
           
    //        if self.isSessionStart {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.cameraImage.image = image
    //            }
            }
        }
    }
    
    func dp_addNavButtons() {
        self.navigationItem.leftBarButtonItems = []
       dp_createLeftNavBarItems(image: "light", action: #selector(dp_didTapLIgth))
        dp_createLeftNavBarItems(image: "monoHrome", action: #selector(dp_didTapMonoHrome))
    }
    
    @objc func dp_didTapLIgth() {
     
    }
    
    @objc func dp_didTapMonoHrome() {
     
    }

    func dp_stopSessino() {
        client.stopSession()
    }

    func dp_handleDismiss() {
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
                DP_TranslateManager.shared.originalLanguages = originalLanguage
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
    
    func dp_addButton(button: UIButton?, conteiner: UIView) {
        guard let button = button else { return }
        conteiner.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: conteiner.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: conteiner.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    //MARK: - Create popap menu
    func dp_createPopapMenuView() {
        if popapMenuView == nil {
            let currentLang = DP_TranslateManager.shared.currentLanguages ?? TranslateLanguage.english
            let originalLang = DP_TranslateManager.shared.originalLanguages ?? TranslateLanguage.english
            let currentNameLang = DP_TranslateManager.shared.dp_getNameLang(lang: currentLang) ?? "non"
            let originalNameLang = DP_TranslateManager.shared.dp_getNameLang(lang: originalLang) ?? "non"
            
            popapMenuView = DP_PopUpLangView(frame: CGRect(x: 20, y: view.safeAreaInsets.top + 20, width: view.bounds.width - 40, height: 42),
                                             firstText: originalNameLang,
                                             secondText: currentNameLang)
            guard let popapMenuView = popapMenuView else { return }
            view.addSubview(popapMenuView)
           
            popapMenuView.changeButton?.addTarget(self, action: #selector(dp_changeLang), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                guard let self = self,
                let popapMenuView = self.popapMenuView else { return }
                popapMenuView.alpha = 1.0
            }
        }
    }
    
    func dp_removePopapMenuView() {
        UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
            guard let self = self else { return }
            self.popapMenuView?.alpha = 0.0
        } completion: { [weak self] completion in
            if completion {
                self?.popapMenuView?.removeFromSuperview()
                self?.popapMenuView = nil
            }
        }
    }
    
    @objc func dp_didTapCameraButton() {
        
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
  //      isSessionStart = false
        currentImage = photoHelper.dp_scaleAndOrient(image: image)
        guard let currentImage = currentImage else { return }
        dp_startRecognizedText(image: currentImage)
    }
    
    @objc func dp_changeLang() {
        print("dp_changeLang")
    }
    
    @objc func dp_resetCamera() {
    //    isSessionStart = true
      //  cameraImage.layer.sublayers?.removeAll()
      //  dp_addVideo()
    }
}
