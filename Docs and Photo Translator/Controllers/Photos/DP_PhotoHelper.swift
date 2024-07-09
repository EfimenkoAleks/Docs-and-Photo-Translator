//
//  DP_PhotoHelper.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit
import Vision
import MLKitTranslate

final class DP_PhotoHelper: NSObject {
    
    private var preferens: DP_PreferencesProtocol
    private var screenNumber = 0
    
    init(preferens: DP_PreferencesProtocol = DP_Preferences()) {
        self.preferens = preferens
        super.init()
    }
    
    func dp_determineTheNumberOfLanguages(_ strings: [String], complletion: @escaping ([String]) -> Void) {
      
        let serialQueue = DispatchQueue(label: "queuename")
        
        let dispath = DispatchGroup()
        var arrLangs: [String] = []
        for text in strings {
            dispath.enter()
            DP_TranslateManager.shared.dp_identityLanguage(text: text) { lang in
                guard let lang = lang else {
                    dispath.leave()
                    return
                }
                serialQueue.sync {
                    arrLangs.append(lang)
                    dispath.leave()
                }
            }
        }
        dispath.notify(queue: .main) {
            complletion(arrLangs)
        }
    }
    
    func dp_determineTheMajority(arrLangs: [String], complletion: @escaping (String) -> Void) {
        var dict: [String: Int] = [:]
        let set: Set<String> = Set(arrLangs.map { $0 })
        set.forEach { event in
            dict[event] = 0
        }
        arrLangs.forEach { event in
            let keys: [String] = Array(dict.keys)
            if keys.contains(event) {
                guard var vol = dict[event] else { return }
                vol += 1
                dict[event] = vol
            } else {
                dict[event] = 1
            }
        }
        let fff = dict.sorted(by: {$0.value > $1.value})
     //   print(fff.first!.key)
        guard let lang = fff.first else {
            complletion(DP_TranslateLangError.translateError.events)
            return
        }
        complletion(lang.key)
    }
    
    func dp_getTextForScaningLang(arrLangs: [String], complletion: @escaping (String) -> Void) {
        
        dp_determineTheNumberOfLanguages(arrLangs) { [weak self] rez in
            self?.dp_determineTheMajority(arrLangs: rez, complletion: { lang in

                let arrLang = DP_TranslateManager.shared.allLanguages.map({$0.rawValue})
                if arrLang.contains(lang) {
                    complletion(lang)
                } else {
                    complletion(DP_TranslateLangError.translateError.events)
                }
            })
        }
    }
    
    func dp_savePinedPhoto(url: URL) {
        guard let number = Int(url.lastPathComponent) else { return }
        preferens.dp_saveNumberPinedPhoto(number: number)
    }
    
    func dp_ifContainsPinedPhoto(url: URL) -> Bool {
        guard let number = Int(url.lastPathComponent) else { return false }
       let intArr = preferens.dp_getPinedPhotoNumber()
        if intArr.contains(number) {
            return true
        } else {
            return false
        }
    }
    
    func dp_deletePinedPhoto(url: URL) {
        guard let number = Int(url.lastPathComponent) else { return }
        
        let intArr = preferens.dp_getPinedPhotoNumber()
        let intArrDelete = intArr.filter({$0 != number})
        preferens.dp_deletePinedPhoto(arrInt: intArrDelete)
    }
    
    func dp_deletePhoto(url: URL) {
        guard let number = Int(url.lastPathComponent) else { return }
        
        let intArr = preferens.dp_getPhotoNumber()
        let intArrDelete = intArr.filter({$0 != number})
        preferens.dp_deletePhoto(arrInt: intArrDelete)
        DP_FileManager.shared.dp_removeFile(path: url.lastPathComponent)
    }
    
    func dp_getStartLang() -> String? {
        preferens.dp_getStartLang()
    }
    
    func dp_getNumber() -> [Int] {
        preferens.dp_getPhotoNumber()
    }
    
    func dp_getPhotos() -> [DP_PhotoModel] {
        let arrInt = preferens.dp_getPhotoNumber()
        
       let paths = arrInt.compactMap({DP_FileManager.shared.dp_getFileUrlFromPath("\($0)")})
        var models: [DP_PhotoModel] = paths.map { url -> DP_PhotoModel in
          var dateCreated = ""
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
                let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                dateCreated = Date.sm_convertDateToString(date: creationDate, formatter: "dd.MM.yy HH:mm")
                }
           return DP_PhotoModel(name: "", date: dateCreated, path: url)
        }
        
        models = models.sorted(by: {$0.date > $1.date})
        return models
    }
    
    func dp_getPinedPhotos() -> [DP_PhotoModel] {
        let arrInt = preferens.dp_getPinedPhotoNumber()
        
       let paths = arrInt.compactMap({DP_FileManager.shared.dp_getFileUrlFromPath("\($0)")})
        var models: [DP_PhotoModel] = paths.map { url -> DP_PhotoModel in
          var dateCreated = ""
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
                let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                dateCreated = Date.sm_convertDateToString(date: creationDate, formatter: "dd.MM.yy HH:mm")
                }
           return DP_PhotoModel(name: "", date: dateCreated, path: url)
        }
        
        models = models.sorted(by: {$0.date > $1.date})
        return models
    }
    
    ///  Scale and orient picture for Vision framework
    ///
    ///  From [Detecting Objects in Still Images](https://developer.apple.com/documentation/vision/detecting_objects_in_still_images).
    ///
    ///  - Parameter image: Any `UIImage` with any orientation
    ///  - Returns: An image that has been rotated such that it can be safely passed to Vision framework for detection.

    func dp_scaleAndOrient(image: UIImage) -> UIImage {

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

    func dp_convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {
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
 
    func dp_createViewImage(rect: CGRect, bounds: CGRect, viewFrame: CGRect, text: String, inputImage: UIImage) -> UIView {
    
        let newRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height / 7 * 5)
        
        guard var croppedImage = cropImage(image: inputImage, toRect: newRect),
              let cgImage = croppedImage.cgImage else { return UIView()}
           
        let beginImage = CIImage(cgImage: cgImage)
        croppedImage = applyBlurFilter(aCIImage: beginImage, val: 20)
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue((70.0), forKey: kCIInputRadiusKey)

        let rectLb = newRect
        let screen = viewFrame
        let width = screen.width / bounds.width
        let height = screen.height / bounds.height

        let lbX = rectLb.minX.rounded() * width
        let lbY = rectLb.minY.rounded() * height

        let lbHeight = rectLb.height * height
        let lbWidth = rectLb.width * width

        let view = UIImageView(frame: CGRect(x: lbX, y: lbY, width: lbWidth, height: lbHeight))
        view.image = croppedImage

        let lb = UILabel(frame: CGRect(x: 0, y: 0, width: lbWidth, height: lbHeight))
        lb.textColor = .black
        lb.textAlignment = .center
        lb.text = text
        lb.font = lb.font.withSize(lb.frame.height / 5 * 3)

        view.addSubview(lb)

        return view
    }
    
    func applyBlurFilter(aCIImage: CIImage, val: CGFloat) -> UIImage {
            let clampFilter = CIFilter(name: "CIAffineClamp")
            clampFilter?.setDefaults()
            clampFilter?.setValue(aCIImage, forKey: kCIInputImageKey)

            let blurFilter = CIFilter(name: "CIGaussianBlur")
            blurFilter?.setValue(clampFilter?.outputImage, forKey: kCIInputImageKey)
            blurFilter?.setValue(val, forKey: kCIInputRadiusKey)

            let rect = aCIImage.extent
            if let output = blurFilter?.outputImage {
                let context = CIContext(options: nil)
                if let cgimg = context.createCGImage(output, from: rect) {
                    let processedImage = UIImage(cgImage: cgimg)
                    return processedImage
                }
            }
            fatalError()
        }
 
    func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage? {
        // Ensure the rectangle is within the bounds of the image
        guard let cgImage = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        // Create a new UIImage from the cropped CGImage
        let croppedImage = UIImage(cgImage: cgImage)
        
        return croppedImage
    }
}

struct DP_ResponseTranslateModel {
    var rects: [CGRect]
    var imageBounds: CGRect
    var texts: [String]
}
