//
//  FeaturedVideoCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 03/07/23.
//

import UIKit
import AVFoundation
import AVKit
import Mixpanel

class FeaturedVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCreationDate: UILabel!
    @IBOutlet weak var imgThumbNail: UIImageView!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var imgOverlay: UIImageView!
    @IBOutlet weak var progressView: UISlider!
    @IBOutlet weak var btnMaximize: UIButton!
    
    var playerLayer = AVPlayerLayer()
    var videoModel = GetVideoViewModel()
    
    var delegate : SuperViewDelegate?
    var index : IndexPath?
    
    var videoStartTime : Date?
    
    var videoId : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videoModel.delegate = self
        self.progressView.value = 0.0001
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
            sliderValueDidChanged(self.progressView)
        }
    }
    
    @IBAction func sliderValueDidChanged(_ sender: UISlider) {
        
        self.btnPlayPause.isHidden = false
        
        if let duration = self.playerLayer.player?.currentItem?.duration, duration.seconds.isFinite {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            
            self.playerLayer.player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                
            })
        }
    }
    
    @IBAction func btnPausePlayDidTapped(_ sender: UIButton) {
        if !btnPlayPause.isSelected {
            btnPlayPause.isSelected = true
            playerLayer.player?.play()
            
            Mixpanel.mainInstance().trackWithLogs(event: "Feature Video Viewed", properties: [
                "Email" : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.Registered : (Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y,
                "Video ID" : self.videoId,
                "Video Title" : self.article?.title,
                "Video Category" : self.article?.category
            ])
            
            self.videoStartTime = Date()
            self.playerLayer.isHidden = false
            UIView.animate(withDuration: 3) {
                self.btnPlayPause.isHidden = true
            }
            
        } else {
            btnPlayPause.isSelected = false
            playerLayer.player?.pause()
            self.playerLayer.isHidden = true
        }
    }
    
    var dispatchItem : DispatchWorkItem?
    
    override func prepareForReuse() {
        self.videoId = nil
        self.videoStartTime = nil
        self.progressView.value = 0.0001
        self.playerLayer.removeFromSuperlayer()
        self.btnPlayPause.isSelected = false
        self.btnPlayPause.isHidden = true
        self.contentView.hideSkeleton()
    }
    
    func initiateVideoLayer(url : URL) {
        DispatchQueue.main.async {
            let player = AVPlayer(url: url)
            self.playerLayer.player = player
            self.playerLayer.frame = self.imgThumbNail.frame
            self.playerLayer.videoGravity = .resizeAspectFill
            self.btnPlayPause.isHidden = false
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(self.tapOnImageOverlay(_:)))
            self.imgOverlay.isUserInteractionEnabled = true
            self.imgOverlay.addGestureRecognizer(tapGesture)
            self.playerLayer.isHidden = true
            self.progressView.value = 0.0001
            self.imgThumbNail.layer.addSublayer(self.playerLayer)
            self.addObseverToPlayer()
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
    
    func addObseverToPlayer() {
        self.playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            
            if self.progressView.isHighlighted {
                return
            }
            
            let duration = CMTimeGetSeconds( self.playerLayer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            self.progressView.value = progress
            if progress == 1 {
                self.playerLayer.player?.currentItem?.seek(to: CMTime.zero){_ in
                    self.btnPlayPause.isSelected = false
                    self.btnPlayPause.isHidden = false
                    self.playerLayer.isHidden = true
                }
            }
        }
    }
    
    @objc func tapOnImageOverlay(_ : UITapGestureRecognizer) {
        print(self.lblCreationDate.frame.minY - self.lblTitle.frame.maxY)
        self.btnPlayPause.isHidden = false
        dispatchItem?.cancel()
        dispatchItem = DispatchWorkItem {
            UIView.animate(withDuration: 1) {
                self.btnPlayPause.isHidden = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: dispatchItem ?? DispatchWorkItem(block: {}))
    }
    
    var article : Article? {
        didSet {
            self.lblCategory.setAttributedTitleWithProperties(
                title: article?.category?.uppercased() ?? "",
                font: EthosFont.Brother1816Regular(size: 10),
                foregroundColor: UIColor(red: 0.392, green: 0.388, blue: 0.392, alpha: 1),
                kern: 0.5
            )
            
            self.lblTitle.setAttributedTitleWithProperties(
                title: article?.title ?? "",
                font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
                foregroundColor: .white,
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            
            if let video = article?.video, video != "" , !video.contains("player.vimeo.com"),  let url = URL(string: video) {
                initiateVideoLayer(url: url)
                
            } else if let video = article?.video, video != "" , video.contains("player.vimeo.com"){
                let id  = video.getVimeoId()
                self.videoId = id
                videoModel.getVideoUrlFromId(id: id, index: self.index ?? IndexPath())
            }
            
            if let mainAsset = article?.assets?.first(where: { element in
                element.type == AssetType.image.rawValue
            }),
               let urlStr = mainAsset.url,
               urlStr != "",
               let url = URL(string: urlStr)   {
                self.imgThumbNail.kf.setImage(with: url)
            }
            
            if let createdDate = article?.createdDate {
                let strCreatedDate = EthosDateAndTimeHelper().getStringFromTimeStamp(timeStamp:createdDate)
                let authorString = NSAttributedString(string: strCreatedDate, attributes: [NSAttributedString.Key.foregroundColor :  UIColor(red: 0.392, green: 0.388, blue: 0.392, alpha: 1), NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14), NSAttributedString.Key.kern : 0.5])
                self.lblCreationDate.attributedText = authorString
            }
        }
    }
    
    
    @IBAction func goToArtcileDetails(_ sender: UIButton) {
        if let id = self.article?.id {
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ArticleClicked, properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ArticleID : id,
                EthosConstants.ArticleTitle : self.article?.title,
                EthosConstants.ArticleCategory : self.article?.category
            ])
            
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleDetail, EthosKeys.value : id])
        }
    }
    
    func getImageFromAsset(url : URL) {
        let asset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTimeMake(value: 5, timescale: 2)
        let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        if let thumbnail = img {
            let frameImg  = UIImage(cgImage: thumbnail)
            DispatchQueue.main.async {
                self.imgThumbNail.image = frameImg
            }
        }
    }
}

extension FeaturedVideoCollectionViewCell : GetVideoModelDelegate {
    
    func didGetUrl(url: String, image: String, index: IndexPath) {
        DispatchQueue.main.async {
            if let url = URL(string: url), index == self.index {
                self.initiateVideoLayer(url: url)
            }
        }
    }
}
