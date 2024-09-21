//
//  NotificationTableViewCell.swift
//  Ethos
//
//  Created by mac on 20/09/23.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnAction: UIButton!
    
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImage.setBorder(borderWidth: 0, borderColor: .clear, radius: 40)
    }
    
    var notification : NotificationDBModel? {
        didSet {
            if let notification = self.notification {
                self.lblTitle.setAttributedTitleWithProperties(title: notification.title ?? "", font: EthosFont.Brother1816Regular(size: 14), foregroundColor: .black, lineHeightMultiple: 1.42, kern: 0.1)
                
                self.lblMessage.setAttributedTitleWithProperties(title: notification.body ?? "", font: EthosFont.Brother1816Regular(size: 12), foregroundColor: .black, lineHeightMultiple: 1.42, kern: 0.1)
            
                if let image = notification.image, let url = URL(string: image) {
                        self.mainImage.kf.setImage(with: url)
                }
            }
        }
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        if let notification = self.notification {
            DataBaseModel().deleteNotification(id: notification.identity ?? "") {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadTableView])
            }
        }
    }
    
    @IBAction func btnActionDidTapped(_ sender: UIButton) {
        if let notification = self.notification {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.openWebPage, EthosKeys.url : notification.link ?? ""])
        }
        
        
    }
    
}
