//
//  File.swift
//  
//
//  Created by Fernando Goulart on 2/29/24.
//

import Foundation

public protocol HTTPClient: Sendable {
    func get<T>(url: String, parameters: [String: Any], _ type: T.Type) throws -> any HTTPClientTask
}
