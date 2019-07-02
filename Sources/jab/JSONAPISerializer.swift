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
                    JSONAPIKeys.id.rawValue: child.id
                ]
            ]
            relationships[label] = relation
            resourceJSON[label] = nil
        }
        
        json[JSONAPIKeys.id] = id
        json[JSONAPIKeys.attributes] = resourceJSON
        json[JSONAPIKeys.type] = resource.id
        json[JSONAPIKeys.relationships] = relationships
        
        let rootJson: [String: Any] = [
            JSONAPIKeys.data.rawValue: json
        ]
        
        return try JSONSerialization.data(withJSONObject: rootJson, options: .prettyPrinted)
    }
    
    public func serialize<T: Resource>(resource: T) -> Result<Data, Swift.Error> {
        return Result(catching: { try serialize(resource: resource) })
    }
    
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
                reflectNamedProperties(
                    of: child.value,
                    recursively: true,
                    using: closure
                )
            }
        }
    }
}
