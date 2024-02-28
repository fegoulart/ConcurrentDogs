//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import Alamofire

public actor NetworkRequestTask<T> {
    var dataTask: any DogTask<T>

    public init(dataTask: any DogTask<T>) {
        self.dataTask = dataTask
    }

    public func getResponse() async -> DataResponse<T, AFError> {
        return await dataTask.response
    }

    public func cancel() {
        return dataTask.cancel()
    }

}
