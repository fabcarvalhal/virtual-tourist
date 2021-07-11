import Foundation

protocol URLRequestAdapter {
    
    func adapt(_ urlRequest: inout URLRequest)
}
