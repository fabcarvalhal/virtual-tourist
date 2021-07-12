//
//  SimpleJSONHandler.swift
//  OnTheMap
//
//  Created by Fabrício Silva Carvalhal on 12/06/21.
//

import Foundation

enum SimpleJSONHandlerError: Error  {
    
    case parseError
    case encodingError
}


final class SimpleJSONHandler<T: Codable> {
    
    // Needed for the data subrange on udacity api
    private let decodeDataAfter: Int?
    
    init(decodeDataAfter: Int? = nil) {
        self.decodeDataAfter = decodeDataAfter
    }
    
    func decode(_ data: Data) throws -> T  {
        var dataToDecode = data
        if let decodeDataAfter = decodeDataAfter {
            let range = decodeDataAfter..<data.count
            dataToDecode = dataToDecode.subdata(in: range)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: dataToDecode)
            return decodedData
        } catch {
            throw SimpleJSONHandlerError.parseError
        }
    }
    
    func encode(_ value: T) throws -> Data {
        do {
            let encodedData = try JSONEncoder().encode(value)
            return encodedData
        } catch {
            throw SimpleJSONHandlerError.encodingError
        }
    }
}
