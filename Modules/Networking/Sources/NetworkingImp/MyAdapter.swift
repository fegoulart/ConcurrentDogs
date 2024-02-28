//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import Alamofire

public class MyAdapter: RequestAdapter {
    public func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.headers.add(name: "x-api-key", value: "live_LR9k2dReFOvCrsSnKy6q0zX3QJQ6RBg3P16dT73KT0hdEcfjFFujDJ1fDer9FSGr")
        completion(.success(urlRequest))
    }
}
