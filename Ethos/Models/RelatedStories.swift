//
//  RelatedStories.swift
//  Ethos
//
//  Created by Softgrid on 09/05/24.
//

import UIKit

class RelatedStories : NSObject {
    var storyHeading: String?
    var stories: [Story]?
    
    init(storyHeading: String? = nil, stories: [Story]? = nil) {
        self.storyHeading = storyHeading
        self.stories = stories
    }
    
    init(json : [String : Any]) {
        if let storyHeading = json[EthosConstants.storyHeading] as? String {
            self.storyHeading = storyHeading
        }
        
        if let stories = json[EthosConstants.stories] as? [[String : Any]] {
            var arrStory = [Story]()
            
            for _ in stories {
                let val = Story()
                arrStory.append(val)
            }
            
            self.stories = arrStory
        }
    }
}
