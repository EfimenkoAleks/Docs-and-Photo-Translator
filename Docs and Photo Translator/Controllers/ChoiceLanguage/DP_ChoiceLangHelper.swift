//
//  DP_ChoiceLangHelper.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 02.07.2024.
//

import Foundation

final class DP_ChoiceLangHelper: NSObject {
    
    private var preferens: DP_PreferencesProtocol
    
    init(preferens: DP_PreferencesProtocol = DP_Preferences()) {
        self.preferens = preferens
        super.init()
    }
    
    func dp_setStartLang(_ lang: String) {
        preferens.dp_setStartLang(lang)
    }
}
