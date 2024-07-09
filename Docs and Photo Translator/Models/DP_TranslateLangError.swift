//
//  DP_TranslateLangError.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 09.07.2024.
//

import Foundation

enum DP_TranslateLangError {
    case translateError
    case cantRecognizeLang
}

extension DP_TranslateLangError {
    
    var events: String {
        switch self {

        case .translateError: return "no find lang"
        case .cantRecognizeLang: return "Can't recognize language"
        }
    }
}
