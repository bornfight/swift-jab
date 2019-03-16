//
//  Unwrap.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

func unwrap<T>(_ option: T?, orThrow error: Error) throws -> T {
    if let value = option {
        return value
    }
    
    throw error
}
