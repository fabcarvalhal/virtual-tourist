//
//  BaseApiClient.swift
//  OnTheMap
//
//  Created by Fabrício Silva Carvalhal on 12/06/21.
//

import Foundation


class BaseApiClient {
    
    private let urlRequester: URLRequester
    
    init(urlRequester: URLRequester = URLRequester()) {
        self.urlRequester = urlRequester
    }
    
    func makeRequest<T: Codable>(with urlRequest: URLRequest,
                                 jsonHandler: SimpleJSONHandler<T> = SimpleJSONHandler<T>(),
                                 completion: @escaping (Result<T>) -> Void) {
        urlRequester.makeRequest(with: urlRequest) { response in
            switch response {
            case .success(let data):
                do {
                    let responseObject = try jsonHandler.decode(data)
                    completion(.success(responseObject))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeRequest(with urlRequest: URLRequest,
                                 completion: @escaping (Result<Data>) -> Void) {
        urlRequester.makeRequest(with: urlRequest) { response in
            switch response {
            case .success(let data):
                    completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

