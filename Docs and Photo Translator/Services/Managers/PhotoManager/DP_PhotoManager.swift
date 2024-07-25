//
//  DP_PhotoManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 25.07.2024.
//

import UIKit
import AVFoundation

class DP_PhotoManager: NSObject {
    
    var captureSession: AVCaptureSession?
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    private let sessionQueue = DispatchQueue(label: "session.queue")
    
    var stillImageOutput: AVCapturePhotoOutput!
    var imageHanddler: Block<(UIImage)>?
    
    func startSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Get the front and back-facing camera for taking photos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
        
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        
        // Configure the session with the output for capturing still images
        stillImageOutput = AVCapturePhotoOutput()
        
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        
        sessionQueue.async {
            captureSession.startRunning()
        }
        
    }
    
    func dp_createPhoto(withLight: AVCaptureDevice.FlashMode) {
        // Set photo settings
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = withLight
        
        stillImageOutput.isHighResolutionCaptureEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func stopSesion() {
        captureSession?.stopRunning()
        captureSession = nil
    }
}

extension DP_PhotoManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        
        // Get the image from the photo buffer
        guard let imageData = photo.fileDataRepresentation(),
        let image = UIImage(data: imageData) else { return }
        
        imageHanddler?(image)
    }
}

