//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation

public protocol DogsRepositoryProtocol {
    associatedtype DogImage

    func fetchDogs(limit: Int, page: Int) async throws -> [Dog]
    func fetchImage(url: URL) async throws -> DogImage
}
