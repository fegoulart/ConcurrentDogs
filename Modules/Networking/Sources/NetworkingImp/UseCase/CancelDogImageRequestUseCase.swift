//
//  File.swift
//  
//
//  Created by Fernando Goulart on 3/1/24.
//

import Foundation
import NetworkingInterface

public class CancelDogImageRequestUseCase: CancelDogImageRequestUseCaseProtocol {
    let repository: any DogsRepositoryProtocol

    public init(repository: any DogsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(url: URL) async throws {
        try await repository.cancelImageRequest(url: url)
    }
}
