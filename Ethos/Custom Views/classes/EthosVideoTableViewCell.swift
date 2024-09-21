//
//  EthosVideoTableViewCell.swift
//  Ethos
//
//  Created by mac on 18/01/24.
//

import UIKit
import AVFoundation
import AVKit
import Mixpanel

class EthosVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UISlider!
    
    var product : Product?
    
    var viewModel : GetVideoViewModel = GetVideoViewModel()
    var playerLayer : AVPlayerLayer = AVPlayerLayer()
    
    override func awakeFromNib() {
        self.playerLayer.isHidden = true
        self.viewModel.delegate = self
        self.progressView.value = 0
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
        self.btnPlayPause.isSelected = false
        self.btnPlayPause.isHidden = false
    }
    
    var productVideo : ProductVideo? {
        didSet {
            if let url = self.productVideo?.url {
                self.indicator.startAnimating()
                let id = url.getVimeoId()
                
                if let title = productVideo?.title {
                    self.lblTitle.setAttributedTitleWithProperties(title: title.uppercased(), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, foregroundColor: .black, kern : 0.5)
                }
                
                self.viewModel.getVideoUrlFromId(id: id, index: IndexPath())
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
                    DispatchQueue.main.async {
                        self.btnPlayPause.isSelected = false
                        self.btnPlayPause.isHidden = false
                    }
                }
            }
        }
    }
    
    @objc func tapOnImageOverlay(_ : UITapGestureRecognizer) {
        self.btnPlayPauseDidTapped(self.btnPlayPause)
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
    
}

extension EthosVideoTableViewCell : GetVideoModelDelegate {
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
