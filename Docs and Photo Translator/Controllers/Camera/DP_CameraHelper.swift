//
//  DP_CameraHelper.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import Foundation

final class DP_CameraHelper: NSObject {
    
    private var preferens: DP_PreferencesProtocol
    private var screenNumber = 0
    
    init(preferens: DP_PreferencesProtocol = DP_Preferences()) {
        self.preferens = preferens
        super.init()
    }
    
    func dp_saveNewPhoto(data: Data) {
        let lastNumber = dp_getNumber()
        screenNumber = lastNumber.last ?? 0
        screenNumber += 1
        
        _ = DP_FileManager.shared.dp_saveData(data, path: "screen\(screenNumber)")
        preferens.dp_saveNumberPhoto(number: screenNumber)
    }
    
    func dp_getNumber() -> [Int] {
        preferens.dp_getPhotoNumber()
    }
}
