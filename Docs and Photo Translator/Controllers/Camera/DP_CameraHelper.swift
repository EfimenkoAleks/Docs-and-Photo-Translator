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
    
    func dp_getImageFromUrl(path: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: path)
             return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    func dp_getPhotos(completion: @escaping ([DP_Pickture]) -> Void) {
        let arrInt = preferens.dp_getPhotoNumber()
        
       let paths = arrInt.compactMap({DP_FileManager.shared.dp_getFileUrlFromPath("\($0)")})
        var models: [DP_Pickture] = paths.map { url -> DP_Pickture in
          var dateCreated = ""
            if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
                let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                dateCreated = Date.sm_convertDateToString(date: creationDate, formatter: "dd.MM.yy HH:mm:ss")
                }
            return DP_Pickture(image: url, date: dateCreated, isSelected: false)
        }
        
        models = models.sorted(by: {$0.date > $1.date})
     completion(models)
    }
    
    
    func dp_section() -> UICollectionViewCompositionalLayout {
        let width = UIScreen.main.bounds.width
        let itemWidth = (width - 32) / 3
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),heightDimension: .absolute(139))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .absolute(139))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
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
