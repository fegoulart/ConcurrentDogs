//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import NetworkingInterface
import Alamofire
import UIKit

public enum DogsError: Error {
    case invalidImageData
}

public actor DogsRepository: DogsRepositoryProtocol {
    public typealias DogImage = UIImage

    let taskFactory: any DataTaskAbstractFactory<[DogDTO]>

    public init(taskFactory: any DataTaskAbstractFactory<[DogDTO]>) {
        self.taskFactory = taskFactory
    }

    public func fetchDogs(limit: Int, page: Int) async throws -> [Dog] {
        let task: NetworkRequestTask<[DogDTO]> = taskFactory.makeDataTask(
            url: "https://api.thedogapi.com/v1/breeds",
            limit: limit,
            page: page
        )
        let response: DataResponse<[DogDTO], AFError> = await task.getResponse()
        switch response.result {
        case .success(let dogs): 
            return dogs.map {
                Dog(breed: $0.name, image: $0.image.url)
            }
        case .failure(let error):
            throw error
        }
    }

    public func fetchImage(url: URL) async throws -> UIImage {
        let task: NetworkRequestTask<Data> = taskFactory.makeImageDataTask(url: url)
        let response: DataResponse<Data, AFError> = await task.getResponse()
        switch response.result {
        case .success(let imageData):
            guard let image = UIImage(data: imageData) else {
                throw DogsError.invalidImageData
            }
            return image
        case .failure(let error):
            throw error
        }
    }
}
