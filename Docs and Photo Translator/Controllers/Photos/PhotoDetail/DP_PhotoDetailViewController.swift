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
    
//    private lazy var segmentationRequest: VNGeneratePersonSegmentationRequest = {
//        let request = VNGeneratePersonSegmentationRequest(completionHandler: segmentationCompletionHandler)
//        request.qualityLevel = .accurate
//        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
//        return request
//    }()
    
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
        do {
            let data = try Data(contentsOf: path)
            guard let img = UIImage(data: data) else { return }
            
           let normImg = scaleAndOrient(image: img)
            recognizeText(in: normImg)
        } catch {
            photoImage.image = UIImage(named: "defaultPhoto")
        }
    }
    
//    func dp_recognizeText(image: UIImage) {
//        photoImage.image = image
//
//        guard let cgImage = image.cgImage else { return }
//        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
//        let size = CGSize(width: cgImage.width, height: cgImage.height)
//        let bounds = CGRect(origin: .zero, size: size)
//        let request = VNRecognizeTextRequest { request, error in
//            guard let results = request.results as? [VNRecognizedTextObservation],
//                  error == nil else { return }
//
//            let str = results.compactMap {
//                $0.topCandidates(1).first?.string}.joined(separator: "\n")
//            print(str)
//
//        }
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try imageRequestHandler.perform([request])
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    func detectText(in image: UIImage, completion: @escaping ([VNTextObservation]?) -> Void) {
//        guard let cgImage = image.cgImage else {
//            completion(nil)
//            return
//        }
//
//        let request = VNDetectTextRectanglesRequest { request, error in
//            guard error == nil else {
//                completion(nil)
//                return
//            }
//            completion(request.results as? [VNTextObservation])
//        }
//        request.reportCharacterBoxes = true
//
//        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        DispatchQueue.global(qos: .userInitiated).async {
//            try? handler.perform([request])
//        }
//    }
//
//    func createMask(for image: UIImage, textObservations: [VNTextObservation]) -> UIImage? {
//        UIGraphicsBeginImageContext(image.size)
//        guard let context = UIGraphicsGetCurrentContext(), let cgImage = image.cgImage else {
//            return nil
//        }
//
//        let size = image.size
//        let scale = size.width / CGFloat(cgImage.width)
//        context.scaleBy(x: scale, y: scale)
//        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
//
//        context.setFillColor(UIColor.black.cgColor)
//        for observation in textObservations {
//            let boundingBox = observation.boundingBox
//            let rect = CGRect(x: boundingBox.origin.x * size.width,
//                              y: (1 - boundingBox.origin.y - boundingBox.height) * size.height,
//                              width: boundingBox.width * size.width,
//                              height: boundingBox.height * size.height)
//            context.fill(rect)
//        }
//
//        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return maskImage
//    }
//
//    func inpaint(image: UIImage, mask: UIImage) -> UIImage? {
//        guard let ciImage = CIImage(image: image), let maskCIImage = CIImage(image: mask) else {
//            return nil
//        }
//
//        let filter = CIFilter(name: "CIMaskedVariableBlur")
//        filter?.setValue(ciImage, forKey: kCIInputImageKey)
//        filter?.setValue(maskCIImage, forKey: "inputMask")
//        filter?.setValue(10, forKey: kCIInputRadiusKey)
//
//        guard let outputCIImage = filter?.outputImage else {
//            return nil
//        }
//
//        let context = CIContext()
//        if let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
//            return UIImage(cgImage: outputCGImage)
//        }
//        return nil
//    }
//
//    func removeText(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
//        detectText(in: image) { textObservations in
//            guard let textObservations = textObservations else {
//                completion(nil)
//                return
//            }
//
//            let mask = self.createMask(for: image, textObservations: textObservations)
//            guard let maskImage = mask else {
//                completion(nil)
//                return
//            }
//
//            let inpaintedImage = self.inpaint(image: image, mask: maskImage)
//            completion(inpaintedImage)
//        }
//    }

//--------------------
    
    
//    func processImage(_ image: UIImage, completion: @escaping (Result<UIImage,Error>) -> Void) {
//        self.completion = completion
//        self.image = image
//        self.originalCiImage = CIImage(image: image)!
//
//        do {
//            let handler = VNImageRequestHandler(ciImage: originalCiImage!, options: [:])
//            try handler.perform([self.segmentationRequest])
//        } catch {
//            debugPrint("Error performing vision image request: \(error.localizedDescription)")
//            completion(.failure(error))
//        }
//    }
//
//    private func segmentationCompletionHandler(request: VNRequest?, error: Error?) {
//        guard let result = request?.results?.first as? VNPixelBufferObservation else {
//            completion?(.failure(error!))
//            return
//        }
//        let pixelBuffer = result.pixelBuffer
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: [:])
//
//        var translate = CGAffineTransform()
//            var resize = CIImage()
//
//            resize = ciImage.resizeToSameHeight(as: self.originalCiImage!)
//            translate = CGAffineTransform(translationX: -(resize.extent.width - (self.originalCiImage!.extent.width)) * 0.5, y: 0)
//
//            let transparentBlackImage =  resize.transformed(by: translate)
//
//        let alphaImage = self.originalCiImage!.settingAlphaOne(in: CGRect.zero)
//
//        let filter = CIFilter(name: "CIBlendWithMask", parameters: [
//                kCIInputImageKey: self.originalCiImage!,
//                kCIInputBackgroundImageKey:alphaImage,
//                kCIInputMaskImageKey:transparentBlackImage])
//            let editedImage = filter?.outputImage
//            completion?(.success(UIImage(ciImage: editedImage!)))
//
//    }
//
//    func removeTextFromImage(image: UIImage) -> UIImage? {
//        guard let cgImage = image.cgImage else { return nil }
//
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//
//        let textDetectionRequest = VNDetectTextRectanglesRequest { [weak self] (request, error) in
//            guard error == nil else {
//                print("Text detection error: \(String(describing: error))")
//                return
//            }
//            self?.processTextDetectionResults(request.results, in: image)
//        }
//        textDetectionRequest.reportCharacterBoxes = true
//
//        do {
//            try requestHandler.perform([textDetectionRequest])
//        } catch {
//            print("Failed to perform text detection request: \(error)")
//            return nil
//        }
//
//        return image
//    }
//
//    func processTextDetectionResults(_ results: [Any]?, in image: UIImage) {
//        guard let results = results as? [VNTextObservation] else { return }
//
//        for textObservation in results {
//            guard let characterBoxes = textObservation.characterBoxes else { continue }
//
//            for characterBox in characterBoxes {
//                let boundingBox = characterBox.boundingBox
//                let imageSize = image.size
//                let x = boundingBox.origin.x * imageSize.width
//                let y = (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height
//                let width = boundingBox.width * imageSize.width
//                let height = boundingBox.height * imageSize.height
//
//                blurEffect(in: CGRect(x: x, y: y, width: width, height: height), from: image)
//            }
//        }
//    }
//
//    func removeText(in rect: CGRect, from image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//        let ciImage = CIImage(cgImage: cgImage)
//
//        // Create mask image
//        let maskImage = CIImage(color: CIColor(red: 1, green: 1, blue: 1, alpha: 1))
//            .cropped(to: rect)
//
//        // Perform inpainting
//
//
//
//        let filter = CIFilter(name: "CICrystallize")!
//        filter.setValue(maskImage, forKey: kCIInputImageKey)
//        filter.setValue(55, forKey: kCIInputRadiusKey)
//        let editedImage = filter.outputImage
//        UIImage(ciImage: editedImage!)
        
       //  let inpaintedImage = ciImage.applyingFilter("CICrystallize", parameters: [kCIInputMaskImageKey: maskImage])
//            let context = CIContext(options: nil)
//            if let cgInpaintedImage = context.createCGImage(inpaintedImage, from: inpaintedImage.extent) {
//                let resultImage = UIImage(cgImage: cgInpaintedImage)
//                // Use resultImage as the final image without text
//            }
        
 //   }
 
    //--------------------------
    func blurEffect(in rect: CGRect, from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }



//        CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
//           UIImage *cropped = [UIImage imageWithCGImage:imageRef];
//           CGImageRelease(imageRef);
        
        guard let img = cgImage.cropping(to: rect) else { return nil }
        let image = UIImage(cgImage: img, scale: image.scale, orientation: image.imageOrientation)


            let currentFilter = CIFilter(name: "CIGaussianBlur")
            let beginImage = CIImage(cgImage: img)
            currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter!.setValue(30, forKey: kCIInputRadiusKey)

            let cropFilter = CIFilter(name: "CICrop")
            cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
            cropFilter!.setValue(CIVector(cgRect: beginImage.extent), forKey: "inputRectangle")

            let output = cropFilter!.outputImage
            let cgimg = context.createCGImage(output!, from: output!.extent)
            let processedImage = UIImage(cgImage: cgimg!)
            return processedImage
        }

    func recognizeText(in image: UIImage) {
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
                convert(boundingBox: $0.boundingBox, to: CGRect(origin: .zero, size: size))
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
                self.photoImage.image = final
                print(string)
                
                for (i, model) in strings.enumerated() {
                    
//                    let img = self.blurEffect(in: rects[i], from: final)
//                    self.photoImage.image = img
                
   
                    DP_TranslateManager.shared.getText(model) { rezText in
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

    /// Convert Vision coordinates to pixel coordinates within image.
    ///
    /// Adapted from `boundingBox` method from
    /// [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
    /// This flips the y-axis.
    ///
    /// - Parameters:
    ///   - boundingBox: The bounding box returned by Vision framework.
    ///   - bounds: The bounds within the image (in pixels, not points).
    ///
    /// - Returns: The bounding box in pixel coordinates, flipped vertically so 0,0 is in the upper left corner

    func convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
        let imageWidth = bounds.width
        let imageHeight = bounds.height

        // Begin with input rect.
        var rect = boundingBox

        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.minX
        rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY

        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight

        return rect
    }

    ///  Scale and orient picture for Vision framework
    ///
    ///  From [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
    ///
    ///  - Parameter image: Any `UIImage` with any orientation
    ///  - Returns: An image that has been rotated such that it can be safely passed to Vision framework for detection.

    func scaleAndOrient(image: UIImage) -> UIImage {

        // Set a default value for limiting image size.
        let maxResolution: CGFloat = 640

        guard let cgImage = image.cgImage else {
            print("UIImage has no CGImage backing it!")
            return image
        }

        // Compute parameters for transform.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        var transform = CGAffineTransform.identity

        var bounds = CGRect(x: 0, y: 0, width: width, height: height)

        if width > maxResolution ||
            height > maxResolution {
            let ratio = width / height
            if width > height {
                bounds.size.width = maxResolution
                bounds.size.height = round(maxResolution / ratio)
            } else {
                bounds.size.width = round(maxResolution * ratio)
                bounds.size.height = maxResolution
            }
        }

        let scaleRatio = bounds.size.width / width
        let orientation = image.imageOrientation
        switch orientation {
        case .up:
            transform = .identity
        case .down:
            transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
        case .left:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
        case .upMirrored:
            transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
        case .rightMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
        default:
            transform = .identity
        }

        return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
            let context = rendererContext.cgContext

            if orientation == .right || orientation == .left {
                context.scaleBy(x: -scaleRatio, y: scaleRatio)
                context.translateBy(x: -height, y: 0)
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio)
                context.translateBy(x: 0, y: -height)
            }
            context.concatenate(transform)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

}
