//
//  SplashViewController.swift
//  Ethos
//
//  Created by mac on 04/09/23.
//

import UIKit
import Mixpanel

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        GetAppSettingViewModel().getAppSettings {
            if Userpreference.firstSplashWatched == true {
              if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
                  UIApplication
                      .shared
                      .connectedScenes
                      .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                      .last { $0.isKeyWindow }?.rootViewController = vc
                }
            } else {
                Userpreference.firstSplashWatched = true
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "RootNavigationController") {
                    self.show(vc, sender: self)
                }
            }
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
     
       
    }
}
