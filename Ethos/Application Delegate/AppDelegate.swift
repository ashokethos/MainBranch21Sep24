//
//  AppDelegate.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import CoreData
import OneSignalFramework
import CoreLocation
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import Siren
import Mixpanel
import PostHog
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical, showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)
        
        siren.wail()
        EthosLoader.shared.instantiate()
        IQKeyboardManager.shared.enable = true
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        requestPhotoLibraryPermission()
        FirebaseApp.configure()
        
        
        DispatchQueue.main.async {
            if Userpreference.testingMode == true {
                Mixpanel.initialize(token: EthosIdentifiers.mixPanelTestingKey, trackAutomaticEvents: false)
            } else {
                Mixpanel.initialize(token: EthosIdentifiers.mixPanelProductionKey, trackAutomaticEvents: false)
            }
            Mixpanel.mainInstance().loggingEnabled = true
        }
        
//        DispatchQueue.main.async {
//            let config = PostHogConfig(apiKey: EthosIdentifiers.postHogApiKey, host: EthosIdentifiers.postHogHost)
//            config.sessionReplay = true
//            PostHogSDK.shared.setup(config)
//        }
        
        DispatchQueue.main.async {
            OneSignal.Debug.setLogLevel(.LL_VERBOSE)
            OneSignal.initialize(EthosIdentifiers.oneSignalApiKey, withLaunchOptions: launchOptions)
            OneSignal.User.pushSubscription.optIn()
        }
        
        DispatchQueue.main.async {
            let properties : Dictionary<String, any MixpanelType> = [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ]
            print(properties.debugDescription)
            Mixpanel.mainInstance().trackWithLogs(
                event: "App Open",
                properties: properties
            )
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let properties : Dictionary<String, any MixpanelType> = [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
            EthosConstants.Platform : EthosConstants.IOS
            ]
        print(properties.debugDescription)

        Mixpanel.mainInstance().trackWithLogs(
            event: "App Close",
            properties: properties
        )
    }
    
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    lazy var sharedPersistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: EthosConstants.Ethos)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: EthosConstants.Ethos)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCenter.default.post(Notification(name: Notification.Name("receivedNotification")))
    }
}

extension MixpanelInstance {
     func trackWithLogs(event: String?, properties: Properties? = nil) {
         self.track(event: event, properties: properties)
         print("Mixpanel Track Request : \"\(event ?? "")\"\nproperties :-\n\(properties?.debugDescription ?? "No Properties")")
    }
}
