//
//  ReadListCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit
import AVFoundation
import SkeletonView

class ReadListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageThumNail: UIImageView!
    @IBOutlet weak var imageOverLay: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var disclosureBtn: UIButton!
    @IBOutlet weak var btnReadMore: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.skeletonTextNumberOfLines = 1
        self.btnReadMore.isHiddenWhenSkeletonIsActive = true
        self.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(18)
        
        self.btnReadMore.setAttributedTitleWithProperties(title: EthosConstants.ReadMore.uppercased(), font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .white,  kern: 1)
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.imageThumNail.image = nil
    }
    
    var article : Article? {
        didSet {
            self.lblTitle.setAttributedTitleWithProperties(title:  article?.title ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), foregroundColor: .white, lineHeightMultiple: 1.25, kern: 0.1)
            
            
            if let mainAsset = article?.assets?.first , mainAsset.type == AssetType.image.rawValue {
                if mainAsset.url != "", let url = URL(string: mainAsset.url ?? "") {
                    self.imageThumNail.kf.setImage(with: url)
                }  else if let url = URL(string: EthosIdentifiers.articlePlaceHolderUrl) {
                    self.imageThumNail.kf.setImage(with: url)
                }
            }
            self.contentView.layoutIfNeeded()
        }
    }
    
    var articleCategory : ArticlesCategory? {
        didSet {
            self.lblTitle.setAttributedTitleWithProperties(title: articleCategory?.name ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), foregroundColor: .white, lineHeightMultiple: 1.25, kern: 0.1)
            
            if let mainAsset = articleCategory?.image {
                if mainAsset != "", let url = URL(string: mainAsset) {
                    self.imageThumNail?.kf.setImage(with: url)
                } else if let url = URL(string: EthosIdentifiers.articlePlaceHolderUrl){
                    self.imageThumNail.kf.setImage(with: url)
                }
            }
        }
    }
    
   
    
    func getImageFromAsset(url : URL) {
        let asset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        let time = CMTimeMake(value: 1, timescale: 2)
        let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        if let thumbnail = img {
            let frameImg  = UIImage(cgImage: thumbnail)
            DispatchQueue.main.async {
                self.imageThumNail.image = frameImg
            }
        }
    }
}
