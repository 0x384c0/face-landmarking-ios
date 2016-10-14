//
//  Converters.swift
//  DisplayLiveSamples
//
//  Created by Andrew Ashurow on 13.10.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit

class Converters {
    
    
    static func pixelBufferFromCGImage(image:CGImageRef,withSize frameSize:CGSize) -> CVPixelBufferRef? {
        let options = [
            "kCVPixelBufferCGImageCompatibilityKey": true,
            "kCVPixelBufferCGBitmapContextCompatibilityKey": true
        ]
        
        let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.alloc(1)
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(frameSize.width),
            Int(frameSize.height),
            OSType(kCVPixelFormatType_32ARGB),
            options,
            pixelBufferPointer
        )
        
        CVPixelBufferLockBaseAddress(pixelBufferPointer.memory!, 0)
        let pxData:UnsafeMutablePointer<(Void)> = CVPixelBufferGetBaseAddress(pixelBufferPointer.memory!)
        
        let rgbColorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        
        let context:CGContextRef = CGBitmapContextCreate(
            pxData,
            Int(frameSize.width),
            Int(frameSize.height),
            8,
            4 * CGImageGetWidth(image),
            rgbColorSpace,
            CGImageAlphaInfo.NoneSkipFirst.rawValue
            )!
        
        CGContextDrawImage(context, CGRectMake(0, 0, frameSize.width, frameSize.height), image)
        CVPixelBufferUnlockBaseAddress(pixelBufferPointer.memory!, 0)
        return pixelBufferPointer.memory!
    }
    
    static func UIImageFromPixelBuffer(imageBuffer:CVPixelBufferRef) -> UIImage {
        let
        ciImage = CIImage(CVImageBuffer: imageBuffer),
        uiImageOut = UIImage(CIImage: ciImage)
        return uiImageOut
    }
    
}