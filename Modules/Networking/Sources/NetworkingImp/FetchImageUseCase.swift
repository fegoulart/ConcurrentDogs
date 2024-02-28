//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import NetworkingInterface
import UIKit

public class FetchImageUseCase: FetchImageUseCaseProtocol {
    public typealias DogImage = UIImage
    let repository: any DogsRepositoryProtocol

    public init(repository: any DogsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(url: URL) async throws -> UIImage {
        guard let image: UIImage = try await repository.fetchImage(url: url) as? UIImage else {
            throw DogsError.invalidImageData
        }
        return image
    }
}

