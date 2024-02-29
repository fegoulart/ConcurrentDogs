//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation
import Alamofire

public final class AFDecodableNetworkService<T: Decodable>: HTTPClient {

    let interceptor: Interceptor

    public init(interceptor: Interceptor) {
        self.interceptor = interceptor
    }

    public func get<R>(url: String, parameters: [String : Any], _ type: R.Type) -> any HTTPClientTask {
        let convertible: URLConvertible = url
        let request = AF.request(convertible, parameters: parameters, interceptor: interceptor)
        let task: DataTask<T> = request.serializingDecodable()
        return task
    }

}
