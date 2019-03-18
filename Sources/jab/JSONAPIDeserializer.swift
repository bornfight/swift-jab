//
//  JSONAPIDeserializer.swift
//  jab
//
//  Created by Dino on 16/03/2019.
//

import Foundation

public class JSONAPIDeserializer {
    enum Error: Swift.Error {
        case missingLinksParameter(dictionary: NSDictionary)
        case failedToTransformToUTF8(string: String)
        case notConvertibleToDictionary(data: Data)
    }
    
    public static let `default` = JSONAPIDeserializer()
    
    private let decoder: JSONDecoder
    private let flattener: JSONAPIFlattener
    
    init(decoder: JSONDecoder = JSONDecoder(), jsonApiDecoder: JSONAPIFlattener = JSONAPIFlattener()) {
        self.decoder = decoder
        self.flattener = jsonApiDecoder
    }
    
    public func deserialize<Resource: Codable>(data: Data) throws -> Resource {
        let jsonDataOption = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        let jsonData = try unwrap(jsonDataOption, orThrow: Error.notConvertibleToDictionary(data: data))

        let resourceDictionary = try flattener.flatten(jsonAPI: jsonData)
        let resourceData = try JSONSerialization.data(withJSONObject: resourceDictionary, options: .prettyPrinted)
        
        return try decoder.decode(Resource.self, from: resourceData)
    }
    
    public func deserializeCollection<Resource: Codable>(data: Data) throws -> Paginated<Resource> {
        let jsonDataOption = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
        let jsonData = try unwrap(jsonDataOption, orThrow: Error.notConvertibleToDictionary(data: data))
        
        let linksDict = try unwrap(jsonData["links"] as? NSDictionary, orThrow: Error.missingLinksParameter(dictionary: jsonData))
        let linksData = try JSONSerialization.data(withJSONObject: linksDict, options: .prettyPrinted)
        let links = try decoder.decode(Links.self, from: linksData)
        
        let resourcesDictionary = try flattener.flattenCollection(jsonAPI: jsonData)
        let resourcesData = try JSONSerialization.data(withJSONObject: resourcesDictionary, options: .prettyPrinted)
        let resources = try decoder.decode([Resource].self, from: resourcesData)
        
        return Paginated(links: links, resources: resources)
    }
}
