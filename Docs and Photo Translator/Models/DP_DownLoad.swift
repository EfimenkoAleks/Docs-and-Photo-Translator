//
//  DP_DownLoad.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 22.06.2024.
//

import Foundation

enum DP_DownLoad {
    case startDownloading
    case loaded(URL)
    case loadedPhoto(URL)
    case loadedVideo(URL)
    case notSupported
    case error
}
