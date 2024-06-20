//
//  DP_TabBarSelectedItem.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 19.06.2024.
//

import Foundation

typealias DP_TabBarSelectedItemExtension = DP_TabBarSelectedItem

enum DP_TabBarSelectedItem {
    case photo, text
}

extension DP_TabBarSelectedItemExtension {

    var selected: Int {
        switch self {
        case .photo: return 0
        case .text: return 1
        }
    }
}
