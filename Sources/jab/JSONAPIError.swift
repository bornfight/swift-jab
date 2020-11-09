//
//  JSONAPIError.swift
//  jab
//
//  Created by Dino on 05/04/2019.
//

import Foundation

public struct JSONAPIError: Decodable, Error {
    public struct Source: Decodable {
        public let pointer: String
    }
    
    public let status: String?
    public let source: Source?
    public let title: String?
    public let detail: String?
    public let code: String?
}

public struct JSONAPIErrors: Decodable, Error {
    public let errors: [JSONAPIError]
}
