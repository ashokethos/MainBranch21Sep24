//
//  FavreLeubaHeaderTableViewCell.swift
//  Ethos
//
//  Created by mac on 04/12/23.
//

import UIKit
import AVFoundation
import AVKit

class FavreLeubaHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var imageHeader: UIImageView!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var constraintHeightVideoView: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeightOfImagesView: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: UISlider!
    
    @IBOutlet weak var constraintTopImageHeader: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpacingImageAndLblHeader: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpacingLblHeaderAndImages: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpacingImagesAndLblContent: NSLayoutConstraint!
    
    @IBOutlet weak var constraintBottomLblContent: NSLayoutConstraint!
    
    var playerLayer = AVPlayerLayer()
    var videoModel = GetVideoViewModel()
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoModel.delegate = self
        self.progressView.value = 0
        self.playerLayer.isHidden = true
        progressView.setThumbImage(UIImage.imageWithName(name: EthosConstants.redDot), for: .normal)
        progressView.setThumbImage(UIImage.imageWithName(name: EthosConstants.redDot), for: .highlighted)
            let gr = UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(_:)))
        progressView.addGestureRecognizer(gr)
        
    }
    
    @objc func sliderTapped(_ gesture: UIGestureRecognizer) {
        let slider: UISlider? = (gesture.view as? UISlider)
        if (slider?.isHighlighted)! {
            return
        }
        
        if let width = slider?.bounds.size.width, let max = slider?.maximumValue, let min = slider?.minimumValue {
            let pt: CGPoint = gesture.location(in: slider)
            let percentage = pt.x / width
            let delta = Float(percentage) * Float(max - min)
            let value = min + delta
            slider?.setValue(Float(value), animated: true)
            sliderValueDidChange(self.progressView)
        }
    }
    
    override func prepareForReuse() {
        self.playerLayer.removeFromSuperlayer()
        self.playerLayer.isHidden = true
        self.btnPlayPause.isSelected = false
        self.btnPlayPause.isHidden = true
        self.progressView.isHidden = true
        self.progressView.value = 0
    }
    
    var data : FavreLeubaData? {
        didSet {
    
            if let video = data?.videoUrl, let videoThumbnail = data?.videoThumbnail {
                
                self.constraintHeightVideoView.constant = self.imageHeader.frame.size.width*243/369
                
                if let thumbNailUrl = URL(string: videoThumbnail) {
                    self.imageHeader.kf.setImage(with: thumbNailUrl)
                }
                
                if  video != "" , !video.contains("player.vimeo.com"),  let url = URL(string: video) {
                    initiateVideoLayer(url: url)
                    
                } else if video != "" , video.contains("player.vimeo.com"){
                    let id  = video.getVimeoId()
                    videoModel.getVideoUrlFromId(id: id, index: IndexPath())
                }
                
                self.constraintSpacingImageAndLblHeader.constant = 50
            } else {
                self.constraintHeightVideoView.constant = 0
                self.constraintSpacingImageAndLblHeader.constant = 0
            }
            
            
            if let text = data?.mainText {
                
                if text.image == nil && text.image2 == nil && text.image3 == nil {
                    self.constraintHeightOfImagesView.constant = 0
                    self.constraintSpacingLblHeaderAndImages.constant = 0
                } else {
                    self.constraintSpacingLblHeaderAndImages.constant = 50
                    self.constraintHeightOfImagesView.constant = 500
                }
                
                if let mainTextHeading = text.heading {
                    self.lblHeader.setAttributedTitleWithProperties(title: mainTextHeading, font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),alignment: .center, lineHeightMultiple: 1.5, kern: 0.5)
                    constraintSpacingImagesAndLblContent.constant = 60
                } else {
                    constraintSpacingImagesAndLblContent.constant = 0
                }
                
                if let img1 = text.image, let url = URL(string: img1) {
                    self.img1.kf.setImage(with: url)
                }
                
                if let img2 = text.image2, let url = URL(string: img2) {
                    self.img2.kf.setImage(with: url)
                }
                
                if let img3 = text.image3 , let url = URL(string: img3) {
                    self.img3.kf.setImage(with: url)
                }
                
                if let textDescription = text.text {
                    self.lblContent.setAttributedTitleWithProperties(title: textDescription, font: EthosFont.Brother1816Regular(size: 14), lineHeightMultiple: 1.5, kern: 0.5)
                    self.constraintBottomLblContent.constant = 30
                } else {
                    self.constraintBottomLblContent.constant = 0
                }
                
                DispatchQueue.main.async {
                    self.img1.clipRightCorner(offset: 50)
                    self.img2.clipRightCorner(offset: 50)
                    self.img3.clipRightCorner(offset: 50)
                }
                
                
            } else {
                self.constraintHeightOfImagesView.constant = 0
            }
        }
    }
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        
        self.btnPlayPause.isHidden = false
        
        if let duration = self.playerLayer.player?.currentItem?.duration, duration.seconds.isFinite {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            self.playerLayer.player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                
            })
        }
    }
    
    @IBAction func btnMaximizeDidTapped(_ sender: UIButton) {
        
        let vc = AVPlayerViewController()
        vc.player = self.playerLayer.player
        vc.showsPlaybackControls = true
        self.btnPlayPause.isSelected = false
        self.btnPlayPause.isHidden = false
        UIApplication.topViewController()?.present(vc, animated: true)
        
    }
    
    
    func initiateVideoLayer(url : URL) {
        DispatchQueue.main.async {
            let player = AVPlayer(url: url)
            self.playerLayer.player = player
            self.playerLayer.frame =  CGRect(origin: CGPoint.zero, size: self.imageHeader.frame.size) 
            self.playerLayer.videoGravity = .resizeAspectFill
            self.btnPlayPause.isHidden = false
            self.progressView.isHidden = false
            self.progressView.value = 0
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(self.tapOnImageOverlay(_:)))
            self.imageHeader.isUserInteractionEnabled = true
            self.imageHeader.addGestureRecognizer(tapGesture)
            self.imageHeader.layer.addSublayer(self.playerLayer)
            self.addObseverToPlayer()
        }
        
    }
    
    @objc func tapOnImageOverlay(_ : UITapGestureRecognizer) {
        self.btnPausePlayDidTapped(self.btnPlayPause)
    }
    
    
    func addObseverToPlayer() {
        playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            
            if self.progressView.isHighlighted {
                return
            }
            
            let duration = CMTimeGetSeconds(self.playerLayer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            self.progressView.value = progress
            
            self.playerLayer.isHidden = progress == 0
            
            if progress >= 0.99 {
                self.playerLayer.player?.currentItem?.seek(to: CMTime.zero){_ in
                    self.playerLayer.player?.pause()
                    DispatchQueue.main.async {
                        self.btnPlayPause.isSelected = false
                        self.btnPlayPause.isHidden = false
                    }
                }
            }
        }
    }
    
    
    @IBAction func btnPausePlayDidTapped(_ sender: UIButton) {
        if !btnPlayPause.isSelected {
            btnPlayPause.isSelected = true
            playerLayer.player?.play()
            btnPlayPause.isHidden = true
        } else {
            btnPlayPause.isSelected = false
            playerLayer.player?.pause()
            btnPlayPause.isHidden = false
        }
    }
}

extension FavreLeubaHeaderTableViewCell : GetVideoModelDelegate {
    
    func didGetUrl(url: String, image: String, index : IndexPath) {
        DispatchQueue.main.async {
           if let url = URL(string: url) {
               self.initiateVideoLayer(url: url)
            }
        }
    }
}

