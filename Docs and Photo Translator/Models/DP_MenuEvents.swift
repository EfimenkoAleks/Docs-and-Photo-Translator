//
//  DP_MenuEvents.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 09.07.2024.
//

import Foundation

enum DP_MenuEvents {
    case menu
    case choiceLang
    case fromLibrary
    case privaciPolicy
}

extension DP_MenuEvents {
    
    var title: String {
        switch self {

        case .menu: return "Menu"
        case .choiceLang: return "Select language"
        case .fromLibrary: return "From gallery"
        case .privaciPolicy: return "Privacy Policy"
        }
    }
    
    var image: String {
        switch self {

        case .menu: return "menu"
        case .choiceLang: return "list.bullet.rectangle.portrait"
        case .fromLibrary: return "photo.on.rectangle.angled"
        case .privaciPolicy: return "lock.shield"
        }
    }
}
