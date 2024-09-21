//
//  SpecialCategoryCell_II.swift
//  Ethos
//
//  Created by SoftGrid on 11/07/23.
//

import UIKit
import Mixpanel

class SpecialCategoryCell_II: UITableViewCell {
    
    var delegate : SuperViewDelegate?
    
    @IBOutlet weak var btnShopNow1: UIButton!
    
    @IBOutlet weak var btnShopNow2: UIButton!
    
    @IBOutlet weak var btnShopNow3: UIButton!
    
    @IBOutlet weak var btnShopNow4: UIButton!
    
    @IBOutlet weak var btnShopNow5: UIButton!
    
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var lbl3: UILabel!
    
    @IBOutlet weak var lbl4: UILabel!
    
    @IBOutlet weak var lbl5: UILabel!
    
    @IBOutlet weak var shopNow1: UIButton!
    
    @IBOutlet weak var shopNow2: UIButton!
    
    @IBOutlet weak var shopNow3: UIButton!
    
    @IBOutlet weak var shopNow4: UIButton!
    
    @IBOutlet weak var shopNow5: UIButton!
    
    
    @IBOutlet weak var imageViewTopImage: UIImageView!
    
    @IBOutlet weak var imageViewSecondImage: UIImageView!
    
    @IBOutlet weak var imageViewThirdImage: UIImageView!
    
    @IBOutlet weak var imageViewFourthImage: UIImageView!
    
    @IBOutlet weak var imageViewFifthImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lbl1.setAttributedTitleWithProperties(title: Userpreference.categoryTopImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl2.setAttributedTitleWithProperties(title: Userpreference.categorySecondImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl3.setAttributedTitleWithProperties(title: Userpreference.categoryThirdImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl4.setAttributedTitleWithProperties(title: Userpreference.categoryFourthImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        lbl5.setAttributedTitleWithProperties(title: Userpreference.categoryFifthImageTitle ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18), alignment: .center, foregroundColor: .white, lineHeightMultiple: 1.33, kern: 0.1)
        
        shopNow1.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 12), foregroundColor: .white, kern: 0.5)
        
        shopNow2.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
       shopNow3.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        
       shopNow4.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        
        shopNow5.setAttributedTitleWithProperties(title: "SHOP NOW", font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .white, kern: 0.5)
        
        if let image = Userpreference.categoryTopImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: image) {
            imageViewTopImage.kf.setImage(with: imgUrl)
        }
        
        if let image = Userpreference.categorySecondImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: image) {
            imageViewSecondImage.kf.setImage(with: imgUrl)
        }
        
        if let image = Userpreference.categoryThirdImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: image) {
            imageViewThirdImage.kf.setImage(with: imgUrl)
        }
        
        if let image = Userpreference.categoryFourthImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: image) {
            imageViewFourthImage.kf.setImage(with: imgUrl)
        }

        if let image = Userpreference.categoryFifthImage?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let imgUrl = URL(string: image) {
            imageViewFifthImage.kf.setImage(with: imgUrl)
        }
        
    }
    
    @IBAction func routeToWatchWinders(_ sender: UIButton) {
        
        
        
        
        switch sender {
            
        case btnShopNow1 :
            
            if let category = Userpreference.categoryTopImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.typesOfWatchesClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.categoryTopImageTitle
                ])
            }
            
            
            
        case btnShopNow2 :

            if let category = Userpreference.categorySecondImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.typesOfWatchesClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.categorySecondImageTitle
                ])
            }
            
        case btnShopNow3 :
            
            if let category = Userpreference.categoryThirdImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.typesOfWatchesClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.categoryThirdImageTitle
                ])
            }
            
        case btnShopNow4 :

            
            if let category = Userpreference.categoryFourthImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.typesOfWatchesClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.categoryFourthImageTitle
                ])
            }
            
            
        case btnShopNow5 :
            if let category = Userpreference.categoryFifthImageCategoryId, let id = category.categoryId {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : id, EthosKeys.filters : category.appliedFilters.count > 0 ? category.appliedFilters : nil])
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.typesOfWatchesClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : Userpreference.categoryFifthImageTitle
                ])
            }
            
        
            
        default : break
            
        }
    }
    
    
}
