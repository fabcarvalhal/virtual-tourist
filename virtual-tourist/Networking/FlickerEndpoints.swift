//
//  FlickerEndpoints.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

enum FlickerEndpoint: Endpoint {
    
    case searchPhotos
    
    var baseUrl: String {
        "https://www.flickr.com/services/rest/"
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var path: String {
        ""
    }
    
    var headers: [String : Any] {
        [:]
    }
    
    
}
