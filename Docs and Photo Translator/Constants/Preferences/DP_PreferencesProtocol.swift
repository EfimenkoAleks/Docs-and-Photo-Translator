//
//  DP_PreferencesProtocol.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 24.06.2024.
//

import Foundation

protocol DP_PreferencesProtocol {
    func dp_saveNumberPhoto(number: Int)
    func dp_getPhotoNumber() -> [Int]
    func dp_setStartLang(_ startLang: String)
    func dp_getStartLang() -> String?
    func dp_saveNumberPinedPhoto(number: Int)
    func dp_getPinedPhotoNumber() -> [Int]
    func dp_deletePinedPhoto(arrInt: [Int])
    func dp_deletePhoto(arrInt: [Int])
}
