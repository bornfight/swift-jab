//
//  ResponseAdapter.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

public protocol ResponseAdapterType {
    func adapt(response: HTTPURLResponse, data: Data) throws -> Data
}

open class ResponseAdapter: ResponseAdapterType {
    enum Error: Swift.Error {
        case unsuccessfulStatusCode(response: HTTPURLResponse)
    }
    
    public let successfulStatusCodes = (200..<300)
    
    open func adapt(response: HTTPURLResponse, data: Data) throws -> Data {
        guard successfulStatusCodes.contains(response.statusCode) else {
            throw Error.unsuccessfulStatusCode(response: response)
        }
        
        return data
    }
    
    open func adapt(_ tuple: (response: HTTPURLResponse, data: Data)) throws -> Data {
        return try adapt(response: tuple.response, data: tuple.data)
    }
}
