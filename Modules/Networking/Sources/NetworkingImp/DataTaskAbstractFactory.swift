//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation

public protocol DataTaskAbstractFactory<T> {
    associatedtype T: Decodable

    func makeDataTask(
        url: String,
        limit: Int,
        page: Int
    ) -> NetworkRequestTask<T>

    func makeImageDataTask(
        url: URL
    ) -> NetworkRequestTask<Data>
}
