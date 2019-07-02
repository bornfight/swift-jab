//
//  Paginated.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

public class Paginated<Resource: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case links
        case resources = "data"
    }
    
    public var links: Links
    public var resources: [Resource]
    
    public init(links: Links, resources: [Resource]) {
        self.links = links
        self.resources = resources
    }
}
