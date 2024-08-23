//
//  ModelModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import Foundation

struct ModelModel: Codable {
    var _id: String
    var name: String
    var brand: BrandModel
    
    enum CodingKeys: String, CodingKey {
        case _id
        case brand
        case name
    }
    
    init(
        _id: String = "",
        brand: BrandModel = .init(),
        name: String = "") {
            
            self._id = _id
            self.brand = brand
            self.name = name
        }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        brand = try container.decodeIfPresent(BrandModel.self, forKey: .brand) ?? BrandModel()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_id, forKey: ._id)
        try container.encode(brand, forKey: .brand)
        try container.encode(name, forKey: .name)
    }
}
