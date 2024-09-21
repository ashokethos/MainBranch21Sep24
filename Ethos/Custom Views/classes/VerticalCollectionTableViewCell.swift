//
//  VerticalCollectionTableViewCell.swift
//  Ethos
//
//  Created by mac on 04/07/23.
//

import UIKit
import Mixpanel
import SkeletonView

class VerticalCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBottom: UIButton!
    @IBOutlet weak var collectionView: EthosContentSizedCollectionView!
    @IBOutlet weak var indicator : UIActivityIndicatorView!
    
    var isForPreOwned = false
    
    var delegate : SuperViewDelegate?
    var productViewModel = GetProductViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCells()
        setUI()
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.isForPreOwned = false
    }
    
    func setupCells() {
        self.collectionView.registerCell(className: ProductCollectionViewCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        productViewModel.delegate = self
    }
    
    func setUI() {
        lblTitle.setAttributedTitleWithProperties(title: EthosConstants.JustIn.uppercased(), font: EthosFont.Brother1816Medium(size: 12), kern: 1)
        btnBottom.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        btnBottom.setAttributedTitleWithProperties(title: "SHOP ALL NEW ARRIVALS", font: EthosFont.Brother1816Medium(size: 12), kern: 0.5)
    }
    
    @IBAction func btnBottomDidTapped(_ sender: UIButton) {
        if self.isForPreOwned {
            Mixpanel.mainInstance().trackWithLogs(event:  "Pre Owned Shop All New Arrivals Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        } else {
            Mixpanel.mainInstance().trackWithLogs(event:  "Shop All New Arrivals Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        }

        
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : self.isForPreOwned ? 6 : 144, EthosKeys.categoryName : EthosConstants.NewArrivals, EthosKeys.forSecondMovement : self.isForPreOwned])
    }
    
    
}

extension VerticalCollectionTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productViewModel.products.count >= 10 ? 10 : productViewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
            cell.contentView.hideSkeleton()
            cell.isForPreOwned = self.isForPreOwned
            cell.product = productViewModel.products[indexPath.item]
            cell.constraintBottomPrice.constant = 60
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((self.contentView.bounds.width - (totalSpace)) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 346)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProductDetails, EthosKeys.value : self.productViewModel.products[indexPath.item],EthosKeys.categoryId : self.isForPreOwned ? 6 : 144, EthosKeys.categoryName : EthosConstants.NewArrivals, EthosKeys.forSecondMovement : self.isForPreOwned, EthosKeys.site : self.isForPreOwned ? Site.secondMovement : Site.ethos])
        
        if self.isForPreOwned {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.PreOwnedJustInProductClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.SKU : self.productViewModel.products[indexPath.item].sku,
                EthosConstants.ProductName : self.productViewModel.products[indexPath.item].name,
                EthosConstants.Price : self.productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.price
            ]
            )
        } else {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.ProductClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.SKU : self.productViewModel.products[indexPath.item].sku,
                EthosConstants.ProductName : self.productViewModel.products[indexPath.item].name,
                EthosConstants.Price : self.productViewModel.products[indexPath.item].price,
                EthosConstants.ShopType : EthosConstants.Ethos,
                EthosConstants.ProductSubCategory : EthosConstants.JustIn
            ]
            )
        }
    }
}

extension VerticalCollectionTableViewCell : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return String(describing: ProductCollectionViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
            cell.contentView.showAnimatedGradientSkeleton()
            cell.isForPreOwned = self.isForPreOwned
            cell.constraintBottomPrice.constant = 80
            return cell
        }
        return UICollectionViewCell()
    }
}

extension VerticalCollectionTableViewCell : GetProductViewModelDelegate {
    func errorInGettingFilters() {
        
    }
    
    func didGetFilters() {
        
    }
    
    func didGetProductDetails(details: Product) {
        
    }
    
    func failedToGetProductDetails() {
        
    }
    
    func errorInGettingProducts(error: String) {
        
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5 ) {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadHeightOfTableView])
            }
        }
    }
}


