//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import Alamofire

public final class NetworkRequest: DataTaskAbstractFactory {
    public typealias T = [DogDTO]

    public init() { }

    public func makeDataTask<T: Decodable>(
        url: String = "https://api.thedogapi.com/v1/breeds",
        limit: Int = 20,
        page: Int = 0
    ) -> NetworkRequestTask<T> {
        let convertible: URLConvertible = url
        let interceptor: Interceptor = Interceptor(
            adapter: MyAdapter(),
            retrier: MyRetrier()
        )
        let dataTask = AF.request(convertible, parameters: ["limit": limit, "page": page], interceptor: interceptor).serializingDecodable(T.self)
        let result: NetworkRequestTask<T> = NetworkRequestTask(dataTask: dataTask)
        return result
    }

    public func makeImageDataTask(
        url: URL
    ) -> NetworkRequestTask<Data> {
        let convertible: URLConvertible = url
        let interceptor: Interceptor = Interceptor(
            adapter: MyAdapter(),
            retrier: MyRetrier()
        )
        let dataTask = AF.request(
            convertible,
            interceptor: interceptor
        ).serializingData()
        let result: NetworkRequestTask<Data> = NetworkRequestTask(dataTask: dataTask)
        return result
    }
}
