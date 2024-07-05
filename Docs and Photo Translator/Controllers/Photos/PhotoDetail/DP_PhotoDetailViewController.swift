//
//  DP_PhotoDetailViewController.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 27.06.2024.
//

import UIKit
import Vision
import CoreImage.CIFilterBuiltins
import MLKit
import MLKitTranslate


class DP_PhotoDetailViewController: DP_BaseViewController {

    @IBOutlet weak var photoImage: UIImageView!
    var coordinator: DP_PhotoDetailCoordinatorProtocol?
    private var path: URL
    var image: UIImage?
    var originalCiImage: CIImage?
    var completion: ((Result<UIImage,Error>) -> Void)?
    var context = CIContext(options: nil)
    @objc dynamic var inputImage : CIImage?
    private var helper: DP_PhotoHelper = DP_PhotoHelper()

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
}

extension DP_PhotoDetailViewController {
    
    func dp_configure() {
        dp_addLoader()
        do {
            let data = try Data(contentsOf: path)
            guard let img = UIImage(data: data) else { return }
            
            let normImg = helper.dp_scaleAndOrient(image: img)
            dp_recognizeText(in: normImg) { [weak self] in
                self?.dp_removeLoader()
                self?.dp_addNavButtons()
            }
        } catch {
            photoImage.image = UIImage(named: "defaultPhoto")
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
                helper.dp_convert(boundingBox: $0.boundingBox, to: CGRect(origin: .zero, size: size))
            }
            
            let modelText = results.compactMap {
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
            helper.dp_getTextForScaningLang(arrLangs: strings) { lang in
                let originalLanguage = TranslateLanguage(rawValue: lang)
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self = self else { return }
                    self.photoImage.image = final
                    print(modelText)
                    
                    for (i, model) in strings.enumerated() {
                        
                        //                    let img = self.blurEffect(in: rects[i], from: final)
                        //                    self.photoImage.image = img
                        
                        DP_TranslateManager.shared.getText(model, originalLanguage: originalLanguage) { rezText in
                            switch rezText {
                            case .success(let rezText):
                                let rectLb = rects[i]
                                let screen = self.photoImage.frame
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
                                
                                self.photoImage.addSubview(lb)
                            case .noLanguage:
                                break
                            }
                        }
                    }
                    completion()
                }
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
