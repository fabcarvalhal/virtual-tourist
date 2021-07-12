import Foundation
import CoreLocation

protocol FlickerAPIInterface: AnyObject {
    
    func searchPhotos(request: SearchPhotosRequest,
                      completion: @escaping (Result<SearchPhotosResponse>) -> Void)
    
    func downloadPhoto(url: String, completion: @escaping (Result<Data>) -> Void)
}

final class FlickerAPIClient: BaseApiClient, FlickerAPIInterface {
    
    func searchPhotos(request: SearchPhotosRequest,
                      completion: @escaping (Result<SearchPhotosResponse>) -> Void) {
        let endpoint = FlickerEndpoint.searchPhotos
        
        do {
            let request = try URLRequestBuilder(with: endpoint.baseUrl)
                .set(method: endpoint.method)
                .set(params: .query(request.toDictionary()))
                .set(adapter: FlickerRequestAdapter())
                .build()
            
            makeRequest(with: request,
                        completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    func downloadPhoto(url: String, completion: @escaping (Result<Data>) -> Void) {
        do {
            let request = try URLRequestBuilder(with: url)
                .set(headers: [HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue])
                .build()
            
            makeRequest(with: request,
                        completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}
