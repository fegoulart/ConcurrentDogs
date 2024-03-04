//
//  File.swift
//  
//
//  Created by Fernando Goulart on 3/4/24.
//

//import Foundation
//import NetworkingInterface
//import UIKit
//import Alamofire
//
//public protocol
//
//public actor TaskGroupDogsRepositoryDecorator: DogsRepositoryProtocol {
//    public typealias DogImage = UIImage
//
//    let decoratee: any DogsRepositoryProtocol
//
//    public init(decoratee: any DogsRepositoryProtocol) {
//        self.decoratee = decoratee
//    }
//
//    public func fetchDogs(limit: Int, page: Int) async throws -> [NetworkingInterface.Dog] {
//        return try await decoratee.fetchDogs(limit: limit, page: page)
//    }
//}
//
//extension TaskGroupDogsRepositoryDecorator {
//
//    var imageTaskGroup: TaskGroup<UIImage> = await withTaskGroup(of: UIImage.self) {group in 
//
//    }
//
//    public func fetchImage(url: URL) async throws -> UIImage {
//
//    }
//
//    public func cancelImageRequest(url: URL) async throws {
//        
//    }
//}
//
//public actor DogImage {
//    @TaskLocal static var url: String?
//    var makeDataTask: (String) -> DataTask<Data>
//
//    public init(makeDataTask: @escaping (String) -> DataTask<Data>) {
//        self.makeDataTask = makeDataTask
//    }
//
//    public func execute() async throws -> Data {
//        guard let endpoint: String = DogImage.url else {
//            // FIXME: use proper error
//            throw DogsError.invalidImageData
//        }
//        try Task.checkCancellation()
//        let dataTask = makeDataTask(endpoint)
//        return try await withTaskCancellationHandler {
//            let response = await dataTask.response.result
//            switch response {
//            case .success(let imageData):
//                return imageData
//            case .failure(let error):
//                throw error
//            }
//        } onCancel: {
//            dataTask.cancel()
//        }
//    }
//}
