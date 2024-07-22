//
//  DP_TabbarModels.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import Foundation

typealias DP_TabbarModelsExtension = DP_TabbarModels

enum DP_TabbarModels: CaseIterable {
    case photo
    case text
    case camera
}

extension DP_TabbarModelsExtension {
    var image: String {
        switch self {
        case .photo: return "home"
        case .text: return "text"
        case .camera: return "camera"
        }
    }

    var title: String {
        switch self {
        case .photo: return ""
        case .text: return ""
        case .camera: return ""
        }
    }
}
