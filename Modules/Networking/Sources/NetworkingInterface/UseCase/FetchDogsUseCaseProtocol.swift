//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation

public protocol FetchDogsUseCaseProtocol: Sendable {
    func execute(limit: Int, page: Int) async throws -> [Dog]
}
