//
//  SecondMovementMainDesctionTableViewCell.swift
//  Ethos
//
//  Created by mac on 14/12/23.
//

import UIKit
import WebKit
import SkeletonView

class SecondMovementMainDesctionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblCondition: UILabel!
    @IBOutlet weak var lblPurchaseYear: UILabel!
    @IBOutlet weak var lblWatchBox: UILabel!
    @IBOutlet weak var lblServiceRecord: UILabel!
    @IBOutlet weak var lblWarrantyCard: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableViewDescription: EthosContentSizedTableView!
    @IBOutlet weak var imageTriangle: UIImageView!
    
    var delegate : SuperViewDelegate?
    var activityViewModel : UserActivityViewModel = UserActivityViewModel()
    var ArrDescription = [(String, String)]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableViewDescription.dataSource = self
        self.tableViewDescription.delegate = self
        self.tableViewDescription.registerCell(className: WatchConditionDescriptionTableViewCell.self)
        
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.lblCondition.text = ""
        self.lblPurchaseYear.text = ""
        self.lblWarrantyCard.text = ""
        self.lblSize.text = ""
        self.lblServiceRecord.text = ""
        self.lblWatchBox.text = ""
        self.product = nil
        self.ArrDescription.removeAll()
        self.tableViewDescription.reloadData()
        self.tableViewDescription.isHidden = true
        self.imageTriangle.isHidden = true
    }
    
    var product : Product? {
        didSet {
           
                
            self.lblCondition.text = product?.extensionAttributes?.ethProdCustomeData?.watchCondition ?? "N/A"
                
            self.lblPurchaseYear.text = product?.extensionAttributes?.ethProdCustomeData?.purchaseYear ?? "N/A"
                
            self.lblWarrantyCard.text = product?.extensionAttributes?.ethProdCustomeData?.warrantyCard ?? "N/A"
                
            self.lblSize.text = product?.extensionAttributes?.ethProdCustomeData?.size?.replacingOccurrences(of: "Mm", with: "mm") ?? "N/A"
                
            self.lblServiceRecord.text = product?.extensionAttributes?.ethProdCustomeData?.serviceRecord ?? "N/A"
                
            self.lblWatchBox.text = product?.extensionAttributes?.ethProdCustomeData?.watchBox ?? "N/A"
                
            if let conditionDescription = product?.extensionAttributes?.ethProdCustomeData?.watchConditionDescription {
                    let data = Data(conditionDescription.utf8)
                    
                    let output = data.html2String
                    let components = output.components(separatedBy: .newlines)
                    
                    let chunkedArr = components.chunked(into: 2)
                    var ArrChunks = [(String, String)]()
                    for chunks in chunkedArr {
                        if chunks.count == 2  {
                            ArrChunks.append((chunks[0], chunks[1]))
                        }
                    }
                    self.ArrDescription = ArrChunks
                    self.tableViewDescription.reloadData()
                }
           
        }
    }
    
    
    @IBAction func btnConditionDescriptionDidTapped(_ sender: UIButton) {
        self.tableViewDescription.isHidden = false
        self.imageTriangle.isHidden = false
    }
}

extension SecondMovementMainDesctionTableViewCell : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ArrDescription.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WatchConditionDescriptionTableViewCell.self), for: indexPath) as? WatchConditionDescriptionTableViewCell {
            cell.data = self.ArrDescription[safe : indexPath.row]
            
            if indexPath.row == 0 {
                cell.viewTopSeperator.isHidden = true
            } else {
                cell.viewTopSeperator.isHidden = false
            }
            
            if indexPath.row == self.ArrDescription.count - 1 {
                cell.viewBottomSeperator.isHidden = true
            } else {
                cell.viewBottomSeperator.isHidden = false
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension SecondMovementMainDesctionTableViewCell {
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
}
