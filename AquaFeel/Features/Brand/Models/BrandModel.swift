//
//  BrandModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import Foundation

struct BrandModel: Codable {
    var _id: String
    var name: String

    enum CodingKeys: String, CodingKey {
        case _id
        case name
    }

    init(
        _id: String = "",
        name: String = "") {
            self._id = name
            self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(_id, forKey: ._id)
        try container.encode(name, forKey: .name)
    }
}
