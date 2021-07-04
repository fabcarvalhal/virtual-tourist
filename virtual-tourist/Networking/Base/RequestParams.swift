//
//  RequestParams.swift
//  OnTheMap
//
//  Created by Fabrício Silva Carvalhal on 05/06/21.
//

import Foundation

enum RequestParams {
    
    typealias QueryParameters = [String: Any]
    
    case body(Data?)
    case query(QueryParameters?)
}
