//
//  DP_VideoManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 22.06.2024.
//

import Foundation
import CoreMedia

final class DP_VideoManager {
    
    // MARK: - dependencies
    
    private lazy var captureManager = DP_VideoCaptureManager()
    private lazy var videoEncoder = H264Encoder()
    var handlerBufer: ((CMSampleBuffer) -> Void)?

    func startSendingVideoToServer() throws {
        try videoEncoder.configureCompressSession()
        
        captureManager.setVideoOutputDelegate(with: videoEncoder)
        
        videoEncoder.handlerBufer = { [weak self] bufer in
            self?.handlerBufer?(bufer)
        }
    }
    
    func stopSession() {
        captureManager.stopSession()
    }
}
