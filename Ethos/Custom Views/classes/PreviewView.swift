//
//  PreviewView.swift
//  Ethos
//
//  Created by Softgrid on 18/07/24.
//

import Foundation
import UIKit
import AVFoundation

class PreviewView: UIImageView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
