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
}
