//
//  Links.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

public struct Links: Codable {
    let current: String
    let first: String?
    let last: String?
    let previous: String?
    let next: String?
    
    enum CodingKeys: String, CodingKey {
        case current = "self"
        case first
        case last
        case previous = "prev"
        case next
    }
}
