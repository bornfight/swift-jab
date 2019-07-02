//
//  Identifiable.swift
//  jab
//
//  Created by Dino on 19/03/2019.
//

import Foundation

public protocol JSONAPIIdentifiable {
    var id: String { get }
    
    static var jsonTypeIdentifier: String { get }
}
