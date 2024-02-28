//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import Alamofire

public protocol DogTask<T> {
    associatedtype T

    var response: DataResponse<T, AFError> { get async }
    func cancel()
}
