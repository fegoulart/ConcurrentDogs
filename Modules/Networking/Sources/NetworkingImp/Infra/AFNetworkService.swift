//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation
import NetworkingInterface

public final class AFNetworkService: HTTPClient {

    let dataService: HTTPClient
    let decodableService: HTTPClient

    public init(dataService: HTTPClient, decodableService: HTTPClient) {
        self.dataService = dataService
        self.decodableService = decodableService
    }


    public func get<T>(url: String, parameters: [String : Any], _ type: T.Type) throws -> any HTTPClientTask {
        if type == Data.self {
            return try dataService.get(url: url, parameters: parameters, Data.self)
        }
        // if type == Decodable.self {
            return try decodableService.get(url: url, parameters: parameters, T.self)
        //}
        // FIXME: Create a more appropriate error
        //throw DogsError.invalidImageData
    }
}
