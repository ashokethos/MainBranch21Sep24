//
//  BetterTogetherViewController.swift
//  Ethos
//
//  Created by mac on 29/06/23.
//

import UIKit
import Mixpanel

class BetterTogetherViewController: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var lblNumberOfItems: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorFooter: UIActivityIndicatorView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var categoryName : String?
    var sku : String?
    var isForPreOwned = false
    let refreshControl = UIRefreshControl()
    var productViewModel = GetProductViewModel()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.productCollectionView.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        callApi()
    }
    
    func callApi() {
        if let sku = self.sku {
            self.productViewModel.betterTogether(sku: sku)
        }
    }
    
    func setup() {
        self.lblTitle.isHidden = true
        self.addTapGestureToDissmissKeyBoard()
        productCollectionView.registerCell(className: ProductCollectionViewCell.self)
        productViewModel.delegate = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.lblTitle.text = self.categoryName?.uppercased()
            self.callApi()
            self.addRefreshControl()
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension BetterTogetherViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productViewModel.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
            cell.isForPreOwned = self.isForPreOwned
            cell.product = productViewModel.products[safe : indexPath.row]
            return cell
            
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: section == 0 ? 24 : 0, left: 30, bottom: 0, right: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isForPreOwned {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                vc.sku = productViewModel.products[indexPath.item].sku
                self.navigationController?.pushViewController(vc, animated: true)
            }

        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                vc.sku = productViewModel.products[indexPath.item].sku
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension BetterTogetherViewController : GetProductViewModelDelegate {
    
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
        DispatchQueue.main.async {
            if self.productCollectionView.refreshControl?.isRefreshing != true {
                self.indicator.startAnimating()
            }
        }
        
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.productCollectionView.refreshControl?.endRefreshing()
            self.indicator.stopAnimating()
        }
    }
    
    func startFooterIndicator() {
        DispatchQueue.main.async {
            self.indicatorFooter.startAnimating()
        }
    }
    
    func stopFooterIndicator() {
        DispatchQueue.main.async {
            self.indicatorFooter.stopAnimating()
        }
    }
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        DispatchQueue.main.async {
            self.lblNumberOfItems.text = "\(self.productViewModel.products.count) products".uppercased()
            self.productCollectionView.reloadData()
        }
    }
    
    
    
    
}
