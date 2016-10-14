//
//  ViewController.swift
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 15.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let sessionHandler = SessionHandler()
    var layer: AVSampleBufferDisplayLayer?
    var cameraFounded = false
    
    @IBOutlet weak var noCamText: UILabel!
    @IBOutlet weak var preview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraFounded = sessionHandler.openSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if cameraFounded{
        if layer == nil{
            layer = sessionHandler.layer
            layer!.frame = preview.bounds
            preview.layer.addSublayer(layer!)
            view.layoutIfNeeded()
            }
        } else {
            noCamText.hidden = false
        }
    }
}

