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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        current = try? container.decode(String.self, forKey: .current)
        first = try? container.decode(String.self, forKey: .first)
        last = try? container.decode(String.self, forKey: .last)
        previous = try? container.decode(String.self, forKey: .previous)
        next = try? container.decode(String.self, forKey: .next)
    }
    
}
