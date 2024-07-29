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
    
    @IBOutlet private weak var cameraView: UIView!
    @IBOutlet private weak var previewView: UIImageView!
    @IBOutlet private weak var containerReset: DP_ViewVithGradient!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containerPhoto: DP_ViewVithGradient!
   
    var coordinator: DP_CameraCoordinatorProtocol?
    private var cameraImage: UIImageView?
    private let photoOutput = AVCapturePhotoOutput()
    private let layer = AVSampleBufferDisplayLayer()
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
    private var isOriginLang: Bool = true
    private var ligth: AVCaptureDevice.FlashMode = .off
    private var lightImage: UIImage?
    private var monohromeImage: UIImage?
    private var currentLang: TranslateLanguage?
    private var originalLang: TranslateLanguage?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private let manager: DP_PhotoManager = DP_PhotoManager()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isSmallBackButtonEnabled = false
        dp_setGradient()
      super.viewWillAppear(animated)
        dp_resetImage()
        dp_setPreview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
   
        dp_stopSessino()
    }

    override func dp_backButtonAction() {
        dp_handleDismiss()
    }
}

private extension DP_CameraViewControllerExtension {
    
    func dp_configUI() {
        dp_createNavTitle(rotate: rotateNavButton)
        dp_setLeftNavBarItems()
        dp_configureUI()
        dp_resetLanguage()
        dp_addTapView()
    }
    
    func dp_addVideo(captureSession: AVCaptureSession?) {
        guard let captureSession = captureSession,
        let cameraImage = cameraImage else { return }
        
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraImage.layer.insertSublayer(cameraPreviewLayer, at: 0)
        cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resize
        let screen = UIScreen.main.bounds
        let height = screen.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom)
        cameraPreviewLayer.frame = CGRect(x: 0, y: 0, width: screen.width, height: height)
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
    
    func dp_setPreview() {
        helper.dp_getPhotos { [weak self] array in
            guard let self = self,
                  let model = array.first,
                  let url = model.image else { return }
            
            do {
                let data = try Data(contentsOf: url)
                self.previewView.image = UIImage(data: data)
            } catch {
                self.previewView.image = UIImage()
            }
        }
    }
    
    func dp_addTapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dp_didTapPreview))
        previewView.addGestureRecognizer(tap)
        previewView.layer.cornerRadius = 8
        previewView.layer.masksToBounds = true
    }
    
    func dp_resetLanguage() {
        currentLang = DP_TranslateManager.shared.currentLanguages ?? TranslateLanguage.english
        originalLang = nil
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
     //   dp_resetLanguage()
        
        coordinator?.dp_eventOccurred(with: .choise)
        coordinator?.eventHandler = { [weak self] image in
            guard let self = self,
            let newImage = image else { return }
            self.currentImage = newImage
         
            self.dp_restartCondition()
            self.cameraImage?.image = newImage
            self.dp_setStartLoadImage(newImage: newImage)
        }
    }
    
    func dp_getBuferForView(bufer: CMSampleBuffer) {
        DispatchQueue.main.async { [weak self] in
            self?.layer.enqueue(bufer)
        }
    }
    
    func dp_startRecognizedText(image: UIImage, isOriginalLang: Bool) {
        dp_recognizeText(in: image, isOriginalLang: isOriginalLang) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dp_removeLoader()
                self.dp_createPopapMenuView(isOriginalLang: isOriginalLang)
            }
        }
    }

    func dp_stopSessino() {
        manager.stopSesion()
    }
    
    func dp_setLeftNavBarItems() {
        lightImage = UIImage(systemName: "bolt.fill")
        monohromeImage = UIImage(named: "monoHrome")
        dp_addNavButtons()
    }
    
    func dp_addNavButtons() {
        self.navigationItem.leftBarButtonItems = []
       dp_createLeftNavBarItems(image: lightImage, action: #selector(dp_didTapLIgth))
        dp_createLeftNavBarItems(image: monohromeImage, action: #selector(dp_didTapMonoHrome))
        self.navigationItem.rightBarButtonItems = []
        dp_createRightNavBarItems(image: "livephoto.slash", action: #selector(dp_didTapLiveCamera))
    }
    
    @objc func dp_didTapLIgth() {
        ligth = ligth == .off ? .on : .off
        lightImage = ligth == .on ? UIImage(systemName: "bolt.fill") : UIImage(systemName: "bolt.slash.fill")
        dp_addNavButtons()
    }
    
    @objc func dp_didTapMonoHrome() {
     
    }
    
    @objc func dp_didTapLiveCamera() {
     
    }

    func dp_handleDismiss() {
        DP_StartCoordinator.shared.dp_strart()
    }
    
    func dp_recognizeText(in image: UIImage, isOriginalLang: Bool, completion: @escaping () -> Void) {
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
                
                let originalTextLang = TranslateLanguage(rawValue: lang)
                var currentLang: TranslateLanguage = originalTextLang
                if !isOriginalLang, let lang = self.currentLang {
                    currentLang = lang
                    self.currentLang = self.originalLang
                    self.originalLang = currentLang
                } else if isOriginalLang, self.originalLang != nil, let lang = self.currentLang {
                    currentLang = lang
                    self.currentLang = self.originalLang
                    self.originalLang = currentLang
                } else {
                    self.originalLang = currentLang
                }
               
                if !DP_TranslateManager.shared.isLanguageDownloaded(currentLang) {
                    DP_TranslateManager.shared.dp_translateTag(lang: currentLang) { [weak self] rezOrigin in
                        guard let self = self else { return }
                        self.dp_presentAlertWithTwoButtons(title: "The text uses - \(rezOrigin) language, to translate you need to download the \(rezOrigin) language")
                    }
                    completion()
                } else {
                    DispatchQueue.main.async { [weak self] in

                        guard let self = self else { return }

                        for (i, str) in model.texts.enumerated() {

                            DP_TranslateManager.shared.getText(str, originalLanguage: currentLang) { [weak self] rezText in
                                guard let self = self,
                                      let cameraImage = self.cameraImage else { return }
                                switch rezText {
                                case .success(let rezText):

                                    let lb = self.photoHelper.dp_createViewImage(rect: model.rects[i], bounds: model.imageBounds, viewFrame: cameraImage.frame, text: rezText, inputImage: image)

                                    cameraImage.addSubview(lb)
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
    
    func dp_restartCondition() {
        dp_resetLanguage()
        dp_removePopapMenuView(0.0)
        dp_removeImageView()
        dp_createImageView()
    }
 
    func dp_resetImage() {
        dp_restartCondition()
        manager.startSession()
        dp_addVideo(captureSession: manager.captureSession)
    }
    
    func dp_createImageView() {
        cameraImage = UIImageView()
        cameraImage?.contentMode = .scaleToFill
        cameraImage?.backgroundColor = UIColor.clear
        cameraImage?.translatesAutoresizingMaskIntoConstraints = false
        guard let cameraImage = cameraImage else { return }
        
        cameraView.insertSubview(cameraImage, at: 0)
        
        NSLayoutConstraint.activate([
            cameraImage.topAnchor.constraint(equalTo: cameraView.topAnchor),
            cameraImage.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
            cameraImage.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
            cameraImage.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor)
        ])
    }
    
    func dp_removeImageView() {
        cameraImage?.removeFromSuperview()
        cameraImage = nil
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
    func dp_createPopapMenuView(isOriginalLang: Bool = true) {
        if popapMenuView == nil {
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
    
    func dp_removePopapMenuView(_ duration: CGFloat = 0.5) {
        UIView.animate(withDuration: duration, delay: 0) { [weak self] in
            guard let self = self else { return }
            self.popapMenuView?.alpha = 0.0
        } completion: { [weak self] completion in
            if completion {
                self?.popapMenuView?.removeFromSuperview()
                self?.popapMenuView = nil
            }
        }
    }
    
    func dp_tapCamera() {
        dp_resetLanguage()
        manager.dp_createPhoto(withLight: ligth)
        manager.imageHanddler = { [weak self] newImage in
            guard let self = self else { return }

            self.dp_addLoader()
            guard let data = newImage.jpegData(compressionQuality: 0.7) else { return }

            self.urlPhoto = self.helper.dp_saveNewPhoto(data: data)

            self.dp_setStartLoadImage(newImage: newImage)
        }
    }
    
    func dp_setStartLoadImage(newImage: UIImage) {
        self.dp_stopSessino()
        self.currentImage = self.photoHelper.dp_scaleAndOrient(image: newImage)
        guard let currentImage = self.currentImage else { return }
        self.dp_startRecognizedText(image: currentImage, isOriginalLang: true)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dp_setPreview()
        }
    }

    @objc func dp_didTapCameraButton() {
        popapMenuView == nil ? dp_tapCamera() : dp_resetImage()
    }

    @objc func dp_changeLang() {
        dp_addLoader()
        isOriginLang.toggle()
        dp_removePopapMenuView(0.0)
      
        guard let currentImage = currentImage else { return }
        dp_startRecognizedText(image: currentImage, isOriginalLang: isOriginLang)
    }
    
    @objc func dp_resetCamera() {
        dp_resetImage()
    }
}
