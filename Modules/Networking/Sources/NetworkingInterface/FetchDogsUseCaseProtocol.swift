//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation

public protocol FetchDogsUseCaseProtocol {
    func execute(limit: Int, page: Int) async throws -> [Dog]
}

public protocol FetchImageUseCaseProtocol {
    associatedtype DogImage

    func execute(url: URL) async throws -> DogImage
}
