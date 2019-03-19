//
//  Identifiable.swift
//  jab
//
//  Created by Dino on 19/03/2019.
//

import Foundation

public protocol JSONAPIIdentifiable {
    var identifier: String { get set }
    
    static var codingKey: String { get }
}

extension JSONAPIIdentifiable {
    static var codingKey: String {
        return "id"
    }
}
