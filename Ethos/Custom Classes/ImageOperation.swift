//
//  ImageOperation.swift
//  Ethos
//
//  Created by mac on 13/09/23.
//

import Foundation
import UIKit

class ImageOperation : Operation {
    
    let url : String
    
    init(url: String, completion: @escaping ((UIImage) -> ())) {
        self.url = url
        self.completion = completion
    }
    
    var completion : ((UIImage) -> ())
    
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let url = URL(string: self.url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = RequestType.GET.rawValue
        
        
        if self.isCancelled {
            return
        }
        
        
        
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if self.isCancelled {
                    return
                }
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let data = data {
                            DispatchQueue.main.async {
                                self.completion((UIImage(data: data) ?? UIImage()))
                            }
                        }
                    }
                }
            }
            task.resume()
        }
        
    }
}
