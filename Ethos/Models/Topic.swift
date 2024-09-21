//
//  HelpAndServiceModel.swift
//  Ethos
//
//  Created by mac on 08/08/23.
//

import UIKit

class Topic: NSObject {
    var title : String
    var subtitle : String
    var image : String
    var subTopics = [Topic]()
    var ArrQues = [QuestionAnswer]()
    
    init(title: String, subtitle: String, image: String, subTopics: [Topic] = [Topic](), ArrQues: [QuestionAnswer] = [QuestionAnswer]()) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.subTopics = subTopics
        self.ArrQues = ArrQues
    }
}
