//
//  SearchPhotosResponse.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

struct SearchPhotosResponse: Codable {
    
    let photos: [SearchPhotosResponseItem]
}

struct SearchPhotosResponseItem: Codable {
    
    let id: String
    let owner: String
    let server: String
    let farm: Int
    let title: String
}
