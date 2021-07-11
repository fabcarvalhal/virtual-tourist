import Foundation
import CoreLocation

protocol FlickerAPIInterface: AnyObject {
    
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
}
