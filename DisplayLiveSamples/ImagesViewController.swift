//
//  ImagesViewController.swift
//  DisplayLiveSamples
//
//  Created by Andrew Ashurow on 13.10.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBAction func back(sender: AnyObject) {
        print("dismissViewControllerAnimated")
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        wrapper.prepare()
    }
    
    
    let wrapper = DlibWrapper()
    
    @IBAction func findFaces(sender: AnyObject) {
        let
        image = imageView.image!.CGImage,
        size = imageView.image!.size
        
        let imageBuffer: CVPixelBufferRef = Converters.pixelBufferFromCGImage(image!, withSize: size)!
        wrapper.drawFaceLandMarksOnImageBuffer(imageBuffer)
        
        imageView.image = Converters.UIImageFromPixelBuffer(imageBuffer)
    }
   
    
}
