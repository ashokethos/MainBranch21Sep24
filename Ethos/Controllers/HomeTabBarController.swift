//
//  AppTabBarController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import Mixpanel

class HomeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let view = UIVisualEffectView()
        let frm = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: self.tabBar.frame.height)
        view.effect = UIBlurEffect(style: .light)
        view.backgroundColor = EthosColor.barBackGroundColor
        view.frame = frm
        self.tabBar.addSubview(view)
        for v in self.tabBar.subviews {
            if v != view {
                self.tabBar.bringSubviewToFront(v)
            }
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Latest" {
            Mixpanel.mainInstance().trackWithLogs(event: "Latest Articles Tab Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        }
        
        if item.title == "Discover" {
            Mixpanel.mainInstance().trackWithLogs(event: "Discover Tab Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        }
        
        if item.title == "Shop" {
            Mixpanel.mainInstance().trackWithLogs(event: "Shop Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        }
        
        if item.title == "Pre-Owned" {
            Mixpanel.mainInstance().trackWithLogs(event: "Pre-Owned Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
        }
    }
}
