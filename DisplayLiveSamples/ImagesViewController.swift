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
    @IBAction func back(_ sender: AnyObject) {
        print("dismissViewControllerAnimated")
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        loading(isLoading: true)
        DispatchQueue.global(qos:.default).async {[unowned self] in
            self.wrapper?.prepare()
            self.loading(isLoading: false)
        }
        
    }
    
    
    let wrapper = DlibWrapper()
    
    @IBAction func findFaces(_ sender: AnyObject) {
        
        let
        image = self.imageView.image!.cgImage,
        size = self.imageView.image!.size
        
        loading(isLoading: true)
        DispatchQueue.global(qos:.default).async {[unowned self] in
            
            let imageBuffer: CVPixelBuffer = Converters.pixelBufferFromCGImage(image: image!, withSize: size)!
            self.wrapper?.drawFaceLandMarks(on: imageBuffer)
            
            DispatchQueue.main.async {[unowned self] in
                self.imageView.image = Converters.UIImageFromPixelBuffer(imageBuffer: imageBuffer)
                self.loading(isLoading: false)
            }
        }
        
        
    }
    
    
    func loading(isLoading:Bool) {
        DispatchQueue.main.async {[unowned self] in
            if isLoading{
                self.present(UIAlertController(title: "Processing...", message: nil, preferredStyle: .alert), animated: true, completion: nil)
            } else {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
