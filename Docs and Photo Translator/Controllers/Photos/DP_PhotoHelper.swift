//
//  DP_PhotoHelper.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit

final class DP_PhotoHelper: NSObject {
    
    private var preferens: DP_PreferencesProtocol
    private var screenNumber = 0
    
    init(preferens: DP_PreferencesProtocol = DP_Preferences()) {
        self.preferens = preferens
        super.init()
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
        let models: [DP_PhotoModel] = paths.map { url -> DP_PhotoModel in
          var dateCreated = ""
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
                let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                dateCreated = Date.sm_convertDateToString(date: creationDate, formatter: "dd.MM.yy HH:mm")
                }
           return DP_PhotoModel(name: "", date: dateCreated, path: url)
        }
        
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
    
    func dp_blurEffect(in rect: CGRect, from image: UIImage, context: CIContext) -> UIImage? {
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
}
