//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import NetworkingInterface

public class FetchDogsUseCase: FetchDogsUseCaseProtocol {

    let repository: any DogsRepositoryProtocol

    public init(repository: any DogsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(limit: Int, page: Int) async throws -> [Dog] {
        return try await repository.fetchDogs(limit: limit, page: page)
    }
}
