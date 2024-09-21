//
//  GetRevolutionData.swift
//  Ethos
//
//  Created by Ashok kumar on 31/07/24.
//

import Foundation

//class GetRevolutionData: Codable {
//    var post_id: Int?
//    var title: String?
//    var url: String?
//    var description: String?
//    var date: String?
//    var mobile_image: String?
//    var desktop_image: String?
//    var thumbnail: String?
//    var thumbnail_1: String?
//    var thumbnail_2: String?
//    var thumbnail_3: String?
//    var thumbnail_4: String?
//    var thumbnail_5: String?
//    var read_time: String?
//    var readme: String?
//    
//    init(post_id: Int? = nil, title: String? = nil, url: String? = nil, description: String? = nil, date: String? = nil, mobile_image: String? = nil, desktop_image: String? = nil, thumbnail: String? = nil, thumbnail_1: String? = nil, thumbnail_2: String? = nil, thumbnail_3: String? = nil, thumbnail_4: String? = nil, thumbnail_5: String? = nil, read_time: String? = nil, readme: String? = nil) {
//        self.post_id = post_id
//        self.title = title
//        self.url = url
//        self.description = description
//        self.date = date
//        self.mobile_image = mobile_image
//        self.desktop_image = desktop_image
//        self.thumbnail = thumbnail
//        self.thumbnail_1 = thumbnail_1
//        self.thumbnail_2 = thumbnail_2
//        self.thumbnail_3 = thumbnail_3
//        self.thumbnail_4 = thumbnail_4
//        self.thumbnail_5 = thumbnail_5
//        self.read_time = read_time
//        self.readme = readme
//    }
//    
//    init (json : [String : Any]) {
//        if let post_id = json["post_id"] as? Int {
//            self.post_id = post_id
//        }
//        
//        if let post_id = json["post_id"] as? String {
//            self.post_id = Int(post_id)
//        }
//        
//        if let title = json["title"] as? String {
//            self.title = title
//        }
//        
//        if let url = json["url"] as? String {
//            self.url = url
//        }
//        
//        if let description = json["description"] as? String {
//            self.description = description
//        }
//        
//        if let date = json["date"] as? String {
//            self.date = date
//        }
//        
//        if let mobile_image = json["mobile_image"] as? String {
//            self.mobile_image = mobile_image
//        }
//        
//        if let desktop_image = json["desktop_image"] as? String {
//            self.desktop_image = desktop_image
//        }
//        
//        if let thumbnail = json["thumbnail"] as? String {
//            self.thumbnail = thumbnail
//        }
//        
//        if let thumbnail = json["thumbnail"] as? Bool {
//            self.thumbnail = String(thumbnail)
//        }
//        
//        if let thumbnail_1 = json["thumbnail_1"] as? String {
//            self.thumbnail_1 = thumbnail_1
//        }
//        
//        if let thumbnail_1 = json["thumbnail_1"] as? Bool {
//            self.thumbnail_1 = String(thumbnail_1)
//        }
//        
//        if let thumbnail_2 = json["thumbnail_2"] as? String {
//            self.thumbnail_2 = thumbnail_2
//        }
//        
//        if let thumbnail_2 = json["thumbnail_2"] as? Bool {
//            self.thumbnail_2 = String(thumbnail_2)
//        }
//        
//        if let thumbnail_3 = json["thumbnail_3"] as? String {
//            self.thumbnail_3 = thumbnail_3
//        }
//        
//        if let thumbnail_3 = json["thumbnail_3"] as? Bool {
//            self.thumbnail_3 = String(thumbnail_3)
//        }
//        
//        if let thumbnail_4 = json["thumbnail_4"] as? String {
//            self.thumbnail_4 = thumbnail_4
//        }
//        
//        if let thumbnail_4 = json["thumbnail_4"] as? Bool {
//            self.thumbnail_4 = String(thumbnail_4)
//        }
//        
//        if let thumbnail_5 = json["thumbnail_5"] as? String {
//            self.thumbnail_5 = thumbnail_5
//        }
//        
//        if let thumbnail_5 = json["thumbnail_5"] as? Bool {
//            self.thumbnail_5 = String(thumbnail_5)
//        }
//        
//        if let read_time = json["read_time"] as? String {
//            self.read_time = read_time
//        }
//        
//        if let readme = json["readme"] as? String {
//            self.readme = readme
//        }
//    }
//}


class GetRevolutionData: Codable {
    var post_id: Int?
    var title: String?
    var url: String?
    var description: String?
    var date: String?
    var mobile_image: String?
    var desktop_image: String?
    var thumbnail: String?
    var thumbnail_1: String?
    var thumbnail_2: String?
    var thumbnail_3: String?
    var thumbnail_4: String?
    var thumbnail_5: String?
    var read_time: String?
    var readme: String?

    // Custom decoding method
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        post_id = try container.decodeIfPresent(Int.self, forKey: .post_id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        mobile_image = try container.decodeIfPresent(String.self, forKey: .mobile_image)
        desktop_image = try container.decodeIfPresent(String.self, forKey: .desktop_image)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        thumbnail_1 = try container.decodeIfPresent(String.self, forKey: .thumbnail_1)
        thumbnail_2 = try container.decodeIfPresent(String.self, forKey: .thumbnail_2)
        // Custom decoding for thumbnail_3
        if let thumbnail3String = try? container.decode(String.self, forKey: .thumbnail_3) {
            thumbnail_3 = thumbnail3String
        } else if let thumbnail3Bool = try? container.decode(Bool.self, forKey: .thumbnail_3) {
            // Convert Bool to String if needed
            thumbnail_3 = thumbnail3Bool ? "true" : "false"
        }
        if let thumbnail3String = try? container.decode(String.self, forKey: .thumbnail_3) {
            thumbnail_3 = thumbnail3String
        } else if let thumbnail3Bool = try? container.decode(Bool.self, forKey: .thumbnail_3) {
            // Convert Bool to String if needed
            thumbnail_3 = thumbnail3Bool ? "true" : "false"
        }
        
        if let thumbnail4String = try? container.decode(String.self, forKey: .thumbnail_4) {
            thumbnail_4 = thumbnail4String
        } else if let thumbnail4Bool = try? container.decode(Bool.self, forKey: .thumbnail_4) {
            // Convert Bool to String if needed
            thumbnail_4 = thumbnail4Bool ? "true" : "false"
        }
        
        if let thumbnail5String = try? container.decode(String.self, forKey: .thumbnail_5) {
            thumbnail_5 = thumbnail5String
        } else if let thumbnail5Bool = try? container.decode(Bool.self, forKey: .thumbnail_5) {
            // Convert Bool to String if needed
            thumbnail_5 = thumbnail5Bool ? "true" : "false"
        }
        read_time = try container.decodeIfPresent(String.self, forKey: .read_time)
        readme = try container.decodeIfPresent(String.self, forKey: .readme)
    }
    
    enum CodingKeys: String, CodingKey {
        case post_id
        case title
        case url
        case description
        case date
        case mobile_image
        case desktop_image
        case thumbnail
        case thumbnail_1
        case thumbnail_2
        case thumbnail_3
        case thumbnail_4
        case thumbnail_5
        case read_time
        case readme
    }
}
