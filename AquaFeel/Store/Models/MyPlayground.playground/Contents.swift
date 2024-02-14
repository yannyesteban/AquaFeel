import UIKit

import Foundation

//import Foundation

struct YourModel: Codable {
    var id: String
    
    // Si hay otras propiedades en tu JSON, agrégales aquí
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        // Agrega otras claves si es necesario
    }
}

// Ejemplo de parsing de JSON
let jsonString = #"{"_id": "4444"}"#
let jsonData = jsonString.data(using: .utf8)!

do {
    let decodedModel = try JSONDecoder().decode(YourModel.self, from: jsonData)
    print("Parsed Model:", decodedModel)
    print("ID:", decodedModel.id )
} catch {
    print("Error decoding JSON:", error)
}

let lead  = LeadViewModel()

lead.loadAll()
        
struct foo<T> {
    init(_: T) { }
}

func bar<T>(_: T) { }

foo<Set>([2])
bar([2])

let f = ["yanny", "esteban"]

print(f.Type)


class UserData: Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case name
        
    }
    
    @Published var name: String = "pepe"
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    
}

var greeting = "Hello, playground"


var json = """
 {

"name":"Yanny 2025"
}

"""

print(greeting)

print(json)



let userData = try JSONDecoder().decode(UserData.self, from: Data(json.utf8))

print(userData.name)



