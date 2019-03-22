//
//  JSONAPIKeys.swift
//  jab
//
//  Created by Dino on 20/03/2019.
//

import Foundation

enum JSONAPIKeys: String {
    case jsonapi
    case links
    case data
    case attributes
    case relationships
    case type
    case id
    case included
    case identifier
}

extension Dictionary {
    subscript<T: RawRepresentable>(expression: T) -> Value? where T.RawValue == Key {
        get {
            return self[expression.rawValue]
        }
        set {
            self[expression.rawValue] = newValue
        }
    }
}
