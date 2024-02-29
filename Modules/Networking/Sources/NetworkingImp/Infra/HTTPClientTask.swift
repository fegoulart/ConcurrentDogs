//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation

public protocol HTTPClientTask<T> {
    associatedtype T

    func getResponse() async throws -> T
    func cancel()
}
