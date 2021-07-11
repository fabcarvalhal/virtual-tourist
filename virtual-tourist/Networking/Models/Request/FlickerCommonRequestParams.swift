//
//  FlickerCommonRequestParams.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

struct FlickerSearchRequestParams: DictionaryConvertible {
    
    let nojsoncallback = 1
    let api_key = "e9ffade65473cd2a5325fffbad7ae681"
    let method = "flickr.photos.search"
    let format = "json"
}
