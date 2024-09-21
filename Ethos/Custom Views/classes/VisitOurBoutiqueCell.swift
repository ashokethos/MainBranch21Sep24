//
//  VisitOurBoutiqueCell.swift
//  Ethos
//
//  Created by mac on 30/06/23.
//

import UIKit
import AVKit
import Mixpanel

class VisitOurBoutiqueCell: UITableViewCell {
    
    @IBOutlet weak var btnBottom: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var superController : UIViewController?
    var superTableView : UITableView?
    var playerLayer : AVPlayerLayer = AVPlayerLayer()
    var dispatchItem : DispatchWorkItem?
    var viewModel : GetVideoViewModel = GetVideoViewModel()
    var delegate : SuperViewDelegate?
    
    var videoStartime : Date?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel.delegate = self
        btnBottom.setAttributedTitleWithProperties(title: "VISIT OUR BOUTIQUE", font: EthosFont.Brother1816Regular(size: 12), alignment: .center, foregroundColor: .black, backgroundColor: .clear, lineHeightMultiple: 1.5, kern: 1)
    }
    
    @IBAction func btnBottomDidTapped(_ sender: UIButton) {
        
        Mixpanel.mainInstance().trackWithLogs(event: "Pre Owned Visit Boutique Clicked", properties: [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
            EthosConstants.Platform : EthosConstants.IOS
        ])
        
        
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.visitOurBoutique])
    }
    
    override func prepareForReuse() {
        self.playerLayer.player?.pause()
        self.imageViewMain.image = nil
        self.playerLayer.player = nil
        self.playerLayer.removeFromSuperlayer()
        self.btnPlayPause.isSelected = false
        self.btnPlayPause.isHidden = false
        self.videoStartime = nil
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
    
    @objc func tapOnImageOverlay(_ : UITapGestureRecognizer) {
        self.btnPlayPause.isHidden = false
        dispatchItem?.cancel()
        dispatchItem = DispatchWorkItem {
            UIView.animate(withDuration: 1) {
                if self.btnPlayPause.isSelected == true {
                    self.btnPlayPause.isHidden = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: dispatchItem ?? DispatchWorkItem(block: {}))
    }
    
    
    
    @IBAction func btnPlayPauseDidTapped(_ sender: UIButton) {
        if !btnPlayPause.isSelected {
            btnPlayPause.isSelected = true
            playerLayer.player?.play()
            self.videoStartime = Date()
            UIView.animate(withDuration: 3) {
                if self.btnPlayPause.isSelected {
                    self.btnPlayPause.isHidden = true
                }
            }
        } else {
            btnPlayPause.isSelected = false
            playerLayer.player?.pause()
            
        }
    }
    
    func addObserverToPlayer() {
        playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            let duration = CMTimeGetSeconds(self.playerLayer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            
            if progress >= 0.99 {
                self.playerLayer.player?.currentItem?.seek(to: CMTime.zero){_ in
                    self.playerLayer.player?.pause()
                    self.btnPlayPause.isSelected = false
                    self.btnPlayPause.isHidden = false
                    
                }
            }
        }
    }
}

extension VisitOurBoutiqueCell : GetVideoModelDelegate {
    func didGetUrl(url: String, image: String, index : IndexPath) {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            if let url = URL(string: url) {
                let player = AVPlayer(url: url)
                self.playerLayer.player = player
                self.playerLayer.videoGravity = .resizeAspectFill
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: self.imageViewMain.frame.width, height: self.imageViewMain.frame.height)
                let tapGesture = UITapGestureRecognizer()
                tapGesture.addTarget(self, action: #selector(self.tapOnImageOverlay(_:)))
                self.imageViewMain.isUserInteractionEnabled = true
                self.imageViewMain.addGestureRecognizer(tapGesture)
                self.imageViewMain.layer.addSublayer(self.playerLayer)
                if (UIApplication.topViewController() as? PreOwnedViewController)?.selectedIndex == 0, let visibleCells = self.superTableView?.visibleCells, visibleCells.contains(self)  {
                    self.btnPlayPause.isSelected = true
                    self.playerLayer.player?.play()
                    self.videoStartime = Date()
                }
               
                self.addObserverToPlayer()
            }
        }
    }
}
