//
//  BrandsTableViewCell.swift
//  Ethos
//
//  Created by mac on 19/10/23.
//

import UIKit
import Mixpanel
import SkeletonView

class BrandsTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var btnViewAllDisclosureBtn: UIButton!
    @IBOutlet weak var txtBtnViewAll: UIButton!
    @IBOutlet weak var viewBtnViewAll: UIView!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnViewAllProducts: UIButton!
    var forSecondMovement : Bool = false
    let brandViewModel = GetBrandsViewModel()
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func initiateData() {
        self.brandViewModel.getBrands(site: self.forSecondMovement ? .secondMovement : .ethos, includeRolex: true)
        self.setUI()
    }
    
    func setup() {
        self.collectionView.registerCell(className: BrandImageCollectionViewCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.brandViewModel.delegate = self
        
        self.btnViewAllDisclosureBtn.setImage(UIImage.imageWithName(name: EthosConstants.rightArrowEthos), for: .normal)
        self.txtBtnViewAll.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black ,kern: 0.5)
        self.btnViewAllProducts.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Medium(size: 12), kern: 1)
    }
    
    
    func setUI() {
        self.txtBtnViewAll.setAttributedTitleWithProperties(title: EthosConstants.AtoZ, font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .black ,kern: 1)
        self.btnViewAllDisclosureBtn.setImage(UIImage.imageWithName(name: EthosConstants.downArrowEthos), for: .normal)
        self.updateProgressView()
    }
    
    override func prepareForReuse() {
        self.contentView.layoutIfNeeded()
        self.forSecondMovement = false
        self.indicator.stopAnimating()
        self.collectionView.contentOffset = CGPoint.zero
        self.progressView.progress = 0
        self.setTitle(title: "")
        self.brandViewModel.brands.removeAll()
        self.collectionView.reloadData()
    }
    
    func updateProgressView() {
        DispatchQueue.main.async {
            let multiplier = (self.collectionView.contentOffset.x + self.collectionView.frame.width)/self.collectionView.contentSize.width
            self.progressView.progress = Float(multiplier)
            self.layoutIfNeeded()
        }
    }
    
    func setTitle(title : String) {
        labelHeading.setAttributedTitleWithProperties(
            title: title,
            font: EthosFont.Brother1816Medium(size: 12),
            kern: 1
        )
    }
    
    @IBAction func btnViewAllProductsDidTapped(_ sender: UIButton) {
        if self.forSecondMovement {
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.PreOwnedBrandsViewAllClicked, properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        } else {
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ViewAllBrandsClicked, properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        }
       
        
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : self.forSecondMovement ? 3 : 110, EthosKeys.forSecondMovement : self.forSecondMovement, EthosKeys.categoryName : "All Watches"])
        
    }
    
    @IBAction func btnViewAllDidTapped(_ sender: UIButton) {
        if self.txtBtnViewAll.titleLabel?.attributedText?.string == EthosConstants.AtoZ {
            self.txtBtnViewAll.setAttributedTitleWithProperties(title: EthosConstants.ZtoA, font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .black ,kern: 1)
            
            self.btnViewAllDisclosureBtn.setImage(UIImage.imageWithName(name: EthosConstants.downArrowEthos), for: .normal)
            brandViewModel.getBrands(site: self.forSecondMovement ? .secondMovement : .ethos, sorted: true, isAscending: false, includeRolex: true)
        } else {
            self.txtBtnViewAll.setAttributedTitleWithProperties(title: EthosConstants.AtoZ, font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .black ,kern: 1)
            self.btnViewAllDisclosureBtn.setImage(UIImage.imageWithName(name: EthosConstants.downArrowEthos), for: .normal)
            brandViewModel.getBrands(site: self.forSecondMovement ? .secondMovement : .ethos, sorted: true, isAscending: true, includeRolex: true)
        }
    }
}

extension BrandsTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brandViewModel.brands.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BrandImageCollectionViewCell.self), for: indexPath) as? BrandImageCollectionViewCell {
            cell.index = indexPath
            cell.brand = brandViewModel.brands[indexPath.item]
            cell.setBorderAccordingToIndex(index: indexPath.item, totalCount: self.brandViewModel.brands.count)
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.forSecondMovement {
            Mixpanel.mainInstance().trackWithLogs(
                event: "Pre Owned Brands Clicked",
                properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Brand: brandViewModel.brands[indexPath.item].name
                ]
            )
        } else {
            Mixpanel.mainInstance().trackWithLogs(
                event: "Brand Shops Clicked",
                properties: [
                    EthosConstants.Email: Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Brand: brandViewModel.brands[indexPath.item].name
                ]
            )
        }

        
        self.delegate?.updateView (
            info: [
                EthosKeys.key : EthosKeys.routeToProducts ,
                EthosKeys.categoryId : brandViewModel.brands[indexPath.item].category_id,
                EthosKeys.categoryName : brandViewModel.brands[indexPath.item].name,
                EthosKeys.forSecondMovement : self.forSecondMovement
            ]
        )
    }
}

extension BrandsTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let multiplier = (scrollView.contentOffset.x + scrollView.frame.width)/scrollView.contentSize.width
            self.progressView.progress = Float(multiplier)
        }
    }
}

extension BrandsTableViewCell : GetBrandsViewModelDelegate {
    func didGetBrandsForSellOrTrade(brands: [BrandForSellOrTrade]) {
        
    }
    
    func didGetFormBrands(brands : [FormBrand]) {
        
    }
    
    func errorInGettingBrands() {
        
    }
    
    func didGetBrands(brands: [BrandModel]) {
        self.collectionView.reloadData()
        updateProgressView()
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.collectionView.showAnimatedGradientSkeleton()
        }
        
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.collectionView.hideSkeleton()
        }
        
    }
    
    
}

extension BrandsTableViewCell : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        String(describing: BrandImageCollectionViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BrandImageCollectionViewCell.self), for: indexPath) as? BrandImageCollectionViewCell {
            cell.index = indexPath
            cell.setBorderAccordingToIndex(index: indexPath.item, totalCount: self.brandViewModel.brands.count)
            cell.contentView.showAnimatedGradientSkeleton()
            return cell
        }
        return UICollectionViewCell()
    }
    
    
}
