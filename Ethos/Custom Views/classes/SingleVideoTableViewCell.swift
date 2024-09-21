//
//  SingleVideoTableViewCell.swift
//  Ethos
//
//  Created by mac on 29/08/23.
//

import UIKit
import AVFoundation

class SingleVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var btnPlayPause: UIButton!
    
    var playerLayer : AVPlayerLayer = AVPlayerLayer()
    
    var url : URL? {
        didSet {
            DispatchQueue.main.async {
                if let url = self.url {
                    let player = AVPlayer(url: url)
                    self.playerLayer.player = player
                    self.playerLayer.videoGravity = .resizeAspectFill
                    self.playerLayer.frame = self.videoContainerView.frame
                    self.videoContainerView.layer.addSublayer(self.playerLayer)
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.addTarget(self, action: #selector(self.btnPlayPauseDidTapped(_:)))
                    self.videoContainerView.isUserInteractionEnabled = true
                    self.videoContainerView.addGestureRecognizer(tapGesture)
                    self.btnPlayPause.isHidden = true
                    self.playerLayer.player?.play()
                    self.addObserverToPlayer()
                }
            }
        }
    }
    
    override func prepareForReuse() {
        self.playerLayer.player?.pause()
        self.playerLayer.player = nil
        self.playerLayer.removeFromSuperlayer()
    }
    
    @IBAction func  btnPlayPauseDidTapped(_ sender : UIButton) {
        self.btnPlayPause.isHidden = !self.btnPlayPause.isHidden
        
        if btnPlayPause.isHidden {
            self.playerLayer.player?.play()
        } else {
            self.playerLayer.player?.pause()
        }
    }
    
    
    func addObserverToPlayer() {
        playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            let duration = CMTimeGetSeconds(self.playerLayer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            
            if progress == 1 {
                self.playerLayer.player?.currentItem?.seek(to: CMTime.zero){_ in
                    self.btnPlayPause.isHidden = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
   
    
}
