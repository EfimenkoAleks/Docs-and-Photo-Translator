//
//  DP_CameraHelper.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import UIKit
import Photos

final class DP_CameraHelper: NSObject {
    
    private var preferens: DP_PreferencesProtocol
    private var screenNumber = 0
    
    init(preferens: DP_PreferencesProtocol = DP_Preferences()) {
        self.preferens = preferens
        super.init()
    }
    
    func dp_saveNewPhoto(data: Data) -> URL? {
        var rezUrl: URL?
        let lastNumber = dp_getNumber()
        screenNumber = lastNumber.last ?? 0
        screenNumber += 1
        
        let photo = DP_FileManager.shared.dp_saveData(data, path: "\(screenNumber)")
        preferens.dp_saveNumberPhoto(number: screenNumber)
        switch photo {
        case .loaded(let url):
            rezUrl = url
        default:
            break
        }
        return rezUrl
    }
    
    func dp_getNumber() -> [Int] {
        preferens.dp_getPhotoNumber()
    }
    
    func sm_getLastPhoto(completion: @escaping (PHAsset?) -> Void) {
        var photos: [PHAsset] = []
        sm_fetchAssets { results in
            guard let results = results else { return }
            for i in 0..<results.count {
                let asset = results.object(at: i)
            //    let photo = SM_Photo(asset: asset, isSelected: false)
                photos.append(asset)
            }
            photos = photos.sorted(by: {$0.creationDate ?? Date() < $1.creationDate ?? Date()})
            completion(photos.last)
        }
    }
    
    func sm_fetchAssets(completionHandler: @escaping (PHFetchResult<PHAsset>?) -> Void) {
        var allPhotos: PHFetchResult<PHAsset>?
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                completionHandler(allPhotos)
            default:
                allPhotos = nil
                completionHandler(allPhotos)
            }
        }
    }
}
