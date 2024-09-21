//
//  HomeCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit
import AVFoundation
import SkeletonView

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthorNameAndDate: UILabel!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imageOverLay: UIImageView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var viewSeperator: UIView!
    
    @IBOutlet weak var consstraintSpacingDescriptionAndSeperator: NSLayoutConstraint!
    
    var delegate : SuperViewDelegate?
    
    var isForPreOwn = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.skeletonTextNumberOfLines = 3
        self.lblCategory.skeletonTextNumberOfLines = 1
        self.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblCategory.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(18)
        self.lblAuthorNameAndDate.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblAuthorNameAndDate.numberOfLines = 1
        self.btnBookmark.isHiddenWhenSkeletonIsActive = true
        
        self.viewDuration.isHidden = true
        self.imgThumbnail.image = nil
    
    }
    
    override func prepareForReuse() {
        self.isForPreOwn = false
        self.imgThumbnail.image = nil
        self.viewDuration.isHidden = true
        self.btnBookmark.isSelected = false
    }
    
    var article : Article? {
        didSet {
            
            self.lblCategory.setAttributedTitleWithProperties(
                title: article?.category?.uppercased() ?? "",
                font: EthosFont.Brother1816Regular(size: 10),
                foregroundColor: EthosColor.red,
                lineHeightMultiple: 1,
                kern: 0.5
            )
            
            
            self.lblTitle.setAttributedTitleWithProperties(
                title: article?.title ?? "",
                font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            
            if let createdDate = article?.createdDate {
                let strCreatedDate = EthosDateAndTimeHelper().getStringFromTimeStamp(timeStamp:createdDate)
                self.lblAuthorNameAndDate.setAttributedTitleWithProperties(
                    title: strCreatedDate,
                    font: EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14),
                    foregroundColor: EthosColor.darkGrey,
                    kern: 0.1
                )
            }
            
            if article?.video != nil,  article?.video != "" {
                self.viewDuration.isHidden = false
            }
            
            if let mainAsset = article?.assets?.first {
                if mainAsset.type == AssetType.image.rawValue {
                    if mainAsset.url != "", let urlStr = mainAsset.url?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: urlStr) {
                        self.imgThumbnail.kf.setImage(with: url, placeholder: nil)
                        
                    }  else if let url = URL(string: EthosIdentifiers.articlePlaceHolderUrl) {
                        self.imgThumbnail.kf.setImage(with: url)
                    }
                }
            }
            
            guard let article = self.article else { return  }
            
            DataBaseModel().checkArticleExistsFromArticle(article: article) { exist in
                if exist {
                    self.btnBookmark.isSelected = true
                } else {
                    self.btnBookmark.isSelected = false
                }
            }
        }
    }
    
    @IBAction func btnBookMarkDidTapped(_ sender: UIButton) {
        VibrationHelper.vibrate()
        
        if let article = self.article {
            
            if self.btnBookmark.isSelected {
                DataBaseModel().checkArticleExistsFromArticle(article: article) { found in
                    if found {
                        DataBaseModel().unsaveArticleFromArticle(article: article) {
                            self.btnBookmark.isSelected = false
                        }
                    } else {
                        self.btnBookmark.isSelected = false
                    }
                }
                
            } else {
                DataBaseModel().checkArticleExistsFromArticle(article: article) { found in
                    if !found {
                        DataBaseModel().saveArticleForArticle(article: article, forPreOwn: self.isForPreOwn) {
                            self.btnBookmark.isSelected = true
                        }
                    } else {
                        self.btnBookmark.isSelected = true
                    }
                }
            }
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadTableView])
        }
    }
}
