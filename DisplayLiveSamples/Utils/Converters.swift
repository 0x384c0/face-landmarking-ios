//
//  Converters.swift
//  DisplayLiveSamples
//
//  Created by Andrew Ashurow on 13.10.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit

class Converters {
    
    
    static func pixelBufferFromCGImage(image:CGImage,withSize frameSize:CGSize) -> CVPixelBuffer? {
        let options = [
            "kCVPixelBufferCGImageCompatibilityKey": true,
            "kCVPixelBufferCGBitmapContextCompatibilityKey": true
        ]
        
        var maybePixelBuffer:CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(frameSize.width),
            Int(frameSize.height),
            OSType(kCVPixelFormatType_32ARGB),
            options as CFDictionary,
            &maybePixelBuffer
        )
        
        guard let pixelBuffer = maybePixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pxData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        let rgbColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context:CGContext = CGContext(
            data: pxData,
            width: Int(frameSize.width),
            height: Int(frameSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * image.width,
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
            )!
        
        context.draw(image, in: CGRect(x:0, y:0, width:frameSize.width, height:frameSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    static func UIImageFromPixelBuffer(imageBuffer:CVPixelBuffer) -> UIImage {
        let
        ciImage = CIImage(cvImageBuffer: imageBuffer),
        uiImageOut = UIImage(ciImage: ciImage)
        return uiImageOut
    }
    
}
