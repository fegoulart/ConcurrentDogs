//
//  File.swift
//  
//
//  Created by Fernando Goulart on 3/1/24.
//

import Foundation

public protocol CancelDogImageRequestUseCaseProtocol {
    func execute(url: URL) async throws
}
