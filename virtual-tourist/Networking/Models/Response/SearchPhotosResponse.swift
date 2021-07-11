//
//  SearchPhotosResponse.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

struct SearchPhotosResponse: Codable {
    
    let response: SearchPhotosResponseInner
    
    enum CodingKeys: String, CodingKey {
        
        case response = "photos"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        response = try container.decode(SearchPhotosResponseInner.self, forKey: .response)
    }
}

struct SearchPhotosResponseItem: Codable {
    
    let id: String
    let owner: String
    let server: String
    let farm: Int
    let secret: String
}

struct SearchPhotosResponseInner: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photoList: [SearchPhotosResponseItem]
    
    enum CodingKeys: String, CodingKey {
        
        case page
        case pages
        case perpage
        case total
        case photoList = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try container.decode(Int.self, forKey: .page)
        total = try container.decode(Int.self, forKey: .total)
        pages = try container.decode(Int.self, forKey: .pages)
        perpage = try container.decode(Int.self, forKey: .perpage)
        photoList = try container.decode([SearchPhotosResponseItem].self, forKey: .photoList)
    }
}
