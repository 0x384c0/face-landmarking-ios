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
        loading(true)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[unowned self] in
            self.wrapper.prepare()
            self.loading(false)
        }
        
    }
    
    
    let wrapper = DlibWrapper()
    
    @IBAction func findFaces(sender: AnyObject) {
        
        loading(true)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[unowned self] in
            let
            image = self.imageView.image!.CGImage,
            size = self.imageView.image!.size
            
            let imageBuffer: CVPixelBufferRef = Converters.pixelBufferFromCGImage(image!, withSize: size)!
            self.wrapper.drawFaceLandMarksOnImageBuffer(imageBuffer)
            
            dispatch_async(dispatch_get_main_queue()) {[unowned self] in
                self.imageView.image = Converters.UIImageFromPixelBuffer(imageBuffer)
                self.loading(false)
            }
        }
        
        
    }
    
    
    func loading(isLoading:Bool) {
        dispatch_async(dispatch_get_main_queue()) {[unowned self] in
            if isLoading{
                self.presentViewController(UIAlertController(title: "Processing...", message: nil, preferredStyle: .Alert), animated: true, completion: nil)
            } else {
                self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
}
