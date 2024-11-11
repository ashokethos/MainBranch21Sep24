//
//  DashboardTabBarController.swift
//  Ethos
//
//  Created by Ashok kumar on 04/10/24.
//

import UIKit

class DashboardTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let item1 = DiscoverViewController()
        item1.tabBarItem = UITabBarItem(title: "Latest", image: UIImage(named: "latest"), selectedImage: UIImage(named: "latest"))
        let controllers = [item1]  //array of the root view controllers displayed by the tab bar interface
        self.viewControllers = controllers
    }

    //Delegate methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title ?? "") ?")
        return true;
    }
}
