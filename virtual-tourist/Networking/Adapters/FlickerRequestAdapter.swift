//
//  FlickerRequestAdapter.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation

final class FlickerRequestAdapter: URLRequestAdapter {
    
    func adapt(_ urlRequest: inout URLRequest) {
        guard let absoluteStringUrl = urlRequest.url?.absoluteURL.absoluteString else { return }
        let additionalParams = FlickerSearchRequestParams().toDictionary()
        let additionalQueryItems = additionalParams.map { pair  in
            return URLQueryItem(name: pair.key, value: "\(pair.value)")
        }
        
        var components = URLComponents(string: absoluteStringUrl)
        
        if let currentparams = components?.queryItems {
            components?.queryItems = additionalQueryItems + currentparams
        }
        
        urlRequest.url = components?.url
    }
}
