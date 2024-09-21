//
//  FavreLeubaData.swift
//  Ethos
//
//  Created by mac on 23/08/23.
//


import Foundation

class FavreLeubaData {
    var videoThumbnail: String?
    var videoUrl: String?
    var mainText: MainText?
    var subText: [SubText]?

    init(videoThumbnail: String?, videoUrl: String?, mainText: MainText?, subText: [SubText]?) {
        self.videoThumbnail = videoThumbnail
        self.videoUrl = videoUrl
        self.mainText = mainText
        self.subText = subText
    }
    
    init(json : [String : Any]) {
        if let videoThumbnail = json[EthosConstants.videoThumbnail] as? String {
            self.videoThumbnail = videoThumbnail
        }
        
        if let videoUrl = json[EthosConstants.videoURL] as? String {
            self.videoUrl = videoUrl
        }
        
        if let mainText = json[EthosConstants.mainText] as? [String : Any] {
            self.mainText = MainText(json: mainText)
        }
        
        if let subText = json[EthosConstants.subText] as? [[String : Any]] {
            var arrText = [SubText]()
            for text in subText {
                let txt = SubText(json: text)
                arrText.append(txt)
            }
            
            self.subText = arrText.sorted(by: { txt1, txt2 in
                (txt2.order ?? 0) > (txt1.order ?? 0)
            })
        }
    }
}

