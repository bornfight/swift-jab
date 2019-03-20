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
        case hasNoAttributes(dictionary: Dictionary<String, Any>)
        case hasNoIdentifier(dictionary: Dictionary<String, Any>)
        case missingDataAttribute(dictionary: Dictionary<String, Any>)
    }
    
    func flattenCollection(jsonAPI: Dictionary<String, Any>) throws -> [Dictionary<String, Any>] {
        guard let dataObject = jsonAPI[JSONAPIKeys.data] as? [Dictionary<String, Any>] else {
            throw Error.missingDataAttribute(dictionary: jsonAPI)
        }
        
        let includedObjects = jsonAPI[JSONAPIKeys.included] as? [Dictionary<String, Any>]
        
        return try dataObject.map { try parse(single: $0, includedObjects: includedObjects) }
    }
    
    func flatten(jsonAPI: Dictionary<String, Any>) throws -> Dictionary<String, Any> {
        guard let dataObject = jsonAPI[JSONAPIKeys.data] as? Dictionary<String, Any> else {
            throw Error.missingDataAttribute(dictionary: jsonAPI)
        }
        
        let includedObjects = jsonAPI[JSONAPIKeys.included] as? [Dictionary<String, Any>]
        
        return try parse(single: dataObject, includedObjects: includedObjects)
    }
    
    private func parse(single jsonApiObject: Dictionary<String, Any>, includedObjects: [Dictionary<String, Any>]?, recursivelySearchRelationships: Bool = true) throws -> Dictionary<String, Any> {
        guard let attributes = jsonApiObject[JSONAPIKeys.attributes] as? Dictionary<String, Any> else {
            throw Error.hasNoAttributes(dictionary: jsonApiObject)
        }
        
        guard let identifier = jsonApiObject[JSONAPIKeys.id] as? String else {
            throw Error.hasNoIdentifier(dictionary: jsonApiObject)
        }
        
        var JSON = attributes
        JSON[JSONAPIKeys.identifier] = identifier
        
        guard let relationships = jsonApiObject[JSONAPIKeys.relationships] as? Dictionary<String, Any>,
              let includes = includedObjects,
              recursivelySearchRelationships
        else { return JSON }
        
        let relationshipData = parse(relationships: relationships, includes: includes)
        
        for relationKey in relationshipData.keys {
            JSON[relationKey] = relationshipData[relationKey]
        }
        
        return JSON
    }
    
    private func parse(relationships: Dictionary<String, Any>, includes: [Dictionary<String, Any>]) -> Dictionary<String, Any> {
        var JSON = Dictionary<String, Any>()
        
        for relationshipKey in relationships.keys {
            guard let relationship = relationships[relationshipKey] as? Dictionary<String, Any> else { continue }
            
            if let relationshipData = relationship[JSONAPIKeys.data] as? [Dictionary<String, Any>] {
                let allIncludedObjects = relationshipData.compactMap { data in fetchObjectAttributes(of: data, in: includes) }
                
                JSON[relationshipKey] = allIncludedObjects
            } else if let relationshipData = relationship[JSONAPIKeys.data] as? Dictionary<String, Any> {
                guard let includedAttributes = fetchObjectAttributes(of: relationshipData, in: includes) else {
                    continue
                }
                
                JSON[relationshipKey] = includedAttributes
            } else {
                continue
            }
        }
        
        return JSON
    }
    
    private func locateIncludedObject(id: String, type: String, in includes: [Dictionary<String, Any>]) -> Dictionary<String, Any>? {
        return includes.first(where: { $0[JSONAPIKeys.type] as? String == type && $0[JSONAPIKeys.id] as? String == id })
    }
    
    private func fetchObjectAttributes(of dictionary: Dictionary<String, Any>, in includedObjects: [Dictionary<String, Any>]) -> Dictionary<String, Any>? {
        guard let type = dictionary[JSONAPIKeys.type] as? String,
              let id = dictionary[JSONAPIKeys.id] as? String,
              let included = locateIncludedObject(id: id, type: type, in: includedObjects)
        else { return nil }
        
        return try? parse(single: included, includedObjects: includedObjects, recursivelySearchRelationships: false)
    }
}
