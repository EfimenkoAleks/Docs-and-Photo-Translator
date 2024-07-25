//
//  UIImageView+Extension.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 26.07.2024.
//

import UIKit
import Photos

extension UIImageView{
    func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize, completion: ((UIImage) -> Void)? = nil) {
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
            guard let image = image else { return }
            switch contentMode {
            case .aspectFill:
                self.contentMode = .scaleAspectFill
            case .aspectFit:
                self.contentMode = .scaleAspectFit
            @unknown default:
                self.contentMode = .scaleAspectFit
            }
            self.image = image
            if let completion = completion {
                completion(image)
            }
        }
    }
}
