//
//  JSONAPIError.swift
//  jab
//
//  Created by Dino on 05/04/2019.
//

import Foundation

struct JSONAPIError: Decodable {
    struct Source: Decodable {
        let pointer: String
    }
    
    let status: String?
    let source: Source?
    let title: String?
    let detail: String?
}
