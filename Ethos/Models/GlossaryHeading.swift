//
//  GlossaryHeading.swift
//  Ethos
//
//  Created by SoftGrid on 25/07/23.
//

import Foundation

class GlossaryHeading {
    var header : String = ""
    var data = [Glossary]()
    
    init(header: String, data: [Glossary] = [Glossary]()) {
        self.header = header
        self.data = data
    }
}
