//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation

public protocol FetchDogImageUseCaseProtocol {
    associatedtype DogImage: Sendable

    func execute(url: URL) async throws -> DogImage
}
