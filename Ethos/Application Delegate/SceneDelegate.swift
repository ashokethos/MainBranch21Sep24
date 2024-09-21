//
//  SceneDelegate.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import FBSDKLoginKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var userActivityModel = UserActivityViewModel()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first, let url = userActivity.webpageURL {
            self.userActivityModel.getDataFromActivityUrl(url: url.absoluteString)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print(scene)
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        let url = userActivity.webpageURL
        self.userActivityModel.getDataFromActivityUrl(url: url?.absoluteString ?? "")
    }
    
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        print(userActivityType)
    }
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        print(userActivity)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print(scene)
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print(scene)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

extension SceneDelegate {
    
    func startIndicator() {
        DispatchQueue.main.async {
            let topController = UIApplication.topViewController()
            EthosLoader.shared.show(view: topController?.view ?? UIView(), frame: topController?.view.frame ?? CGRect.zero)

        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            EthosLoader.shared.hide()
        }
    }
    
}

