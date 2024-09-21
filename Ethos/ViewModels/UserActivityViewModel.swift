//
//  UserActivityViewModel.swift
//  Ethos
//
//  Created by mac on 05/10/23.
//

import Foundation
import UIKit


class UserActivityViewModel {
    
    func getDataFromActivityUrl(url : String) {
        DispatchQueue.main.async {
            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    
    
//    func getDataFromActivityUrl(url : String) {
//        
//        var site = Site.ethos.rawValue
//        
//        if url.contains("secondmovement.com") {
//            site = Site.secondMovement.rawValue
//        }
//        
//        DispatchQueue.main.async {
//            let topController = UIApplication.topViewController()
//            EthosLoader.shared.show(view: topController?.view ?? UIView(), frame: topController?.view.frame ?? CGRect.zero)
//
//        }
//        
//        EthosApiManager().callApi(endPoint: EthosConstants.getUrlType, RequestType: .GET, RequestParameters: [EthosConstants.site : site , EthosConstants.url : url], RequestBody: [:]) { data, response, error in
//            if let response = response as? HTTPURLResponse {
//                
//                DispatchQueue.main.async {
//                    EthosLoader.shared.hide()
//                }
//                
//                if response.statusCode == 200,
//                   let data = data,
//                   let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any],
//                   json[EthosConstants.status] as? Bool == true,
//                   let responsedata = json[EthosConstants.data] as? [String : Any] {
//                    
//                    let id = responsedata[EthosConstants.id] as? Int
//                    let type = responsedata[EthosConstants.type] as? String
//                    let site =  responsedata[EthosConstants.site] as? String
//                    let sku = responsedata[EthosConstants.sku] as? String
//                    let name = responsedata[EthosConstants.name] as? String
//                    let categoryId = responsedata[EthosConstants.id] as? String
//                    
//                    
//                    self.handleUserActivity(id: id, categoryId: categoryId, type: type, site: site, sku: sku, name: name)
//                } else {
//                    DispatchQueue.main.async {
//                        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
//                            UIApplication.shared.open(url)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
    func handleUserActivity(id: Int?, categoryId: String?, type: String?, site: String?, sku: String?, name: String?) {
        DispatchQueue.main.async {
            if type == EthosConstants.article , let id = id {
                
                let topController = UIApplication.topViewController()
                
                if topController?.tabBarController is HomeTabBarController {
                    if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                        if site == Site.secondMovement.rawValue {
                            vc.isForPreOwned = true
                        }
                        vc.articleId = id
                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if let tabbar = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
                        topController?.present(tabbar, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                                    if site == Site.secondMovement.rawValue {
                                        vc.isForPreOwned = true
                                    }
                                    vc.articleId = id
                                    UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }
            } else if type == EthosConstants.product , let sku = sku {
            
                let topController = UIApplication.topViewController()
                
                if topController?.tabBarController is HomeTabBarController {
                    
                    if site == Site.secondMovement.rawValue {
                        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                            vc.sku = sku
                            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                            vc.sku = sku
                            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    
                } else {
                    if let tabbar = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
                        topController?.present(tabbar, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                
                                if site == Site.secondMovement.rawValue {
                                    if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                                        vc.sku = sku
                                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                                    }
                                } else {
                                    if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                                        vc.sku = sku
                                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } else if type == EthosConstants.category, let categoryId = categoryId {
                
                let topController = UIApplication.topViewController()
                
                if topController?.tabBarController is HomeTabBarController {
                    if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                        if site == Site.secondMovement.rawValue {
                            vc.isForPreOwned = true
                        }
                        vc.productViewModel.categoryId = Int(categoryId)
                        vc.productViewModel.categoryName = name
                        
                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if let tabbar = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
                        topController?.present(tabbar, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                                    if site == Site.secondMovement.rawValue {
                                        vc.isForPreOwned = true
                                    }
                                    vc.productViewModel.categoryId = Int(categoryId)
                                    vc.productViewModel.categoryName = name
                                    UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
