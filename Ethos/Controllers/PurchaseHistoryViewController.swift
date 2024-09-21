//
//  PurchaseHistoryViewController.swift
//  Ethos
//
//  Created by Ashok kumar on 15/07/24.
//

import UIKit
import SkeletonView

class PurchaseHistoryViewController: UIViewController {
    
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var purchaseHistoryTableView: UITableView!
    
    var viewModel = GetCustomerViewModel()
    var purchaseHistoryDataArr = [GetPurchaseHistoryData]()
    let refreshControl = UIRefreshControl()
    var emptyMsg = "You haven't placed any orders yet.\nShop now and view your order history here."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
        
        callApi()
    }
    
    func setup() {
        addTapGestureToDissmissKeyBoard()
        topTitleLbl.setAttributedTitleWithProperties(
            title: "ORDER HISTORY",
            font: EthosFont.Brother1816Bold(size: 11), foregroundColor: .white,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        purchaseHistoryTableView.registerCell(className: PurchaseHistoryTableViewCell.self)
        
        purchaseHistoryTableView.isSkeletonable = true
        purchaseHistoryTableView.dataSource = self
        purchaseHistoryTableView.delegate = self
        addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing".uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.purchaseHistoryTableView.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        callApi()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.purchaseHistoryTableView.refreshControl?.endRefreshing()
        }
    }
    
    func callApi() {
        self.purchaseHistoryDataArr.removeAll()
        self.purchaseHistoryTableView.reloadData()
        self.viewModel.delegate = self
        self.viewModel.delegatePurchaseHistory = self
        self.viewModel.getCustomerDetails()
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PurchaseHistoryViewController : SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: PurchaseHistoryTableViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: PurchaseHistoryTableViewCell.self)) as? PurchaseHistoryTableViewCell {
            cell.showSkeleton()
            return cell
        }
        return nil
    }
}

extension PurchaseHistoryViewController : UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if purchaseHistoryDataArr.count == 0{
            purchaseHistoryTableView.setEmptyMessage(emptyMsg)
        }else{
            purchaseHistoryTableView.restore()
        }
        return purchaseHistoryDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PurchaseHistoryTableViewCell.self), for: indexPath) as? PurchaseHistoryTableViewCell {
            if purchaseHistoryDataArr.count > 0{
                cell.purchaseHistoryData = purchaseHistoryDataArr[indexPath.row]
                if let url = URL(string: (purchaseHistoryDataArr[indexPath.row].image ?? "")) {
                    cell.productImg.kf.setImage(with: url)
                }
                cell.brandNameLbl.numberOfLines = 1
                cell.brandNameLbl.setAttributedTitleWithProperties(
                    title: (self.purchaseHistoryDataArr[indexPath.row].brand_name ?? "").uppercased(),
                    font: EthosFont.Brother1816Bold(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.nameLbl.numberOfLines = 1
                cell.nameLbl.setAttributedTitleWithProperties(
                    title: (self.purchaseHistoryDataArr[indexPath.row].name ?? "").uppercased(),
                    font: EthosFont.Brother1816Regular(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.sizeLbl.numberOfLines = 1
                cell.sizeLbl.setAttributedTitleWithProperties(
                    title: (self.purchaseHistoryDataArr[indexPath.row].case_size ?? "").uppercased(),
                    font: EthosFont.Brother1816Regular(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.modelLbl.numberOfLines = 1
                cell.modelLbl.setAttributedTitleWithProperties(
                    title: (self.purchaseHistoryDataArr[indexPath.row].model_number ?? "").uppercased(),
                    font: EthosFont.Brother1816Regular(size: 11), foregroundColor: UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0000),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.billingAmtLbl.numberOfLines = 1
                cell.billingAmtLbl.setAttributedTitleWithProperties(
                    title: "MRP ₹ \((self.purchaseHistoryDataArr[indexPath.row].billing_amount ?? 0).getCommaSeperatedStringValue() ?? "")",
                    font: EthosFont.Brother1816Regular(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.orderDateTitleLbl.setAttributedTitleWithProperties(
                    title: "ORDER DATE",
                    font: EthosFont.Brother1816Bold(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.orderDateLbl.numberOfLines = 1
                cell.orderDateLbl.setAttributedTitleWithProperties(
                    title: (self.purchaseHistoryDataArr[indexPath.row].invoice_date ?? "").uppercased(),
                    font: EthosFont.Brother1816Regular(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.orderIDTitleLbl.setAttributedTitleWithProperties(
                    title: "ORDER ID",
                    font: EthosFont.Brother1816Bold(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
                cell.orderIDLbl.numberOfLines = 1
                cell.orderIDLbl.setAttributedTitleWithProperties(
                    title: "#\(self.purchaseHistoryDataArr[indexPath.row].invoice_number ?? "")",
                    font: EthosFont.Brother1816Regular(size: 11),
                    lineHeightMultiple: 1.25,
                    kern: 0.1
                )
            }
            cell.hideSkeleton()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        if purchaseHistoryDataArr[indexPath.row].watch_category_type == "ETH" {
        //            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
        //                vc.sku = purchaseHistoryDataArr[indexPath.row].model_number ?? ""
        //                self.navigationController?.pushViewController(vc, animated: true)
        //            }
        //        } else {
        //            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
        //                vc.sku = purchaseHistoryDataArr[indexPath.row].model_number ?? ""
        //                self.navigationController?.pushViewController(vc, animated: true)
        //            }
        //        }
    }
}

extension PurchaseHistoryViewController : GetCustomerViewModelDelegate {
    func didGetCustomerData(data: Customer) {
        DispatchQueue.main.async {
            self.viewModel.getPurchaseHistory(site: .ethos)
        }
    }
    
    func unAuthorizedToken(message: String) {
        print("")
    }
    
    func startProfileIndicator() {
        print("")
    }
    
    func stopProfileIndicator() {
        print("")
    }
    
    func updateProfileSuccess(message: String) {
        print("")
    }
    
    func updateProfileFailed(message: String) {
        print("")
    }
    
    func didGetCustomerPoints(points: Int) {
        print("")
    }
    
    func userDeleteSuccess() {
        print("")
    }
    
    func userDeleteFailed(error: String) {
        print("")
    }
    
    
}

extension PurchaseHistoryViewController : GetPurchaseHistoryViewModelDelegate {
    
    func didGetPurchaseHistory(purchaseHistoryData: [GetPurchaseHistoryData]) {
        if purchaseHistoryData.count == 0{
            emptyMsg = "You haven't placed any orders yet.\nShop now and view your order history here."
        }else{
            emptyMsg = ""
        }
        self.purchaseHistoryDataArr = purchaseHistoryData
        
        DispatchQueue.main.async {
            self.purchaseHistoryTableView.stopSkeletonAnimation()
            self.view.hideSkeleton()
            self.purchaseHistoryTableView.reloadData()
        }
    }
    
    func errorInGettingPurchaseHistory(error: String) {
        emptyMsg = "You haven't placed any orders yet.\nShop now and view your order history here."
        
        DispatchQueue.main.async {
            self.purchaseHistoryTableView.reloadData()
        }
    }
    
    //func startIndicator() {
//        DispatchQueue.main.async {
//            self.showActivityIndicator()
//        }
    //}
    
    //func stopIndicator() {
//        DispatchQueue.main.async {
//            self.hideActivityIndicator()
//        }
    //}
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.purchaseHistoryTableView.showAnimatedGradientSkeleton()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.purchaseHistoryTableView.hideSkeleton()
            self.purchaseHistoryTableView.refreshControl?.endRefreshing()
        }
    }
    
    func startFooterIndicator() {
        print("")
    }
    
    func stopFooterIndicator() {
        print("")
    }
}
