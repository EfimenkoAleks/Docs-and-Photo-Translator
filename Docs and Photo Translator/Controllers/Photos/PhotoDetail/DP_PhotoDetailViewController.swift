//
//  DP_PhotoDetailViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 27.06.2024.
//

import UIKit
import Vision
import MLKitTranslate

class DP_PhotoDetailViewController: DP_BaseViewController {

    @IBOutlet private weak var photoImage: UIImageView!
    var coordinator: DP_PhotoDetailCoordinatorProtocol?
    private var path: URL
    private var context = CIContext(options: nil)
    private var helper: DP_PhotoHelper = DP_PhotoHelper()
    private var currentImage: UIImage?

    init(model: URL) {
        path = model
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dp_configure()
    }

    override func dp_backButtonAction() {
        coordinator?.handlerBback?()
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

extension DP_PhotoDetailViewController {
    
    func dp_configure() {
        dp_addLoader()
        do {
            let data = try Data(contentsOf: path)
            guard let img = UIImage(data: data) else { return }
            
            currentImage = helper.dp_scaleAndOrient(image: img)
            photoImage.image = currentImage
            guard let currentImage = currentImage else { return }
            
            dp_startRecognizedText(image: currentImage)
        } catch {
            photoImage.image = UIImage(named: "defaultPhoto")
        }
    }
    
    func dp_startRecognizedText(image: UIImage) {
        dp_recognizeText(in: image) { [weak self] in
            self?.dp_removeLoader()
            self?.dp_addNavButtons()
        }
    }
    
    func dp_addNavButtons() {        
        self.navigationItem.rightBarButtonItems = []
        dp_createRightNavBarItems(image: "square.and.arrow.up", action: #selector(dp_didTapShare))
        var pinStr = "pin"
        if helper.dp_ifContainsPinedPhoto(url: path) {
            pinStr = "pin.fill"
        }
        dp_createRightNavBarItems(image: pinStr, action: #selector(dp_didTapPin))
    }

    @objc func dp_didTapPin() {
        if helper.dp_ifContainsPinedPhoto(url: path) {
            helper.dp_deletePinedPhoto(url: path)
            dp_addNavButtons()
        } else {
            helper.dp_savePinedPhoto(url: path)
            dp_addNavButtons()
        }
    }
    
    @objc func dp_didTapShare() {
        guard let image = photoImage.image else { return }
            let imageShare = [ image ]
            let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
    }
 
    func dp_recognizeText(in image: UIImage, completion: @escaping () -> Void) {
        DP_TextRecognizedManager.shared.dp_textRecognized(in: image) { [weak self] model in
            guard let self = self else { return }
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1

            self.helper.dp_getTextForScaningLang(arrLangs: model.texts) { [weak self] lang in
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
                                
                                    let lb = self.helper.dp_createViewImage(rect: model.rects[i], bounds: model.imageBounds, viewFrame: self.photoImage.frame, text: rezText, inputImage: image)

                                    self.photoImage.addSubview(lb)
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
