//
//  SearchPhotosRequest.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

struct SearchPhotosRequest: DictionaryConvertible {
    
    let lat: String
    let lon: String
    let page: String
    let method = "flickr.photos.search"
}
