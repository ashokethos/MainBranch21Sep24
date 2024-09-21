//
//  SellOrTradeTableViewCell.swift
//  Ethos
//
//  Created by mac on 30/06/23.
//

import UIKit
import Mixpanel

class SellOrTradeTableViewCell: UITableViewCell {

    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func btnSellDidTapped(_ sender: UIButton) {
        Mixpanel.mainInstance().trackWithLogs(
            event: "Sell Your Watch Clicked",
            properties: [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
            EthosConstants.Platform : EthosConstants.IOS
        ])
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.updateView, EthosKeys.value : PreOwnTabsKey.sell])
    }
    
    @IBAction func btnTradeDidTapped(_ sender: UIButton) {
        Mixpanel.mainInstance().trackWithLogs(
            event: "Trade Your Watch Clicked",
            properties: [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
            EthosConstants.Platform : EthosConstants.IOS
        ]
        )
        
        self.delegate?.updateView(
            info: [
                EthosKeys.key : EthosKeys.updateView,
                EthosKeys.value : PreOwnTabsKey.trade
            ]
        )
    }
}
