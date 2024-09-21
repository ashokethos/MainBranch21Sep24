//
//  GetVideoViewModel.swift
//  Ethos
//
//  Created by mac on 21/09/23.
//

import Foundation

class GetVideoViewModel {
    var delegate : GetVideoModelDelegate?
    func getVideoUrlFromId(id : String, index : IndexPath) {
        EthosApiManager().callApi(endPoint: "", RequestType: .GET, RequestParameters: ["video" : id], RequestBody: [:], forVideo: true) { data, response, error in
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                let video = (json["video"] as? String) ?? ""
                let image = (json["image"] as? String) ?? ""
                self.delegate?.didGetUrl(url : video , image : image, index: index)
            }
        }
    }
}



