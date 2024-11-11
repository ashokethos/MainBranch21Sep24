//
//  SplashViewController.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import UIKit
import Mixpanel
import OneSignalFramework

class SplashViewController: UIViewController {
    
    var hasRequestedPermission = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OneSignal.Notifications.requestPermission({ accepted in
            GetAppSettingViewModel().getAppSettings {
                self.MoveHomeScreen()
            }
        }, fallbackToSettings: true)
    }
    
    func MoveHomeScreen(){
        DispatchQueue.main.async {
            if Userpreference.firstSplashWatched == true {
                
                if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
                    UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.last { $0.isKeyWindow }?.rootViewController = vc
                }
                //                if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: DashboardTabBarController.self)) as? DashboardTabBarController {
                //                    UIApplication
                //                        .shared
                //                        .connectedScenes
                //                        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                //                        .last { $0.isKeyWindow }?.rootViewController = vc
                //                  }
            } else {
                Userpreference.firstSplashWatched = true
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") {
                    self.show(vc, sender: self)
                }
            }
        }
    }
}
