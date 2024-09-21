//
//  PurchaseHistoryTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 15/07/24.
//

import UIKit

class PurchaseHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var topConstraintMainBackView: NSLayoutConstraint!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var brandNameLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var modelLbl: UILabel!
    @IBOutlet weak var billingAmtLbl: UILabel!
    @IBOutlet weak var orderDateLbl: UILabel!
    @IBOutlet weak var orderIDLbl: UILabel!
    @IBOutlet weak var orderDateTitleLbl: UILabel!
    @IBOutlet weak var orderIDTitleLbl: UILabel!
    @IBOutlet weak var downloadInvoiceImg: UIImageView!
    @IBOutlet weak var downloadInvoiceBtn: UIButton!
    
    var purchaseHistoryData = GetPurchaseHistoryData()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainBackView.layer.borderWidth = 1
        mainBackView.layer.borderColor = UIColor(red:234/255, green:234/255, blue:234/255, alpha: 1).cgColor
        productImg.isSkeletonable = true
        brandNameLbl.isSkeletonable = true
        nameLbl.isSkeletonable = true
        sizeLbl.isSkeletonable = true
        modelLbl.isSkeletonable = true
        billingAmtLbl.isSkeletonable = true
        orderDateLbl.isSkeletonable = true
        orderIDLbl.isSkeletonable = true
        orderDateTitleLbl.isSkeletonable = true
        orderIDTitleLbl.isSkeletonable = true
        downloadInvoiceImg.isSkeletonable = true
//        showSkeleton()
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
    }
    
    func showSkeleton() {
        DispatchQueue.main.async {
            self.contentView.showAnimatedGradientSkeleton()
            self.productImg.showAnimatedGradientSkeleton()
            self.showAnimatedGradientSkeleton()
            self.brandNameLbl.showAnimatedGradientSkeleton()
            self.nameLbl.showAnimatedGradientSkeleton()
            self.sizeLbl.showAnimatedGradientSkeleton()
            self.modelLbl.showAnimatedGradientSkeleton()
            self.billingAmtLbl.showAnimatedGradientSkeleton()
            self.orderDateLbl.showAnimatedGradientSkeleton()
            self.orderIDLbl.showAnimatedGradientSkeleton()
            self.orderDateTitleLbl.showAnimatedGradientSkeleton()
            self.orderIDTitleLbl.showAnimatedGradientSkeleton()
            self.downloadInvoiceImg.showAnimatedGradientSkeleton()
        }
    }
    
    func hideSkeleton() {
        DispatchQueue.main.async {
            self.contentView.hideSkeleton()
            self.productImg.hideSkeleton()
            self.hideSkeleton()
            self.brandNameLbl.hideSkeleton()
            self.nameLbl.hideSkeleton()
            self.sizeLbl.hideSkeleton()
            self.modelLbl.hideSkeleton()
            self.billingAmtLbl.hideSkeleton()
            self.orderDateLbl.hideSkeleton()
            self.orderIDLbl.hideSkeleton()
            self.orderDateTitleLbl.hideSkeleton()
            self.orderIDTitleLbl.hideSkeleton()
            self.downloadInvoiceImg.hideSkeleton()
            
            if (self.purchaseHistoryData.invoiceAttachmentPath ?? "").isValidURL{
                self.downloadInvoiceImg.isHidden = false
            }else{
                self.downloadInvoiceImg.isHidden = true
            }
            if let url = URL(string: (self.purchaseHistoryData.image ?? "")) {
                self.productImg.kf.setImage(with: url)
            }
            self.brandNameLbl.numberOfLines = 1
            self.brandNameLbl.setAttributedTitleWithProperties(
                title: (self.purchaseHistoryData.brand_name ?? "").uppercased(),
                font: EthosFont.Brother1816Bold(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.nameLbl.numberOfLines = 1
            self.nameLbl.setAttributedTitleWithProperties(
                title: (self.purchaseHistoryData.name ?? "").uppercased(),
                font: EthosFont.Brother1816Regular(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.sizeLbl.numberOfLines = 1
            self.sizeLbl.setAttributedTitleWithProperties(
                title: (self.purchaseHistoryData.case_size ?? "").uppercased(),
                font: EthosFont.Brother1816Regular(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.modelLbl.numberOfLines = 1
            self.modelLbl.setAttributedTitleWithProperties(
                title: (self.purchaseHistoryData.model_number ?? "").uppercased(),
                font: EthosFont.Brother1816Regular(size: 11), foregroundColor: UIColor.init(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0000),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.billingAmtLbl.numberOfLines = 1
            self.billingAmtLbl.setAttributedTitleWithProperties(
                title: "MRP ₹ \((self.purchaseHistoryData.billing_amount ?? 0).getCommaSeperatedStringValue() ?? "")",
                font: EthosFont.Brother1816Regular(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.orderDateTitleLbl.setAttributedTitleWithProperties(
                title: "ORDER DATE",
                font: EthosFont.Brother1816Bold(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.orderDateLbl.numberOfLines = 1
            self.orderDateLbl.setAttributedTitleWithProperties(
                title: (self.purchaseHistoryData.invoice_date ?? "").uppercased(),
                font: EthosFont.Brother1816Regular(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.orderIDTitleLbl.setAttributedTitleWithProperties(
                title: "ORDER ID",
                font: EthosFont.Brother1816Bold(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            self.orderIDLbl.numberOfLines = 1
            self.orderIDLbl.setAttributedTitleWithProperties(
                title: "#\(self.purchaseHistoryData.invoice_number ?? "")",
                font: EthosFont.Brother1816Regular(size: 11),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
