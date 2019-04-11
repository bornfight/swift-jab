//
//  JSONAPISerializer.swift
//  jab
//
//  Created by Dino on 10/04/2019.
//

import Foundation

public class JSONAPISerializer {
    enum Error: Swift.Error {
        case missingLinksParameter(dictionary: Dictionary<String, Any>)
        case missingIdentifier(dictionary: Dictionary<String, Any>)
        case failedToTransformToUTF8(string: String)
        case notConvertibleToDictionary(data: Data)
        case failedToDecode(data: Data)
    }
    
    public typealias Resource = Codable & JSONAPIIdentifiable
    
    private let encoder: JSONEncoder
    
    public init(encoder: JSONEncoder = JSONEncoder()) {
        self.encoder = encoder
    }

    public func serialize<T: Resource>(resource: T) throws -> Data {
        var json = Dictionary<String, Any>()
        let resourceJSONData = try encoder.encode(resource)
        let resourceJSONOption = try JSONSerialization.jsonObject(with: resourceJSONData, options: .allowFragments) as? Dictionary<String, Any>
        var resourceJSON = try unwrap(resourceJSONOption, orThrow: Error.notConvertibleToDictionary(data: resourceJSONData))
        let id = try unwrap(resourceJSON[JSONAPIKeys.identifier], orThrow: Error.missingIdentifier(dictionary: resourceJSON))
        resourceJSON[JSONAPIKeys.identifier] = nil
        
        var relationships = Dictionary<String, Any>()
        
        reflectNamedProperties(of: resource) { (child: Resource, label) in
            let relation: [String: [String: Any]] = [
                JSONAPIKeys.data.rawValue: [
                    JSONAPIKeys.type.rawValue: type(of: child).jsonTypeIdentifier,
                    JSONAPIKeys.id.rawValue: child.identifier
                ]
            ]
            relationships[label] = relation
            resourceJSON[label] = nil
        }
        
        json[JSONAPIKeys.id] = id
        json[JSONAPIKeys.attributes] = resourceJSON
        json[JSONAPIKeys.type] = resource.identifier
        json[JSONAPIKeys.relationships] = relationships
        
        let rootJson: [String: Any] = [
            JSONAPIKeys.data.rawValue: json
        ]
        
        return try JSONSerialization.data(withJSONObject: rootJson, options: .prettyPrinted)
    }
    
//    public func serialize<T: Resource>(resource: T) -> Result<Data, Swift.Error> {
//        return Result(catching: { try serialize(resource: resource) })
//    }
//
//    public func deserializeCollection<T: Resource>(data: Data) throws -> Paginated<T> {
//        let jsonDataOption = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
//        let jsonData = try unwrap(jsonDataOption, orThrow: Error.notConvertibleToDictionary(data: data))
//        
//        let linksDict = try unwrap(jsonData[JSONAPIKeys.links] as? Dictionary<String, Any>, orThrow: Error.missingLinksParameter(dictionary: jsonData))
//        let linksData = try JSONSerialization.data(withJSONObject: linksDict, options: .prettyPrinted)
//        let links = try decoder.decode(Links.self, from: linksData)
//        
//        let resourcesDictionary = try flattener.flattenCollection(jsonAPI: jsonData)
//        let resourcesData = try JSONSerialization.data(withJSONObject: resourcesDictionary, options: .prettyPrinted)
//        
//        if let resources = try? decoder.decode([T].self, from: resourcesData) {
//            return Paginated(links: links, resources: resources)
//        } else if let jsonApiError = try? decoder.decode(JSONAPIErrors.self, from: resourcesData) {
//            throw jsonApiError
//        } else {
//            throw Error.failedToDecode(data: resourcesData)
//        }
//    }
//    
//    public func deserializeCollection<T: Resource>(data: Data) -> Result<Paginated<T>, Swift.Error> {
//        return Result(catching: { try deserializeCollection(data: data) })
//    }
    
    private func reflectNamedProperties<T>(
        of target: Any,
        matchingType type: T.Type = T.self,
        recursively: Bool = false,
        using closure: (T, String) -> Void
        )
    {
        let mirror = Mirror(reflecting: target)
        
        for child in mirror.children {
            if let value = child.value as? T, let label = child.label {
                closure(value, label)
            }
            
            if recursively {
                // To enable recursive reflection, all we have to do
                // is to call our own method again, using the value
                // of each child, and using the same closure.
                reflectNamedProperties(
                    of: child.value,
                    recursively: true,
                    using: closure
                )
            }
        }
    }
}
