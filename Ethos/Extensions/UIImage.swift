//
//  UIImage.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit

extension UIImage {
    
    class func imageWithName(name : String) -> UIImage {
        return UIImage(named: name) ?? UIImage()
    }
    
    class func loadFromURL(url: String, callback: @escaping(UIImage)->()) {
        guard let replacedString = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              let url = URL(string: replacedString) else {
            return
        }
        
        DispatchQueue.global().async {
            let imageData = try? Data(contentsOf: url)
            if let data = imageData {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        callback(image)
                    }
                }
            }
        }
    }
    
    class func loadAsyncFromURL(url: String, index : IndexPath, callback: @escaping(UIImage, IndexPath)->()) {
        guard let replacedString = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
              let url = URL(string: replacedString) else {
            return
        }
        DispatchQueue.global().async {
            let imageData = try? Data(contentsOf: url)
            if let data = imageData {
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        callback(image, index)
                    }
                }
            }
        }
    }
    
    class func checkImageResponse() {
        guard let url = URL(string: "https://dev.ethoswatches.com/the-watch-guide/wp-content/uploads/2023/08/dive-watch-guide-featued@2x-1.jpg") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = RequestType.GET.rawValue
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
                
                if let data = data {
                    print(data)
                }
            }
        }
        task.resume()
    }
    
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
