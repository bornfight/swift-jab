//
//  JSONAPIFlattener.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

/// Transforms deeply nested JSON:API objects into regular objects
/// with all of their relationships wired up. 
class JSONAPIFlattener {
    enum Error: Swift.Error {
        case hasNoAttributes(dictionary: NSDictionary)
        case missingDataAttribute(dictionary: NSDictionary)
    }
    
    func flattenCollection(jsonAPI: NSDictionary) throws -> [NSDictionary] {
        guard let dataObject = jsonAPI["data"] as? [NSDictionary] else {
            throw Error.missingDataAttribute(dictionary: jsonAPI)
        }
        
        let includedObjects = jsonAPI["included"] as? [NSDictionary]
        
        return try dataObject.map { try parse(single: $0, includedObjects: includedObjects) }
    }
    
    func flatten(jsonAPI: NSDictionary) throws -> NSDictionary {
        guard let dataObject = jsonAPI["data"] as? NSDictionary else {
            throw Error.missingDataAttribute(dictionary: jsonAPI)
        }
        
        let includedObjects = jsonAPI["included"] as? [NSDictionary]
        
        return try parse(single: dataObject, includedObjects: includedObjects)
    }
    
    private func parse(single jsonApiObject: NSDictionary, includedObjects: [NSDictionary]?) throws -> NSDictionary {
        guard let attributes = jsonApiObject["attributes"] as? NSDictionary else {
            throw Error.hasNoAttributes(dictionary: jsonApiObject)
        }
        
        guard let relationships = jsonApiObject["relationships"] as? NSDictionary,
              let includes = includedObjects
        else { return attributes }
        
        let JSON = NSMutableDictionary(dictionary: attributes)
        
        for relationshipKey in relationships.allKeys {
            guard let relationship = relationships[relationshipKey] as? NSDictionary else { continue }
            
            if let relationshipData = relationship["data"] as? [NSDictionary] {
                let includes = relationshipData.compactMap { data in fetchAttributes(of: data, in: includes) }
                
                JSON[relationshipKey] = includes
            } else if let relationshipData = relationship["data"] as? NSDictionary {
                guard let includedAttributes = fetchAttributes(of: relationshipData, in: includes) else {
                    continue
                }
                
                JSON[relationshipKey] = includedAttributes
            } else {
                continue
            }
        }
        
        return JSON
    }
    
    private func locateIncludedObject(id: String, type: String, in includes: [NSDictionary]) -> NSDictionary? {
        return includes.first(where: { $0["type"] as? String == type && $0["id"] as? String == id })
    }
    
    private func fetchAttributes(of dictionary: NSDictionary, in includedObjects: [NSDictionary]) -> NSDictionary? {
        guard let type = dictionary["type"] as? String,
              let id = dictionary["id"] as? String,
              let included = locateIncludedObject(id: id, type: type, in: includedObjects),
              let includedAttributes = included["attributes"] as? NSDictionary
        else { return nil }
        
        return includedAttributes
    }
}
