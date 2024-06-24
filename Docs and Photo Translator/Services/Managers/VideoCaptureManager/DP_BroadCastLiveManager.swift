//
//  DP_BroadCastLiveManager.swift
//  Docs and Photo Translator
//
//  Created by Aleksandr on 22.06.2024.
//

import UIKit
import CoreMedia

final class DP_BroadCastLiveManager: NSObject {

    func convert(cmage: CIImage) -> UIImage {
         let context = CIContext(options: nil)
         let cgImage = context.createCGImage(cmage, from: cmage.extent)!
         let image = UIImage(cgImage: cgImage)
         return image
    }
    
    func sm_getBuferForWrite(bufer: CMSampleBuffer) -> UIImage? {
 
            let imageBuffer = CMSampleBufferGetImageBuffer(bufer)!
            let ciimage = CIImage(cvPixelBuffer: imageBuffer)
            let image = self.convert(cmage: ciimage)
        
        return image
    }
}
