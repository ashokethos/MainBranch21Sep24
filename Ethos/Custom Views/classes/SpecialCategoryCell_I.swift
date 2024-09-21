//
//  ShoppingSpecialCategoryCell.swift
//  Ethos
//
//  Created by mac on 07/07/23.
//

import UIKit
import Mixpanel

class SpecialCategoryCell_I: UITableViewCell {
    
    var delegate : SuperViewDelegate?
    
    
    @IBOutlet weak var watchWindersLbl: UILabel!
    
    @IBOutlet weak var shopNow1: UIButton!
    
    @IBOutlet weak var shopNow2: UIButton!
    
    @IBOutlet weak var shopNow3: UIButton!
    
    @IBOutlet weak var shopNow4: UIButton!
    
    @IBOutlet weak var shopNow5: UIButton!
    
    @IBOutlet weak var btnShopNow1: UIButton!
    
    @IBOutlet weak var btnShopNow2: UIButton!
    
    @IBOutlet weak var btnShopNow3: UIButton!
    
    @IBOutlet weak var btnShopNow4: UIButton!
    
    @IBOutlet weak var btnShopNow5: UIButton!
    
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var lbl3: UILabel!
    
    @IBOutlet weak var lbl4: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imageViewTopImage: UIImageView!
    
    @IBOutlet weak var imageViewSecondImage: UIImageView!
    
    @IBOutlet weak var imageViewThirdImage: UIImageView!
    
    @IBOutlet weak var imageViewFourthImage: UIImageView!
    
    @IBOutlet weak var imageViewFifthImage: UIImageView!
    
    @IBOutlet weak var lblTopImage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle.setAttributedTitleWithProperties(title: "LIFESTYLE", font: EthosFont.Brother1816Medium(size: 12), kern: 1)
        
        watchWindersLbl.setAttributedTitleWithProperties(title: Userpreference.lifestyleDescription ?? "", font: EthosFont.Brother1816Regular(size: 14), foregroundColor: .white, lineHeightMultiple: 1.13, kern: 0.1)
        
        shopNow1.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 12), foregroundColor: .white, kern: 0.5)
        
        shopNow2.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        shopNow3.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        
        shopNow4.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        
        shopNow5.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        
        self.lblTopImage.setAttributedTitleWithProperties(title: Userpreference.lifeStyleTopImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 32), alignment: .left, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl1.setAttributedTitleWithProperties(title: Userpreference.lifeStyleSecondImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl2.setAttributedTitleWithProperties(title: Userpreference.lifeStyleThirdImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl3.setAttributedTitleWithProperties(title: Userpreference.lifeStyleFourthImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl4.setAttributedTitleWithProperties(title: Userpreference.lifeStyleFifthImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        if let image = Userpreference.lifeStyleTopImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let imgUrl = URL(string: image) {
            imageViewTopImage.kf.setImage(with: imgUrl)
        }
        
        if let image = Userpreference.lifeStyleSecondImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let imgUrl = URL(string: image) {
            imageViewSecondImage.kf.setImage(with: imgUrl)
        }
        
        if let image = Userpreference.lifeStyleThirdImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let imgUrl = URL(string: image) {
            imageViewThirdImage.kf.setImage(with: imgUrl)
        }
        
        if let image = Userpreference.lifeStyleFourthImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let imgUrl = URL(string: image) {
            imageViewFourthImage.kf.setImage(with: imgUrl)
        }

        if let image = Userpreference.lifeStyleFifthImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let imgUrl = URL(string: image) {
            imageViewFifthImage.kf.setImage(with: imgUrl)
        }
        
    }
    
    
    @IBAction func routeToWatchWinders(_ sender: UIButton) {
        
       
       
        
        switch sender {
            
        case btnShopNow1 :
            
            if let category = Userpreference.lifeStyleTopImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.lifeStyleShopsClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.lifeStyleTopImageTitle
                ])
            }
            
            
            
        case btnShopNow2 :

            if let category = Userpreference.lifeStyleSecondImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.lifeStyleShopsClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.lifeStyleSecondImageTitle
                ])
            }
            
        case btnShopNow3 :
            
            if let category = Userpreference.lifeStyleThirdImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.lifeStyleShopsClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.lifeStyleThirdImageTitle
                ])
            }
            
        case btnShopNow4 :

            
            if let category = Userpreference.lifeStyleFourthImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.lifeStyleShopsClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.lifeStyleFourthImageTitle
                ])
            }
            
            
        case btnShopNow5 :             
            if let category = Userpreference.lifeStyleFifthImageCategoryId, let id = category.categoryId {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.lifeStyleShopsClicked, properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.Category : Userpreference.lifeStyleFifthImageTitle
            ])
        }
            
        
            
        default : break
            
        }
    }
}
