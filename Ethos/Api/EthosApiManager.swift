//
//  EthosApiManager.swift
//  Ethos
//
//  Created by SoftGrid on 13/07/23.
//

import Foundation
import UIKit

class EthosApiManager {
    
    func callApi(endPoint:String, RequestType : RequestType, RequestParameters : [String:String], RequestBody : [String:Any],forVideo : Bool = false ,completionHandler :@escaping (Data?,URLResponse?,Error?) -> ()) {
        var urlComponents = URLComponents(string:  forVideo ? (EthosIdentifiers.baseVideoUrl) : (EthosIdentifiers.baseurl + endPoint))
        if !RequestParameters.isEmpty {
            var queryItems = [URLQueryItem]()
            for (key,value) in RequestParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            urlComponents?.queryItems = queryItems
        }
        
        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = RequestType.rawValue
            
            if RequestType == .POST || RequestType == .PUT {
                request.httpBody = try? JSONSerialization.data(withJSONObject: RequestBody, options: [])
            }
            
            request.addValue(EthosConstants.applicationJson, forHTTPHeaderField: EthosConstants.contentType)
            request.addValue(EthosConstants.bearer + " " + EthosIdentifiers.apitoken, forHTTPHeaderField: EthosConstants.authorization)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        UIApplication.topViewController()?.showAlertWithSingleTitle(title: error.localizedDescription, message: "")
                    }
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                let json = try? JSONSerialization.jsonObject(with: data ?? Data()) as? [String : Any]
                
                print("******** ----------- Api call -----------********\n URL : \(url.absoluteString)\n\n\nParameters : \(RequestParameters.debugDescription)\n\n\nRequestBody :- \(RequestBody.debugDescription)\n\n\nRequestHeaders :-  \((request.allHTTPHeaderFields ?? [:]).debugDescription)\n\n\nStatus Code :- \(statusCode ?? 500)\n\n\nRespose Json :- \n\n \((json ?? [:]).debugDescription)\n\n\n******** ----------- End -----------********")
                
                completionHandler(data,response,error)
            }
            task.resume()
        }
    }
    
    func callMultiPartFormApi(endPoint:String, RequestParameters : [String:String], RequestBody : [String:String], images : [UIImage] , imageKey : String , completionHandler :@escaping (Data?,URLResponse?,Error?) -> ()) {
        
        var urlComponents = URLComponents(string: EthosIdentifiers.baseurl + endPoint)
        if !RequestParameters.isEmpty {
            var queryItems = [URLQueryItem]()
            for (key,value) in RequestParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            
            urlComponents?.queryItems = queryItems
        }
        
        guard let url = urlComponents?.url else { return }
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var request = URLRequest(url: url)
        
        
        var mediaImages = [FormMedia]()
        
        for image in images {
            if let mediaImage = FormMedia(withImage: image, key: imageKey) {
                mediaImages.append(mediaImage)
            }
        }
        
        request.httpMethod = RequestType.POST.rawValue
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(EthosConstants.bearer + " " + EthosIdentifiers.apitoken, forHTTPHeaderField: EthosConstants.authorization )
        
        let dataBody = createDataBody(withParameters: RequestBody, media: mediaImages, boundary: boundary)
        
        request.httpBody = dataBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)}.resume()
    }
    
    
    private func createDataBody(withParameters params: [String: String], media: [FormMedia], boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        for (key, value) in params {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
            body.append("\(value + lineBreak)")
        }
        
        for photo in media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
            body.append(photo.data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
}




