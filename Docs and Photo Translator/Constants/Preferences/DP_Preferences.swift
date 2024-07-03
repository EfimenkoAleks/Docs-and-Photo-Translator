//
//  DP_Preferences.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import Foundation

final class DP_Preferences: DP_PreferencesProtocol {
    
    let defaults = UserDefaults.standard
    
    func dp_setStartLang(_ startLang: String) {
        defaults.setValue(startLang, forKey: DP_ConstantUserDefaultsKeys.startLang)
    }
    
    func dp_getStartLang() -> String? {
        defaults.string(forKey: DP_ConstantUserDefaultsKeys.startLang)
    }
    
    func dp_saveNumberPhoto(number: Int) {
        var arrInt: [Int] = dp_getPhotoNumber()
            if !arrInt.contains(number) {
                arrInt.append(number)
            }
        defaults.setValue(arrInt, forKey: DP_ConstantUserDefaultsKeys.photoNumber)
    }
    
    func dp_getPhotoNumber() -> [Int] {
        if let rez = defaults.array(forKey: DP_ConstantUserDefaultsKeys.photoNumber) as? [Int] {
            return rez
        } else { return [] }
    }
    
    func dp_saveNumberPinedPhoto(number: Int) {
        var arrInt: [Int] = dp_getPinedPhotoNumber()
            if !arrInt.contains(number) {
                arrInt.append(number)
            }
        defaults.setValue(arrInt, forKey: DP_ConstantUserDefaultsKeys.pinedPhotoNumber)
    }
    
    func dp_deletePinedPhoto(arrInt: [Int]) {
        defaults.setValue(arrInt, forKey: DP_ConstantUserDefaultsKeys.pinedPhotoNumber)
    }
    
    func dp_deletePhoto(arrInt: [Int]) {
        defaults.setValue(arrInt, forKey: DP_ConstantUserDefaultsKeys.photoNumber)
    }
    
    func dp_getPinedPhotoNumber() -> [Int] {
        if let rez = defaults.array(forKey: DP_ConstantUserDefaultsKeys.pinedPhotoNumber) as? [Int] {
            return rez
        } else { return [] }
    }
}
