//
//  SecondMovementVideoTableViewCell.swift
//  Ethos
//
//  Created by mac on 18/01/24.
//

import UIKit
import AVFoundation
import AVKit
import Mixpanel

class SecondMovementVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UISlider!
    
    var viewModel : GetVideoViewModel = GetVideoViewModel()
    var product : Product?
    var playerLayer : AVPlayerLayer = AVPlayerLayer()
    
    override func awakeFromNib() {
        self.playerLayer.isHidden = true
        self.viewModel.delegate = self
        self.lblTitle.setAttributedTitleWithProperties(title: "WE DO NOT USE STOCK VIDEOS OR IMAGES", font: EthosFont.Brother1816Regular(size: 12), alignment: .center, kern: 0.5)
        progressView.value = 0
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
        self.playerLayer.isHidden = true
        self.progressView.value = 0
        self.playerLayer.player?.pause()
        self.imageViewMain.image = nil
        self.playerLayer.player = nil
        self.playerLayer.removeFromSuperlayer()
    }
    
    var brand : String? {
        didSet {
            if let brand = self.brand {
                self.lblDescription.setAttributedTitleWithProperties(title: "This is an elaborate video of the actual \(brand) on sale at Second Movement, shot by our photographers in our in-house video lab.", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), lineHeightMultiple: 1.25, kern: 0.1)
            }
        }
    }
    
    var videoUrl : String? {
        didSet {
            if let url = videoUrl {
            self.indicator.startAnimating()
               let id = url.getVimeoId()
                self.viewModel.getVideoUrlFromId(id: id, index: IndexPath())
            }
        }
    }
    
    func addObserverToPlayer() {
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
                    self.btnPlayPause.isSelected = false
                    self.btnPlayPause.isHidden = false
                }
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
    
    
    @IBAction func  btnPlayPauseDidTapped(_ sender : UIButton) {
        if !btnPlayPause.isSelected {
            btnPlayPause.isSelected = true
            playerLayer.player?.play()
            btnPlayPause.isHidden = true
            
            Mixpanel.mainInstance().trackWithLogs(
                event: "Product Video Played",
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ProductType : "",
                EthosConstants.ProductName : product?.extensionAttributes?.ethProdCustomeData?.productName,
                EthosConstants.SKU :  product?.sku,
                EthosConstants.Price : product?.price
            ])
        } else {
            btnPlayPause.isSelected = false
            playerLayer.player?.pause()
            btnPlayPause.isHidden = false
        }
    }
    
    @objc func tapOnImageOverlay(_ : UITapGestureRecognizer) {
        self.btnPlayPauseDidTapped(self.btnPlayPause)
    }
}

extension SecondMovementVideoTableViewCell : GetVideoModelDelegate {
    func didGetUrl(url: String, image: String, index : IndexPath) {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            if let url = URL(string: url) {
                
                if let imgURL = URL(string: image) {
                    self.imageViewMain.kf.setImage(with: imgURL)
                }
                
                let player = AVPlayer(url: url)
                self.playerLayer.player = player
                self.playerLayer.videoGravity = .resizeAspectFill
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: self.imageViewMain.frame.width, height: self.imageViewMain.frame.height)
                let tapGesture = UITapGestureRecognizer()
                tapGesture.addTarget(self, action: #selector(self.tapOnImageOverlay(_:)))
                self.imageViewMain.isUserInteractionEnabled = true
                self.imageViewMain.addGestureRecognizer(tapGesture)
                self.imageViewMain.layer.addSublayer(self.playerLayer)
                self.progressView.value = 0
                self.btnPlayPause.isSelected = false
                self.playerLayer.player?.pause()
                self.addObserverToPlayer()
            }
        }
    }
}
