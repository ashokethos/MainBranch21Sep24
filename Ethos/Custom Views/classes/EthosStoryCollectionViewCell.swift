//
//  CollectionViewCell.swift
//  Ethos
//
//  Created by mac on 05/09/23.
//

import UIKit
import AVKit
import WebKit
import Mixpanel
import SkeletonView

class EthosStoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnAction: UILabel!
    @IBOutlet weak var imageStory: UIImageView!
    @IBOutlet weak var imageOverLay: UIImageView!
    @IBOutlet weak var btnPausePlay: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var constraintSpacingBannerDescriptionAndCTA: NSLayoutConstraint!
    @IBOutlet weak var viewBtnAction: UIView!
    
    var superCollectionView : UICollectionView?
    var masterTableView : UITableView?
    var superCell : UITableViewCell?
    var totalDataCount = 0
    var index : Int?
    var indexPath : IndexPath?
    var isForPreOwned = false
    var avPlayerLayer = AVPlayerLayer()
    var delegate : SuperViewDelegate?
    var videoModel = GetVideoViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videoModel.delegate = self
        self.progressView.progress = 0.0001
        
        self.lblDescription.skeletonLineSpacing = 5
        self.lblDescription.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblDescription.skeletonTextNumberOfLines = 2
       
        self.lblTitle.skeletonLineSpacing = 5
        self.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblTitle.skeletonTextNumberOfLines = 1
        
    }
    
    override func prepareForReuse() {
        self.isForPreOwned = false
        self.contentView.hideSkeleton()
        self.constraintSpacingBannerDescriptionAndCTA.constant = 20
        self.progressView.progress = 0.0001
        self.imageStory.image = nil
        self.indicator.stopAnimating()
        self.lblTitle.setAttributedTitleWithProperties(
            title:  "",
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
            alignment: .center,
            foregroundColor: .white,
            lineHeightMultiple: 1.33,
            kern: 0.1
        )
        
        self.lblDescription.setAttributedTitleWithProperties(
            title: "",
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
            alignment: .center,
            foregroundColor: .white,
            lineHeightMultiple: 1.33,
            kern: 0.1
        )
        
        self.btnAction.setAttributedTitleWithProperties(
            title: "",
            font: EthosFont.Brother1816Regular(size: 10),
            alignment: .center,
            foregroundColor: .white,
            kern: 0.5
        )
        
        self.avPlayerLayer.player?.pause()
        avPlayerLayer.removeFromSuperlayer()
        self.progressView.progress = 0.0001
    }
    
    var story : Banner? {
        didSet {
            
            self.progressView.progress = 0.0001
            
            var btnTitle = EthosConstants.KnowMore.uppercased()
            
            self.constraintSpacingBannerDescriptionAndCTA.constant = 20
            
            switch story?.bannerType ?? "" {
            case BannerType.Article.rawValue : btnTitle = EthosConstants.KnowMore.uppercased()
                
                self.lblTitle.setAttributedTitleWithProperties(
                    title: self.story?.category?.uppercased() ?? "",
                    font: EthosFont.Brother1816Bold(size: 10),
                    alignment: .center,
                    foregroundColor: .white,
                    lineHeightMultiple: 1.67,
                    kern: 0.5
                )
                
                self.lblDescription.setAttributedTitleWithProperties(
                    title:  self.story?.title ?? "",
                    font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
                    alignment: .center,
                    foregroundColor: .white,
                    lineHeightMultiple: 1.33,
                    kern: 0.1
                )
                
            case BannerType.Product.rawValue : btnTitle = self.isForPreOwned ? EthosConstants.DiscoverNow.uppercased() : EthosConstants.ShopNow.uppercased()
                
                self.lblTitle.setAttributedTitleWithProperties(
                    title: self.story?.category?.uppercased() ?? "",
                    font: EthosFont.Brother1816Bold(size: 10),
                    alignment: .center,
                    foregroundColor: .white,
                    lineHeightMultiple: 1.67,
                    kern: 0.5
                )
                
                self.lblDescription.setAttributedTitleWithProperties(
                    title:  self.story?.title ?? "",
                    font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
                    alignment: .center,
                    foregroundColor: .white,
                    lineHeightMultiple: 1.33,
                    kern: 0.1
                )
                
            case BannerType.Custom.rawValue :
                
                self.lblTitle.setAttributedTitleWithProperties(
                    title: self.story?.title ?? "",
                    font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
                    alignment: .center,
                    foregroundColor: .white,
                    lineHeightMultiple: 1.25,
                    kern: 0.5
                )
                
                self.lblDescription.setAttributedTitleWithProperties(
                    title:  self.story?.bannerDescription ?? "",
                    font: EthosFont.Brother1816Regular(size: 14),
                    alignment: .center,
                    foregroundColor: .white,
                    lineHeightMultiple: 1.13,
                    kern: 0.1
                )
                
                if self.story?.bannerDescription == "" || self.story?.bannerDescription == nil ||  self.story?.bannerDescription == "<null>" || self.story?.bannerDescription == "null" {
                    self.constraintSpacingBannerDescriptionAndCTA.constant = 0
                } else {
                    self.constraintSpacingBannerDescriptionAndCTA.constant = 20
                }
                
                switch story?.linkType ?? "" {
                case EthosConstants.article : btnTitle = EthosConstants.KnowMore.uppercased()
                    
                case EthosConstants.product : btnTitle = self.isForPreOwned ? EthosConstants.DiscoverNow.uppercased() : EthosConstants.ShopNow.uppercased()
                    
                case EthosConstants.category : btnTitle = EthosConstants.KnowMore.uppercased()
                    
                default:
                    btnTitle = EthosConstants.KnowMore.uppercased()
                }
                
                
            default:
                btnTitle = EthosConstants.KnowMore.uppercased()
            }
            
            if self.lblTitle.attributedText?.string.isEmpty ?? true && self.lblDescription.attributedText?.string.isEmpty ?? true {
                self.viewBtnAction.isHidden = true
            } else {
                self.viewBtnAction.isHidden = false
            }
            
            self.btnAction.setAttributedTitleWithProperties(
                title: btnTitle,
                font: EthosFont.Brother1816Regular(size: 10),
                alignment: .center,
                foregroundColor: .white,
                kern: 0.5
            )
            
            if story?.type == "image" {
                if let imageUrl = (story?.bannerType == BannerType.Article.rawValue) ? (self.story?.url) : (self.story?.image) , imageUrl != "" {
                    startImageStoryFromUrl(url: imageUrl)
                }
            } else if story?.type == "video" {
                if let videoUrl = self.story?.url, videoUrl != "",
                   videoUrl.contains("player.vimeo.com"){
                    let id = videoUrl.getVimeoId()
                    self.indicator.startAnimating()
                    videoModel.getVideoUrlFromId(id: id, index: self.indexPath ?? IndexPath())
                } else if let videoUrl = self.story?.url, videoUrl != "" {
                    startVideoStoryFromUrl(url: videoUrl)
                }
            }
        }
    }
    
    func startImageStoryFromUrl(url : String) {
        indicator.startAnimating()
        self.btnPausePlay.isHidden = true
        UIImage.loadFromURL(url: url) { image in
            self.indicator.stopAnimating()
            self.imageStory.image = image
            DispatchQueue.main.async {
                UIView.animate(
                    withDuration: 10,
                    animations: {
                        self.progressView.progress += 1
                        self.contentView.layoutIfNeeded()
                        
                    }) { animated in
                        if let shouldChangeStory = self.superCollectionView?.visibleCells.contains(self),
                           let currentIndex = self.index,
                           self.totalDataCount - 1  > currentIndex,
                           shouldChangeStory == true {
                            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.changeStory])
                        } else {
                            if let index = self.index  {
                                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.changeToTop, EthosKeys.currentIndex : index])
                            }
                        }
                    }
            }
        }
    }
    
    func startVideoStoryFromUrl(url : String) {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            if let url = URL(string: url)  {
                let avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
                self.avPlayerLayer.player = avPlayer
                self.avPlayerLayer.videoGravity = .resizeAspectFill
                self.avPlayerLayer.frame = self.imageStory.frame
                self.imageStory.layer.addSublayer(self.avPlayerLayer)
                self.btnPausePlay.isHidden = false
                if let superCell = self.superCell, let masterTableView = self.masterTableView {
                    let masterCellinView = masterTableView.visibleCells.contains(superCell)
                    let selfInSuperCollectionView = self.superCollectionView?.visibleCells.contains(self) ?? false
                    
                    if (masterCellinView && selfInSuperCollectionView) {
                        self.avPlayerLayer.player?.play()
                        self.btnPausePlay.isSelected = true
                        self.addObserverToPlayer()
                    }
                }
            }}
    }
    
    
    @IBAction func btnPausePlayDidTapped(_ sender: UIButton) {
        if avPlayerLayer.player != nil {
            if self.btnPausePlay.isSelected == false {
                self.btnPausePlay.isSelected = true
                self.avPlayerLayer.player?.play()
            } else {
                self.btnPausePlay.isSelected = false
                self.avPlayerLayer.player?.pause()
            }
        }
    }
    
    func addObserverToPlayer() {
        avPlayerLayer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            
            let duration = CMTimeGetSeconds(self.avPlayerLayer.player?.currentItem?.duration ?? CMTime())
            
            let progress = Float((CMTimeGetSeconds(time) / duration))
            self.progressView.progress = progress
            if progress == 1 {
                self.btnPausePlay.isSelected = false
                if let shouldChangeStory = self.superCollectionView?.visibleCells.contains(self),
                   let currentIndex = self.index,
                   self.totalDataCount - 1  > currentIndex,
                   shouldChangeStory == true {
                    self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.changeStory])
                } else {
                    if let index = self.index {
                        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.changeToTop, EthosKeys.currentIndex : index])
                    }
                }
            }
        }
    }
    
    
    @IBAction func didTapActionBtn(_ sender: UIButton) {
        if let id = self.story?.id, let type = self.story?.bannerType {
            if type == BannerType.Article.rawValue {
                
                Mixpanel.mainInstance().trackWithLogs(event: "Article Click", properties: [EthosConstants.ArticleID : id, "Title" : self.story?.bannerDescription])
                
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleDetail, EthosKeys.value : id, EthosKeys.forStoryRoute : true, EthosKeys.story : self.story])
               
            }
            
            if type == BannerType.Product.rawValue, let sku = self.story?.sku {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProductDetails, EthosKeys.value : sku, EthosKeys.forStoryRoute : true, EthosKeys.story : self.story])
            }
            
            if type == BannerType.Custom.rawValue {
                if let linkType = self.story?.linkType, let value = self.story?.value {
                    
                    if linkType == "article" {
                        guard let id = Int(value) else { return }
                        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleDetail, EthosKeys.value : id, EthosKeys.forStoryRoute : true, EthosKeys.story : self.story])
                       
                    }
                    
                    if  linkType == "product" {
                        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProductDetails, EthosKeys.value : value, EthosKeys.forStoryRoute : true, EthosKeys.story : self.story])
                    }
                    
                    if linkType == "category"  {
                        guard let id = Int(value) else { return }
                        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts , EthosKeys.categoryName : self.story?.title ?? "", EthosKeys.categoryId : id, EthosKeys.forStoryRoute : true, EthosKeys.story : self.story])
                        
                    }
                }
            }
        }
    }
}

extension EthosStoryCollectionViewCell : GetVideoModelDelegate {
    func didGetUrl(url : String, image : String, index : IndexPath) {
        if index == self.indexPath {
            startVideoStoryFromUrl(url: url)
        }
    }
}


