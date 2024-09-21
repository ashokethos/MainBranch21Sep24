//
//  UIViewController.swift
//  Ethos
//
//  Created by mac on 31/07/23.
//

import Foundation
import UIKit

extension UIViewController {
    func addTapGestureToDissmissKeyBoard() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(onTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTap() {
        self.view.endEditing(true)
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 30, y: self.view.frame.size.height-150, width: self.view.frame.size.width - 60, height: 35))
        toastLabel.backgroundColor = .black
        toastLabel.setAttributedTitleWithProperties(title: message, font: EthosFont.Brother1816Medium(size: 14), alignment: .center, foregroundColor: .white, backgroundColor: .black, kern: 0.1)
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: 3, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func showAlertWithSingleTitle(title : String, message : String, actionTitle : String = EthosConstants.Ok.uppercased()) {
        DispatchQueue.main.async {
            if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: title, message: message, secondActionTitle: actionTitle)
                self.present(alertController, animated: true)
            }
        }
    }
    
    func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.backgroundColor = .clear
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()
        
        activityIndicator.tag = 100 // 100 for example
        
        // before adding it, you need to check if it is already has been added:
        for subview in view.subviews {
            if subview.tag == 100 {
                print("already added")
                return
            }
        }
        
        view.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        let activityIndicator = view.viewWithTag(100) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        
        // I think you forgot to remove it?
        activityIndicator?.removeFromSuperview()
        
        //UIApplication.shared.endIgnoringInteractionEvents()
    }
}


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        if let alert = controller as? UIAlertController {
            if let navigationController = alert.presentingViewController as? UINavigationController {
                return navigationController.viewControllers.last
            }
            return alert.presentingViewController
        }
        return controller
    }
}

