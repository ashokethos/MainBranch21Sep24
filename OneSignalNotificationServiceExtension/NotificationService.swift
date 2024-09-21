import UserNotifications
import CoreData

import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
        
            let userinfo = request.content.userInfo
            let attachment = userinfo["att"] as? [String : Any]
            let image = attachment?["id"] as? String
            let custom = userinfo["custom"] as? [String : Any]
            let attrId = custom?["i"] as? String
            let link = custom?["u"] as? String
            let aps = userinfo["aps"] as? [String : Any]
            _ = aps?["mutable-content"] as? Int
            let alert = aps?["alert"] as? [String : Any]
            let alertTitle = alert?["title"] as? String
            let alertBody = alert?["body"] as? String
            _ = aps?["relevance-score"] as? Int
            _ = aps?["interruption-level"] as? String
            _ = aps?["sound"] as? String
           
            let managedContext = sharedPersistentContainer.viewContext
           
            guard let entity = NSEntityDescription.entity(forEntityName: "NotificationDBModel", in: managedContext) else { return }
            
            
            let notificationToSave = NotificationDBModel(entity: entity, insertInto: managedContext)
            notificationToSave.title = alertTitle
            notificationToSave.body = alertBody
            notificationToSave.image = image
            notificationToSave.link = link
            notificationToSave.identity = attrId
            notificationToSave.expiryDate = ""
            notificationToSave.receivedDate = DateFormatter().string(from: Date())
            notificationToSave.isRead = false
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
         
            
            
            OneSignalExtension.didReceiveNotificationExtensionRequest(self.receivedRequest, with: bestAttemptContent, withContentHandler: self.contentHandler)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
            contentHandler(bestAttemptContent)
        }
    }
    
    
    lazy var sharedPersistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "Ethos")
        
        print(container.persistentStoreDescriptions)
        
        
        var description = NSPersistentStoreDescription()
        
        
        description.shouldAddStoreAsynchronously = true
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [description]
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = sharedPersistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
}
