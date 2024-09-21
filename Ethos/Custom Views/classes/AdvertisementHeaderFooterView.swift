//
//  AdvertisementHeaderFooterView.swift
//  Ethos
//
//  Created by mac on 07/12/23.
//

import UIKit
import AVFoundation

class AdvertisementHeaderFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var imageViewAd: UIImageView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblAdDescription: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnPausePlay: UIButton!
    @IBOutlet weak var btnActionDisclosure: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoModel.delegate = self
    }
    
    let viewModel = UserActivityViewModel()
    let videoModel = GetVideoViewModel()
    var playerLayer : AVPlayerLayer = AVPlayerLayer()
    var delegate : SuperViewDelegate?
    
    var superTableView : UITableView?
    var superViewController : UIViewController?
    
    var advertisment : Advertisement? {
        didSet {
            
            self.lblHeading.setAttributedTitleWithProperties(
                title: "Advertisment".uppercased(),
                font: EthosFont.Brother1816Regular(size: 10),
                alignment: .center,
                foregroundColor: EthosColor.darkGrey,
                kern: 0.5
            )
            
            self.lblAdDescription.setAttributedTitleWithProperties(
                title: advertisment?.title?.replacingOccurrences(of: "<br />", with: "\n") ?? "",
                font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
                alignment: .center,
                foregroundColor: .white,
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            
            btnAction.setAttributedTitleWithProperties(
                title: EthosConstants.AdSpot,
                font: EthosFont.Brother1816Regular(size: 10),
                alignment: .center,
                foregroundColor: .white,
                kern: 0.5
            )
            
            if let type = advertisment?.type, let url = advertisment?.url {
                if type == AssetType.image.rawValue {
                    self.startIndicator()
                    self.updateUI(forImage: true)
                    UIImage.loadFromURL(url: url) { image in
                        self.stopIndicator()
                        self.imageViewAd.image = image
                    }
                } else if type == AssetType.video.rawValue {
                    self.updateUI(forImage: false)
                    self.startIndicator()
                    self.videoModel.getVideoUrlFromId(id: url.getVimeoId(), index: IndexPath())
                }
            }
        }
    }
    
    override func prepareForReuse() {
        self.playerLayer.player?.pause()
        self.playerLayer.player = nil
        self.playerLayer.removeFromSuperlayer()
        self.imageViewAd.image = nil
    }
    
    func updateUI(forImage : Bool) {
        self.btnPausePlay.isHidden = forImage
        self.lblAdDescription.isHidden = !forImage
        self.btnAction.isHidden = !forImage
        self.btnActionDisclosure.isHidden = !forImage
    }
    
    func addObserverToPlayer() {
        playerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            let duration = CMTimeGetSeconds(self.playerLayer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            
            if progress == 1 {
                self.playerLayer.player?.currentItem?.seek(to: CMTime.zero){_ in
                    self.playerLayer.player?.pause()
                    self.btnPausePlay.isSelected = false
                }
            }
        }
    }
    
    @IBAction func  btnPlayPauseDidTapped(_ sender : UIButton) {
        self.btnPausePlay.isSelected = !self.btnPausePlay.isSelected
        
        if btnPausePlay.isSelected {
            self.playerLayer.player?.play()
        } else {
            self.playerLayer.player?.pause()
        }
    }
    
    
    @IBAction func btnActionDidTapped(_ sender: UIButton) {
        if let link = self.advertisment?.redirect_link {
            viewModel.getDataFromActivityUrl(url: link)
        }
    }
}


extension AdvertisementHeaderFooterView {
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
        
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
}

extension AdvertisementHeaderFooterView : GetVideoModelDelegate {
    func didGetUrl(url: String, image: String, index : IndexPath) {
        self.stopIndicator()
        DispatchQueue.main.async {
            if let url = URL(string: url) {
                let player = AVPlayer(url: url)
                self.playerLayer.player = player
                self.playerLayer.videoGravity = .resizeAspectFill
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: self.imageViewAd.frame.width, height: self.imageViewAd.frame.height)
                self.imageViewAd.layer.addSublayer(self.playerLayer)
                self.addObserverToPlayer()
               
                for index in self.superTableView?.indexPathsForVisibleRows ?? [] {
                    if let footerView = self.superTableView?.footerView(forSection: index.section), UIApplication.topViewController() == self.superViewController, let rectOfCell = self.superTableView?.rectForFooter(inSection: index.section), let rectOfCellInSuperview = self.superTableView?.convert(rectOfCell, to: self.superTableView?.superview) {
                        if rectOfCellInSuperview.origin.y < footerView.contentView.frame.height - 100, rectOfCellInSuperview.origin.y > 50  {
                            (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.play()
                            (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = true
                        } else {
                            (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
                            (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
                        }
                    }
                }
            }
        }
    }
}
