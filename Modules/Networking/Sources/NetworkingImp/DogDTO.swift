//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/28/24.
//

import Foundation
import Alamofire

// live_LR9k2dReFOvCrsSnKy6q0zX3QJQ6RBg3P16dT73KT0hdEcfjFFujDJ1fDer9FSGr
// https://api.thedogapi.com/v1/breeds
/*
 https://developers.thecatapi.com/view-account/ylX4blBYT9FaoVd6OhvR?report=bOoHBz-8t

 Use it as the 'x-api-key' header when making any request to the API, or by adding as a query string parameter e.g. 'api_key=live_LR9k2dReFOvCrsSnKy6q0zX3QJQ6RBg3P16dT73KT0hdEcfjFFujDJ1fDer9FSGr'
 */

public struct DogDTO: Codable {
    public var id: Int
    public var name: String
    public var image: DogImageDTO

    public init(id: Int, name: String, image: DogImageDTO) {
        self.id = id
        self.name = name
        self.image = image
    }
}

