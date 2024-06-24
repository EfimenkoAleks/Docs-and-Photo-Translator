//
//  DP_PhotoHelper.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import Foundation

final class DP_PhotoHelper: NSObject {
    
    private var preferens: DP_PreferencesProtocol
    private var screenNumber = 0
    
    init(preferens: DP_PreferencesProtocol = DP_Preferences()) {
        self.preferens = preferens
        super.init()
    }
    
    func dp_getNumber() -> [Int] {
        preferens.dp_getPhotoNumber()
    }
    
    func dp_getPhotos() -> [DP_PhotoModel] {
        let arrInt = preferens.dp_getPhotoNumber()
        
       let paths = arrInt.compactMap({DP_FileManager.shared.dp_getFileUrlFromPath("screen\($0)")})
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
}
