//
//  JSONAPIDeserializer.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

public class JSONAPIDeserializer {
    enum Error: Swift.Error {
        case missingLinksParameter(dictionary: Dictionary<String, Any>)
        case failedToTransformToUTF8(string: String)
        case notConvertibleToDictionary(data: Data)
    }
    
    public typealias Resource = Codable & JSONAPIIdentifiable
    
    public static let `default` = JSONAPIDeserializer()
    
    private let decoder: JSONDecoder
    private let flattener: JSONAPIFlattener
    public var flatteningStrategy: JSONAPIFlatteningStrategy {
        get {
            return flattener.strategy
        }
        set {
            flattener.strategy = newValue
        }
    }
    
    init(decoder: JSONDecoder = JSONDecoder(), jsonApiDecoder: JSONAPIFlattener = JSONAPIFlattener()) {
        self.decoder = decoder
        self.flattener = jsonApiDecoder
    }
    
    public func deserialize<T: Resource>(data: Data) throws -> T {
        let jsonDataOption = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
        let jsonData = try unwrap(jsonDataOption, orThrow: Error.notConvertibleToDictionary(data: data))

        let resourceDictionary = try flattener.flatten(jsonAPI: jsonData)
        let resourceData = try JSONSerialization.data(withJSONObject: resourceDictionary, options: .prettyPrinted)
        
        return try decoder.decode(T.self, from: resourceData)
    }
    
    public func deserialize<T: Resource>(data: Data) -> Result<T, Swift.Error> {
        return Result(catching: { try deserialize(data: data) })
    }
    
    public func deserializeCollection<T: Resource>(data: Data) throws -> Paginated<T> {
        let jsonDataOption = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
        let jsonData = try unwrap(jsonDataOption, orThrow: Error.notConvertibleToDictionary(data: data))
        
        let linksDict = try unwrap(jsonData[JSONAPIKeys.links] as? Dictionary<String, Any>, orThrow: Error.missingLinksParameter(dictionary: jsonData))
        let linksData = try JSONSerialization.data(withJSONObject: linksDict, options: .prettyPrinted)
        let links = try decoder.decode(Links.self, from: linksData)
        
        let resourcesDictionary = try flattener.flattenCollection(jsonAPI: jsonData)
        let resourcesData = try JSONSerialization.data(withJSONObject: resourcesDictionary, options: .prettyPrinted)
        let resources = try decoder.decode([T].self, from: resourcesData)
        
        return Paginated(links: links, resources: resources)
    }
    
    public func deserializeCollection<T: Resource>(data: Data) -> Result<Paginated<T>, Swift.Error> {
        return Result(catching: { try deserializeCollection(data: data) })
    }
}
