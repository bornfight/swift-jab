//
//  Links.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

public struct Links: Codable {
    var current: String?
    var first: String?
    var last: String?
    var previous: String?
    var next: String?
    
    enum CodingKeys: String, CodingKey {
        case current = "self"
        case first
        case last
        case previous = "prev"
        case next
    }
}
