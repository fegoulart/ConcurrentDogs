//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation
import Alamofire

extension Alamofire.DataTask: HTTPClientTask {
    public typealias T = Value

    public func getResponse() async throws -> Value {
        let result = await self.response.result
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
