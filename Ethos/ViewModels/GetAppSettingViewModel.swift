//
//  GetAppSettingViewModel.swift
//  Ethos
//
//  Created by Softgrid on 26/07/24.
//

import Foundation


class GetAppSettingViewModel : NSObject {
    func getAppSettings(completion : @escaping() -> ()) {
        EthosApiManager().callApi(endPoint: EthosApiEndPoints.getAppSettings, RequestType: .GET, RequestParameters: [EthosConstants.site : Site.ethos.rawValue], RequestBody: [:]) { data, response, error in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any], json[EthosConstants.status] as? Bool == true, 
                let settingData = json[EthosConstants.data] as? [String : Any],
               let arrSettings = settingData["appSetting"] as? [[String : Any]] {
                
                for setting in arrSettings {
                    if let key = setting["setting_key"] as? String {
                        
                        switch key {
                            
                        case "shop_status" :
                            if setting["setting_value"] as? String == "Enable" {
                                Userpreference.shouldShowShopThroughOurBoutique = true
                            }
                            
                            
                        case "search_value" :
                            if setting["setting_value"] as? String == "Products" {
                                Userpreference.preferSearchProducts = true
                            }
                            
                            
                        case "ethos_justin_sort" :
                            Userpreference.ethosJustINSort = setting["setting_value"] as? String
                            
                            
                        case "sm_justin_sort" :
                            Userpreference.smJustINSort = setting["setting_value"] as? String
                            
                            
                        case "lifestyle_status" :
                            if setting["setting_value"] as? String == "Enable" {
                                Userpreference.shouldShowLifeStyle = true
                            }
                            
                            
                        case "lifestyle_top_image_title" :
                            Userpreference.lifeStyleTopImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "lifestyle_top_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.lifeStyleTopImageCategoryId = SettingsCategory(json: dict)
                            }  
                            
                        case "lifestyle_description" :
                            Userpreference.lifestyleDescription = setting["setting_value"] as? String
                            
                            
                        case "lifestyle_second_image_title" :
                            Userpreference.lifeStyleSecondImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "lifestyle_second_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.lifeStyleSecondImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                        case "lifestyle_third_image_title" :
                            Userpreference.lifeStyleThirdImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "lifestyle_third_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.lifeStyleThirdImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "lifestyle_fourth_image_title" :
                            Userpreference.lifeStyleFourthImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "lifestyle_fourth_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.lifeStyleFourthImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "lifestyle_fifth_image_title" :
                            Userpreference.lifeStyleFifthImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "lifestyle_fifth_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.lifeStyleFifthImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "category_status" :
                            if setting["setting_value"] as? String == "Enable" {
                                Userpreference.shouldShowFeaturesSection = true
                            }
                            
                            
                        case "category_top_image_title" :
                            Userpreference.categoryTopImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "category_top_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.categoryTopImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "category_second_image_title" :
                            Userpreference.categorySecondImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "category_second_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.categorySecondImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "category_third_image_title" :
                            Userpreference.categoryThirdImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "category_third_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.categoryThirdImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "category_fourth_image_title" :
                            Userpreference.categoryFourthImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "category_fourth_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.categoryFourthImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "category_fifth_image_title" :
                            Userpreference.categoryFifthImageTitle = (setting["setting_value"] as? String)?.replacingOccurrences(of: "\\n", with: "\n")
                            
                            
                        case "category_fifth_image_category_id" :
                            if let str = setting["setting_value"] as? String,
                                let data = str.data(using: .utf8),
                                let dict = try! JSONSerialization.jsonObject(with: data) as? [String : Any] {
                                Userpreference.categoryFifthImageCategoryId = SettingsCategory(json: dict)
                            }
                            
                            
                        case "delete_account_status" :
                            
                            if setting["setting_value"] as? String == "Enable" {
                                Userpreference.shouldShowDeleteAccount = true
                            }
                            
                            
                        case "skip_button_status" :
                            if setting["setting_value"] as? String == "Enable" {
                                Userpreference.shouldShowSkip = true
                            }
                            
                            
                        case "lifestyle_top_image" :
                            
                            Userpreference.lifeStyleTopImage = setting["setting_value"] as? String
                            
                            
                            
                        case "lifestyle_second_image" :
                            Userpreference.lifeStyleSecondImage = setting["setting_value"] as? String
                            
                            
                            
                        case "lifestyle_third_image" :
                            Userpreference.lifeStyleThirdImage = setting["setting_value"] as? String
                            
                            
                            
                        case "lifestyle_fourth_image" :
                            Userpreference.lifeStyleFourthImage = setting["setting_value"] as? String
                            
                            
                            
                        case "lifestyle_fifth_image" :
                            Userpreference.lifeStyleFifthImage = setting["setting_value"] as? String
                            
                            
                            
                        case "category_top_image" :
                            Userpreference.categoryTopImage = setting["setting_value"] as? String
                            
                            
                            
                        case "category_second_image" :
                            Userpreference.categorySecondImage = setting["setting_value"] as? String
                            
                            
                            
                        case "category_third_image" :
                            Userpreference.categoryThirdImage = setting["setting_value"] as? String
                            
                            
                            
                        case "category_fourth_image" :
                            Userpreference.categoryFourthImage = setting["setting_value"] as? String
                            
                            
                            
                        case "category_fifth_image" :
                            Userpreference.categoryFifthImage = setting["setting_value"] as? String
                            
                        default:
                            break
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
                
            }
        }
    }
}
