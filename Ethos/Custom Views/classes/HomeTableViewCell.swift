//
//  HomeTableViewCell.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import Mixpanel
import SkeletonView

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthorNameAndDate: UILabel!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imageOverLay: UIImageView!
    @IBOutlet weak var btnBookmark: UIButton!
    
    @IBOutlet weak var viewRedline: UIView!
    
    
    let tapGesture = UITapGestureRecognizer()
    var dispatchItem : DispatchWorkItem?
    var delegate : SuperViewDelegate?
    var isForPreOwn = false
    var index : IndexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewDuration.isHidden = true
        self.imgThumbnail.image = nil
        self.btnBookmark.isSelected = false
    
        self.lblTitle.isSkeletonable = true
        self.lblCategory.isSkeletonable = true
        self.imgThumbnail.isSkeletonable = true
        self.lblAuthorNameAndDate.isSkeletonable = true
        self.viewRedline.isSkeletonable = true
        self.btnBookmark.isSkeletonable = true
        
        self.lblTitle.skeletonTextNumberOfLines = 2
        self.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblTitle.skeletonLineSpacing = 10
        
        self.lblAuthorNameAndDate.skeletonTextNumberOfLines = 1
        self.lblAuthorNameAndDate.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblAuthorNameAndDate.skeletonLineSpacing = 10
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.isForPreOwn = false
        self.imgThumbnail.image = nil
        self.viewDuration.isHidden = true
        self.imageOverLay.removeGestureRecognizer(self.tapGesture)
        self.btnBookmark.isSelected = false
    }
    
    func showSkeleton() {
        DispatchQueue.main.async {
            self.lblTitle.showAnimatedGradientSkeleton()
            self.showAnimatedGradientSkeleton()
            self.imgThumbnail.showAnimatedGradientSkeleton()
            self.lblAuthorNameAndDate.showAnimatedGradientSkeleton()
            self.btnBookmark.showAnimatedGradientSkeleton()
        }
    }
    
    var article : Article? {
        didSet {
            self.lblCategory.setAttributedTitleWithProperties(
                title: article?.category?.uppercased() ?? "",
                font: EthosFont.Brother1816Regular(size: 10),
                foregroundColor: EthosColor.red,
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
                    lineHeightMultiple: 1.43,
                    kern: 0.1
                )
            }
            
            if article?.video != nil, article?.video != "" {
                self.viewDuration.isHidden = false
            }
            
            if let mainAsset = article?.assets?.first {
                if mainAsset.type == AssetType.image.rawValue {
                    if mainAsset.url != "" , let url = URL(string: mainAsset.url ?? "") {
                        self.imgThumbnail.kf.setImage(with: url)
                    } else if let url = URL(string: EthosIdentifiers.articlePlaceHolderUrl) {
                        self.imgThumbnail.kf.setImage(with: url)
                    }
                }
            }
            
            guard let article = self.article else { return }
            
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
