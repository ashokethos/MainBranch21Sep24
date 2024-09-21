//
//  PersistantContainer.swift
//  Ethos
//
//  Created by mac on 21/09/23.
//


import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ethoswatches.app.onesignal")
        storeURL = storeURL?.appendingPathComponent("Ethos.sqlite")
        return storeURL!
    }
}
