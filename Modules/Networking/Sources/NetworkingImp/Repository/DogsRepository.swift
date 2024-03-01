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

public actor DogsRepository: DogsRepositoryProtocol {
    public typealias DogImage = UIImage

    let httpClient: HTTPClient
    var fetchDogsTasks: [FetchDogTask: DataTask<[DogDTO]>] = [:]
    var fetchImageTasks: [String: DataTask<Data>] = [:]

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func fetchDogs(limit: Int, page: Int) async throws -> [Dog] {
        let url: String = "https://api.thedogapi.com/v1/breeds"
        let parameters: [String: Any] = ["limit": limit, "page": page]
        let fetchDogTask = FetchDogTask(limit: limit, page: page)
        guard fetchDogsTasks[fetchDogTask] == nil else {
            assertionFailure("not expected")
            // FIXME: Create a proper error
            throw DogsError.invalidImageData
        }
        let task: DataTask<[DogDTO]> = try httpClient.get(url: url, parameters: parameters, [DogDTO].self) as! DataTask<[DogDTO]>
        fetchDogsTasks[fetchDogTask] = task
        let response = await task.response.result
        fetchDogsTasks.removeValue(forKey: fetchDogTask)
        switch response {
        case .success(let dogs):
            return dogs.map {
                Dog(breed: $0.name, image: $0.image.url)
            }
        case .failure(let error):
            throw error
        }
    }

    public func fetchImage(url: URL) async throws -> UIImage {
        guard fetchImageTasks[url.absoluteString] == nil else {
            // assertionFailure("not expected")
            throw DogsError.taskAlreadyExists
        }
        let task: DataTask<Data> = try httpClient.get(url: url.absoluteString, parameters: [:], Data.self) as! DataTask<Data>
        fetchImageTasks[url.absoluteString] = task
        let response = await task.response.result
        fetchImageTasks.removeValue(forKey: url.absoluteString)
        switch response {
        case .success(let imageData):
            guard let result = UIImage(data: imageData) else {
                throw DogsError.invalidImageData
            }
            return result
        case .failure(let error):
            throw error
        }
    }

    public func cancelImageRequest(url: URL) async throws {
        guard let task = fetchImageTasks[url.absoluteString] else {
            //assertionFailure("not expected")
            throw DogsError.couldNotFindTaskToCancel
        }
        task.cancel()
    }
}
