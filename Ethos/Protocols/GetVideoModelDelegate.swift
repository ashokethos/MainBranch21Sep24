//
//  GetVideoModelDelegate.swift
//  Ethos
//
//  Created by mac on 25/10/23.
//

import Foundation

protocol GetVideoModelDelegate {
    func didGetUrl(url : String, image : String, index : IndexPath)
}
