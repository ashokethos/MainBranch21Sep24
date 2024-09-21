//
//  ImageOverLayViewController.swift
//  Ethos
//
//  Created by Softgrid on 18/07/24.
//

import UIKit
import AVFoundation

class ImageOverLayViewController: UIViewController {
    
    @IBOutlet weak var viewPreView: PreviewView!
    @IBOutlet weak var imageViewOverLay: UIImageView!
    @IBOutlet weak var btnCaptureImage: UIButton!
    @IBOutlet weak var btnRotateCamera: UIButton!
    @IBOutlet weak var viewImageTaken: UIView!
    @IBOutlet weak var btnRetake: UIButton!
    @IBOutlet weak var btnProcessImage: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    
    let photoOutput = AVCapturePhotoOutput()
    var session: AVCaptureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var imageTaken = false {
        didSet {
            self.btnCaptureImage.isHidden = self.imageTaken
            self.btnRotateCamera.isHidden = self.imageTaken
            self.viewImageTaken.isHidden = !self.imageTaken
            self.imageViewOverLay.isHidden = self.imageTaken
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnRetake.setAttributedTitleWithProperties(title: "Retake".uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .white, kern: 1)
        self.btnProcessImage.setAttributedTitleWithProperties(title: "Start Scanning".uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, kern: 1)
        self.btnRetake.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.btnProcessImage.setBorder(borderWidth: 1, borderColor: .white, radius: 0)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        configureAndStartSession()
    }
    
    func configureAndStartSession() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput),
              session.canAddOutput(photoOutput)
        else { return }
        session.beginConfiguration()
        session.addInput(videoDeviceInput)
        session.sessionPreset = .photo
        session.addOutput(photoOutput)
        session.commitConfiguration()
        
        self.viewPreView.videoPreviewLayer.session = self.session
        self.viewPreView.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.session.startRunning()
        }
    }
    
    
    @IBAction func rotateCamera(_ sender: UIButton) {
    
        session.beginConfiguration()
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
            if let device = currentInput.device.position == .back ? AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) : AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back), let newVideoInput = try? AVCaptureDeviceInput(device: device) {
                
                session.addInput(newVideoInput)
                session.commitConfiguration()
            }
        } else {
            if let device =  AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back), let newVideoInput = try? AVCaptureDeviceInput(device: device) {
                session.addInput(newVideoInput)
                session.commitConfiguration()
            }
        }
    }
    
    
    
    @IBAction func captureImage(_ sender: UIButton) {
        let photoSettings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = .auto
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    
    @IBAction func btnProcessImageDidTapped(_ sender: UIButton) {
        
    }
    
    
    @IBAction func btnRetakeDidTapped(_ sender: Any) {
        self.imageTaken = false
        DispatchQueue.global(qos: .userInteractive).async {
            self.session.startRunning()
        }
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
}

extension ImageOverLayViewController : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: (any Error)?) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if let data = photo.fileDataRepresentation() {
            let image = UIImage(data: data)
            if session.isRunning {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.session.stopRunning()
                    DispatchQueue.main.async {
                        self.viewPreView.image = image
                        self.imageTaken = true
                    }
                }
            }
        }
    }
}
