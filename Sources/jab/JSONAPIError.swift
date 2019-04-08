//
//  JSONAPIError.swift
//  jab
//
//  Created by Dino on 05/04/2019.
//

import Foundation

public struct JSONAPIError: Decodable, Error {
    struct Source: Decodable {
        let pointer: String
    }
    
    let status: String?
    let source: Source?
    let title: String?
    let detail: String?
}

public struct JSONAPIErrors: Decodable, Error {
    let errors: [JSONAPIError]
}
