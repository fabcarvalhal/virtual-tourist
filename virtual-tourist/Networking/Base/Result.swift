//
//  Result.swift
//  OnTheMap
//
//  Created by Fabrício Silva Carvalhal on 05/06/21.
//

import Foundation

public enum Result<T> {
    
    case success(T)
    case failure(Error)
}
