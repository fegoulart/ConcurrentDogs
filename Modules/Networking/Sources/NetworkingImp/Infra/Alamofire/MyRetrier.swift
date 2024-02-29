//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import Alamofire

public class MyRetrier: RequestRetrier {
    public init() { }

    public func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        completion(.doNotRetry)
    }

}
