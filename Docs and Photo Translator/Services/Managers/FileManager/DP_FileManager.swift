//
//  DP_FileManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 22.06.2024.
//

import Foundation

class DP_FileManager {
    
    static let shared: DP_FileManager = DP_FileManager()
    private let fileManager = FileManager.default
    
    func dp_getFileUrlFromPath(_ path: String) -> URL? {
        
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        let fileURL = documentsDirectory.appendingPathComponent(path)
        return fileURL
    }
    
    func dp_saveData(_ data: Data, path: String) -> DP_DownLoad {
        
        guard let fileURL = dp_getFileUrlFromPath(path) else { return .error }
        
        if !fileManager.fileExists(atPath: fileURL.path) {
            do {
                try data.write(to: fileURL)
                return .loaded(fileURL)
            } catch {
                return .error
            }
        } else if fileManager.fileExists(atPath: fileURL.path) {
            return .loaded(fileURL)
        } else {  return .error }
    }
}
