//
//  DP_TabBarItemType.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import Foundation

enum DP_TabBarItemType: Int {
    case photo, text, camera
 
    var item: DP_TabBarItem {
        switch self {
        case .photo:
            return DP_TabBarItem(
                inTitle: DP_TabbarModels.photo.title,
                inImage: DP_TabbarModels.photo.image,
                inSelectedImage: DP_TabbarModels.photo.image,
                inTag: self.rawValue
            )
        case .text:
            return DP_TabBarItem(
                inTitle: DP_TabbarModels.text.title,
                inImage: DP_TabbarModels.text.image,
                inSelectedImage: DP_TabbarModels.text.image,
                inTag: self.rawValue
            )
        case .camera:
            return DP_TabBarItem(
                inTitle: DP_TabbarModels.camera.title,
                inImage: DP_TabbarModels.camera.image,
                inSelectedImage: DP_TabbarModels.camera.image,
                inTag: self.rawValue
            )
        }
    }
}
