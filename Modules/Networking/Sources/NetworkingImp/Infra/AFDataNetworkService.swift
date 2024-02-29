//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation
import Alamofire

public final class AFDataNetworkService: HTTPClient {

    let interceptor: Interceptor

    public init(interceptor: Interceptor) {
        self.interceptor = interceptor
    }
    public func get<T>(url: String, parameters: [String : Any], _ type: T.Type) -> any HTTPClientTask {
        let convertible: URLConvertible = url
        let request = AF.request(convertible, parameters: parameters, interceptor: interceptor)
        return request.serializingData() as! DataTask<T>
    }
}
