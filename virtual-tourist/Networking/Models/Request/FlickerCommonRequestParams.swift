//
//  FlickerCommonRequestParams.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

struct FlickerSearchRequestParams: DictionaryConvertible {
    
    let nojsoncallback = 1
    let api_key = "432097f7e40dab646eb8ab911e392371"
    let method = "flickr.photos.search"
    let format = "json"
}
