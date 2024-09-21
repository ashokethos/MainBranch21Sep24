//
//  DataBaseModel.swift
//  Ethos
//
//  Created by mac on 15/09/23.
//

import Foundation
import UIKit
import CoreData
import Mixpanel

class DataBaseModel {
    
    func fetchAppleData(completion : ([AppleLoginInfoModel]) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.AppleLoginInfoModel)
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [AppleLoginInfoModel] {
                completion(result)
            }
        } catch {
            print("Failed")
        }
    }
    
    func checkUserExists(user : String, completion : (Bool, String?) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.AppleLoginInfoModel)
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [AppleLoginInfoModel] {
                var correspondingEmail : String?
                var found = false
                for db in result {
                    if user == db.user {
                        correspondingEmail = db.email
                        found = true
                    }
                }
                completion(found, correspondingEmail)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    func checkTokenExists(token : Data, completion : (Bool, String?) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.AppleLoginInfoModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [AppleLoginInfoModel] {
                var correspondingEmail : String?
                var found = false
                for db in result {
                    if token == db.token ?? Data() {
                        correspondingEmail = db.email
                        found = true
                    }
                }
                completion(found, correspondingEmail)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func checkEmailExists(email : String, completion : (Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.AppleLoginInfoModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [AppleLoginInfoModel] {
                var found = false
                for db in result {
                    if email == db.email ?? "" {
                        found = true
                    }
                }
                completion(found)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func saveAppleLoginInfo(email : String, token : Data, user : String, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: EthosConstants.AppleLoginInfoModel, in: managedContext) else {
            return
        }
        
        
        let logininfo = AppleLoginInfoModel(entity: entity, insertInto: managedContext)
        logininfo.email = email
        logininfo.token = token
        logininfo.user = user
        
        do {
            try managedContext.save()
            completion()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func updateTokenForEmail(email : String, token : Data, user : String, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<AppleLoginInfoModel>(entityName: EthosConstants.AppleLoginInfoModel)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            for result in results {
                if result.email == email {
                    result.token = token
                    result.user = user
                }
            }
            try managedContext.save()
            completion()
        }
        
        catch {
            
        }
    }
    
    
    
    func fetchProducts(completion : ([ProductDBModel]) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.ProductDBModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [ProductDBModel] {
                completion(result)
            }
        } catch {
            print("Failed")
        }
    }
    
    func fetchRecentProducts(completion : ([RecentProductDBModel]) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.RecentProductDBModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [RecentProductDBModel] {
                completion(result)
            }
        } catch {
            print("Failed")
        }
    }
    
    func fetchArticles(completion : ([ArticleDBModel]) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.ArticleDBModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [ArticleDBModel] {
                completion(result)
            }
        } catch {
            print("Failed")
        }
    }
    
    func fetchNotifications(completion : ([NotificationDBModel]) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.sharedPersistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.NotificationDBModel)
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [NotificationDBModel] {
                completion(result)
            }
        } catch {
            print("Failed")
        }
    }
    
    
    func checkProductExists(product : Product, completion : (Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.ProductDBModel)
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [ProductDBModel] {
                var found = false
                for db in result {
                    if let sku = product.sku {
                        if sku == db.sku ?? "" {
                            found = true
                        }
                    }
                }
                completion(found)
            }
        } catch {
            print("Failed")
        }
    }
    
    func checkRecentProductExists(product : Product, completion : @escaping(Bool) -> ()) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.RecentProductDBModel)
            
            do {
                if let result = try managedContext.fetch(fetchRequest) as? [RecentProductDBModel] {
                    var found = false
                    for db in result {
                        if let sku = product.sku {
                            if sku == db.sku ?? "" {
                                found = true
                            }
                        }
                    }
                    completion(found)
                }
            } catch {
                print("Failed")
            }
        }
    }
    
    func checkArticleExistsFromArticle(article : Article, completion : (Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.ArticleDBModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [ArticleDBModel] {
                var found = false
                for db in result {
                    if let articleId = article.id {
                        if articleId == db.articleId {
                            found = true
                            
                        }
                    }
                }
                completion(found)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    
    func checkArticleExists(article : ArticleDetails, completion : (Bool) -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EthosConstants.ArticleDBModel)
        
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [ArticleDBModel] {
                var found = false
                for db in result {
                    if let id = article.id {
                        if id == db.articleId {
                            found = true
                        }
                    }
                }
                completion(found)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func saveProduct(product : Product, forPreOwn : Bool, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let ProductEntity = NSEntityDescription.entity(forEntityName: EthosConstants.ProductDBModel, in: managedContext)!
        let productToSave = ProductDBModel(entity: ProductEntity, insertInto: managedContext)
        productToSave.sku = product.sku ?? ""
        productToSave.name = product.extensionAttributes?.ethProdCustomeData?.collection ?? (product.extensionAttributes?.ethProdCustomeData?.productName ?? (product.name ?? ""))
        if let price = product.price {
            productToSave.price = Int64(price)
        }
        
        if let customPrice = product.extensionAttributes?.ethProdCustomeData?.price {
            productToSave.customPrice = Int64( customPrice)
        }
        
        productToSave.thumbnailImage = product.extensionAttributes?.ethProdCustomeData?.images?.catalogImage ?? ""
        productToSave.brand = (product.extensionAttributes?.ethProdCustomeData?.brand ?? "")
        productToSave.hidePrice = product.extensionAttributes?.ethProdCustomeData?.hidePrice ?? true
        productToSave.currency = product.currency
        productToSave.preowned = forPreOwn
        productToSave.collectionName = product.extensionAttributes?.ethProdCustomeData?.collection ?? ""
        productToSave.addedDate = Date()
        
        do {
            try managedContext.save()
            completion()
            Mixpanel.mainInstance().trackWithLogs (
                event: "Product Wishlisted",
                properties: [
                    EthosConstants.ProductType : product.extensionAttributes?.ethProdCustomeData?.brand,
                    EthosConstants.ProductName : product.extensionAttributes?.ethProdCustomeData?.productName,
                    EthosConstants.SKU : product.sku,
                    EthosConstants.Price : product.price,
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS
                ])
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveRecentProduct(product : Product, forPreOwn : Bool, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let ProductEntity = NSEntityDescription.entity(forEntityName: EthosConstants.RecentProductDBModel, in: managedContext)!
        
        
        let productToSave = RecentProductDBModel(entity: ProductEntity, insertInto: managedContext)
        productToSave.sku = product.sku ?? ""
        productToSave.name = product.extensionAttributes?.ethProdCustomeData?.collection ?? (product.extensionAttributes?.ethProdCustomeData?.productName ?? (product.name ?? ""))
        
        if let price = product.price {
            productToSave.price = Int64(price)
        }
        
        if let customPrice = product.extensionAttributes?.ethProdCustomeData?.price {
            productToSave.customPrice = Int64( customPrice)
        }
        
        productToSave.thumbnailImage = product.extensionAttributes?.ethProdCustomeData?.images?.catalogImage
        productToSave.brand = (product.extensionAttributes?.ethProdCustomeData?.brand ?? "")
        productToSave.currency = product.currency
        productToSave.preowned = forPreOwn
        productToSave.collectionName = product.extensionAttributes?.ethProdCustomeData?.collection ?? ""
        productToSave.hidePrice = product.extensionAttributes?.ethProdCustomeData?.hidePrice ?? false
        productToSave.addedDate = Date()
        
        do {
            try managedContext.save()
            completion()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func saveArticleForArticle(article : Article, forPreOwn : Bool, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let ArticleEntity = NSEntityDescription.entity(forEntityName: EthosConstants.ArticleDBModel, in: managedContext)!
        
        
        let articleToSave = ArticleDBModel(entity: ArticleEntity, insertInto: managedContext)
        articleToSave.articleId = Int64(article.id ?? 0)
        articleToSave.title = article.title ?? ""
        articleToSave.category = article.category ?? ""
        articleToSave.commentCount = Int64(article.commentCount ?? 0)
        articleToSave.author = article.author
        articleToSave.createdAt = Int64(article.createdDate ?? 0)
        articleToSave.preowned = forPreOwn
        
        if let asset = article.assets?.first {
            articleToSave.imageUrl = asset.url ?? ""
            articleToSave.assetType = AssetType.image.rawValue
        }
        
        do {
            try managedContext.save()
            
            completion()
            
            Mixpanel.mainInstance().trackWithLogs(event: "Article Bookmarked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ArticleID : article.id,
                EthosConstants.ArticleCategory : article.category,
                EthosConstants.ArticleTitle : article.title
            ])
            
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveArticle(article : ArticleDetails, forPreOwn : Bool, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let ArticleEntity = NSEntityDescription.entity(forEntityName: EthosConstants.ArticleDBModel, in: managedContext) else {
            return
        }
        
        let articleToSave = ArticleDBModel(entity: ArticleEntity, insertInto: managedContext)
        articleToSave.articleId = Int64(article.id ?? 0)
        articleToSave.title = article.title ?? ""
        articleToSave.category = article.customCategory?.name ?? ""
        articleToSave.commentCount = Int64(article.commentCount ?? 0)
        articleToSave.author = article.author
        articleToSave.createdAt = Int64(EthosDateAndTimeHelper().getTimeStampFromUTCString(str: article.pubdate ?? ""))
        articleToSave.preowned = forPreOwn
        
        if let asset = article.image {
            articleToSave.imageUrl = asset
            articleToSave.assetType = AssetType.image.rawValue
        }
        
        do {
            try managedContext.save()
            Mixpanel.mainInstance().trackWithLogs(event: "Article Bookmarked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ArticleID : article.id,
                EthosConstants.ArticleCategory : article.customCategory?.name,
                EthosConstants.ArticleTitle : article.title
            ]
            )
            completion()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteNotification(id : String, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.sharedPersistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NotificationDBModel>(entityName: EthosConstants.NotificationDBModel)
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let itemToUpdate = results.first(where: { element in
                id == element.identity
            }) {
                managedContext.delete(itemToUpdate)
                try managedContext.save()
                completion()
            }
        } catch {
            
        }
    }
    
    func readNotifications(completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.sharedPersistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NotificationDBModel>(entityName: EthosConstants.NotificationDBModel)
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                result.isRead = true
            }
            try managedContext.save()
            completion()
        }
        catch {
            
        }
    }
    
    func updateDateOfExistingProduct(product : Product, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<RecentProductDBModel>(entityName: EthosConstants.RecentProductDBModel)
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                if result.sku == product.sku {
                    result.addedDate = Date()
                }
            }
            try managedContext.save()
            completion()
        } catch {
            
        }
    }
    
    func unsaveProduct(product : Product, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ProductDBModel>(entityName: EthosConstants.ProductDBModel)
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let itemToUpdate = results.first(where: { element in
                product.sku == element.sku
            }) {
                managedContext.delete(itemToUpdate)
                try managedContext.save()
                
                completion()
            }
        } catch {
            
        }
    }
    
    func unsaveRecentProduct(product : Product, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<RecentProductDBModel>(entityName: EthosConstants.RecentProductDBModel)
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let itemToUpdate = results.first(where: { element in
                product.sku == element.sku
            }) {
                managedContext.delete(itemToUpdate)
                try managedContext.save()
                completion()
            }
        } catch {
            
        }
    }
    
    func unsaveArticleFromArticle(article : Article, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ArticleDBModel>(entityName: EthosConstants.ArticleDBModel)
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let itemToUpdate = results.first(where: { element in
                element.articleId == Int64(article.id ?? 0 )
            }) {
                managedContext.delete(itemToUpdate)
                try managedContext.save()
                completion()
            }
        } catch {
            
        }
    }
    
    func unsaveArticle(article : ArticleDetails, completion : () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<ArticleDBModel>(entityName: EthosConstants.ArticleDBModel)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            if let itemToUpdate = results.first(where: { element in
                element.articleId == Int64(article.id ?? 0)
            }) {
                managedContext.delete(itemToUpdate)
                try managedContext.save()
                completion()
            }}
        catch {
            
        }
    }
}
