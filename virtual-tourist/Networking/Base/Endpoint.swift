//
//  Endpoint.swift
//  OnTheMap
//
//  Created by Fabrício Silva Carvalhal on 05/06/21.
//

import Foundation

protocol Endpoint {
    
    var baseUrl: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: Any] { get }
}

