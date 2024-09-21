//
//  UserPreference.swift
//  Ethos
//
//  Created by mac on 26/08/23.
//

import Foundation
import UIKit

class Userpreference : NSObject {
    
    static let testingMode = true
    
    static var shouldShowLifeStyle : Bool? = false
    
    static var shouldShowCategories : Bool? = true
    
    static var shouldShowDeleteAccount : Bool? = false
    
    static var shouldShowSkip : Bool? = false
    
    static var preferSearchProducts : Bool? = false
    
    static var shouldShowFeaturesSection : Bool? = false
    
    static var shouldShowShopThroughOurBoutique : Bool? = false
    
    
    static var lifeStyleTopImageTitle : String? = ""
    static var lifeStyleSecondImageTitle : String? = ""
    static var lifeStyleThirdImageTitle : String? = ""
    static var lifeStyleFourthImageTitle : String? = ""
    static var lifeStyleFifthImageTitle : String? = ""
    
    static var lifeStyleTopImageCategoryId : SettingsCategory?
    static var lifeStyleSecondImageCategoryId : SettingsCategory?
    static var lifeStyleThirdImageCategoryId : SettingsCategory?
    static var lifeStyleFourthImageCategoryId : SettingsCategory?
    static var lifeStyleFifthImageCategoryId : SettingsCategory?
    
    static var lifestyleDescription : String? = ""
    
    static var ethosJustINSort : String? = ""
    static var smJustINSort : String? = ""
    
    static var categoryTopImageTitle : String? = ""
    static var categorySecondImageTitle : String? = ""
    static var categoryThirdImageTitle : String? = ""
    static var categoryFourthImageTitle : String? = ""
    static var categoryFifthImageTitle : String? = ""
    
    static var categoryTopImageCategoryId : SettingsCategory?
    static var categorySecondImageCategoryId : SettingsCategory?
    static var categoryThirdImageCategoryId : SettingsCategory?
    static var categoryFourthImageCategoryId : SettingsCategory?
    static var categoryFifthImageCategoryId : SettingsCategory?
    
    static var categoryTopImage : String? = ""
    static var categorySecondImage : String? = ""
    static var categoryThirdImage : String? = ""
    static var categoryFourthImage : String? = ""
    static var categoryFifthImage : String? = ""
    
    static var lifeStyleTopImage : String? = ""
    static var lifeStyleSecondImage : String? = ""
    static var lifeStyleThirdImage : String? = ""
    static var lifeStyleFourthImage : String? = ""
    static var lifeStyleFifthImage : String? = ""
    
    static var token : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.token.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.token.rawValue)
        }
    }
    
    static var userID : Int? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.userID.rawValue) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.userID.rawValue)
        }
    }
    
    static var gender : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.gender.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.gender.rawValue)
        }
    }
    
    static var email : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.email.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.email.rawValue)
        }
    }
    
    static var firstName : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.firstName.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.firstName.rawValue)
        }
    }
    
    static var lastName : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.lastName.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.lastName.rawValue)
        }
    }
    
    static var password : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.password.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.password.rawValue)
        }
    }
    
    static var phoneNumber : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.phoneNumber.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.phoneNumber.rawValue)
        }
    }
    
    static var location : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.location.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.location.rawValue)
        }
    }
    
    static var isSubscribed : Bool? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.subscribed.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.subscribed.rawValue)
        }
    }
    
    static var preownedSplashWatched : Bool? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.preownedSplashWatched.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.preownedSplashWatched.rawValue)
        }
    }
    
    static var firstSplashWatched : Bool? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.firstSplashWatched.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.firstSplashWatched.rawValue)
        }
    }
    
    static var shouldSendSignUpAnalytics : Bool? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.shouldSendSignUpAnalytics.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.shouldSendSignUpAnalytics.rawValue)
        }
    }
    
    static var shouldSendLoginAnalytics : Bool? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.shouldSendLoginAnalytics.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.shouldSendLoginAnalytics.rawValue)
        }
    }
    
    static var currentLoginSignupSource : String? {
        get {
            return UserDefaults.standard.value(forKey: UserPerferenceKey.currentLoginSignupSource.rawValue) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserPerferenceKey.currentLoginSignupSource.rawValue)
        }
    }
    
    static func setUserData(firstName : String? = nil, lastName : String? = nil, token : String? = nil, password : String? = nil , email : String? = nil, phoneNumber : String? = nil, isSubscribed : Bool? = nil, location : String? = nil, userID : Int?, gender : String?) {
       
        if let firstName = firstName {
            Userpreference.firstName = firstName
        }
        
        if let lastName = lastName {
            Userpreference.lastName = lastName
        }
        
        if let email = email {
            Userpreference.email = email
        }
        
        if let phoneNumber = phoneNumber {
            Userpreference.phoneNumber = phoneNumber
        }
        
        if let isSubscribed = isSubscribed {
            Userpreference.isSubscribed = isSubscribed
        }
        
        if let location = location {
            Userpreference.location = location
        }
        
        if let password = password {
            Userpreference.password = password
        }
        
        if let gender = gender {
            Userpreference.gender = gender
        }
        
        if let userID = userID {
            Userpreference.userID = userID
        }
    }
    
    static func resetValues() {
        Userpreference.email = nil
        Userpreference.password = nil
        Userpreference.token = nil
        Userpreference.phoneNumber = nil
        Userpreference.isSubscribed = nil
        Userpreference.firstName = nil
        Userpreference.lastName = nil
        Userpreference.userID = nil
        Userpreference.gender = nil
        Userpreference.location = nil
        UserDefaults.standard.removeObject(forKey: UserPerferenceKey.recentSearchData.rawValue)
        UserDefaults.standard.removeObject(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue)
        UserDefaults.standard.removeObject(forKey: UserPerferenceKey.popularSearchData.rawValue)
    }
    
}
