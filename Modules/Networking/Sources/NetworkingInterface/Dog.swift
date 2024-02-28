//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation

public struct Dog: Equatable {
    public var breed: String
    public var image: String

    public init(breed: String, image: String) {
        self.breed = breed
        self.image = image
    }
}
