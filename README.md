# jab

A lightweight iOS library for transforming [JSON:API](https://jsonapi.org) responses into "usual" REST API responses.

# Usage

The principle class to use is `JSONAPIDeserializer`, which has a reference to a `JSONDecoder` handling the actual decoding of JSON responses.

For example:
```swift
let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .millisecondsSince1970
    return decoder
}()
let jsonApiDeserializer = JSONAPIDeserializer(decoder: jsonDecoder)
```

The deserializer expects an object conforming to `Codable` to be deserialized from the response.
If there was a `Car` object looking a little something like this
```
struct Car: Codable, Hashable {
    let mark: String
    let model: String
    let color: String
    let maxSpeed: Int
}
```

Then the JSON:API response the deserializer would expect to find would look a bit like
```json
{
    "jsonapi": {
        "version": "1.0"
    },
    "data": {
        "type": "cars",
        "id": "1",
        "attributes": {
            "mark": "Toyota",
            "model": "Yaris",
            "color": "Red",
            "max_speed": 250
        }
    }
}
```

It could then be decoded like so:
```swift
let rawJsonString = "..."
let jsonData = rawJsonString.data(using: .utf8)!
let car: Car = try! jsonApiDeserializer.deserialize(data: jsonData)
```
