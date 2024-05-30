//
//  ResourceModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/5/24.
//

import Foundation


enum ResourceType: String, Codable, CaseIterable, Identifiable {
    case pdf = "pdf"
    case image = "image"
    case document = "document"
    case text = "text"

    var id: String { rawValue }
    
    init(from rawValue: String) {
        switch rawValue.uppercased() {
        case "pdf":
            self = .pdf
        case "image":
            self = .image
        case "document":
            self = .document
        default:
            self = .text
        }
    }
  
    var description: String {
        switch self {
        case .pdf:
            return "pdf"
        case .image:
            return "image"
        case .document:
            return "document"
        case .text:
            return "text"
        }
    }
    
    var iconName: String {
        switch self {
        case .pdf:
            return "doc.richtext"
        case .image:
            return "photo"
        case .document:
            return "doc.text"
        case .text:
            return "text.alignleft"
        }
    }

     
}

struct ResourceResponse: Codable, NeedStatusCode {
    let message: String?
    let resource: ResourceModel?
    var statusCode: Int?
}

struct ResourcesResponse: Codable, NeedStatusCode {
    let message: String?
    let count: Int
    let list: [ResourceModel]
    var statusCode: Int?
}

struct ResourceModel: Identifiable, Codable {
    var id: String
    var fileName: String
    var description: String
    var type: ResourceType
    var active: Bool
    var createdBy: String
    var createdOn: Date
    var updatedOn: Date
    
    var recordMode: RecordMode = .none

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fileName = "file_name"
        case description
        case type
        case active
        case createdBy = "created_by"
        case createdOn = "created_on"
        case updatedOn = "updated_on"
    }
    
    var fileURL: String {
        
        return "\(APIValues.scheme)://\(APIValues.host):\(APIValues.port)/uploads/\(fileName)"
        
        
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    init(id: String = "", fileName: String = "", description: String = "", type: ResourceType = .pdf, active: Bool = false, createdBy: String = "", createdOn: Date = .now, updatedOn: Date = .now) {
        self.id = id
        self.fileName = fileName
        self.description = description
        self.type = type
        self.active = active
        self.createdBy = createdBy
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(ResourceType.self, forKey: .type)
        active = try container.decode(Bool.self, forKey: .active)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        let createdOnString = try container.decode(String.self, forKey: .createdOn)
        let updatedOnString = try container.decode(String.self, forKey: .updatedOn)

        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let createdOnDate = isoDateFormatter.date(from: createdOnString) {
            createdOn = createdOnDate
        } else {
            createdOn = Date()
        }

        if let updatedOnDate = isoDateFormatter.date(from: updatedOnString) {
            updatedOn = updatedOnDate
        } else {
            updatedOn = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(description, forKey: .description)
        try container.encode(type, forKey: .type)
        try container.encode(active, forKey: .active)
        try container.encode(createdBy, forKey: .createdBy)

        let datetimeString = ResourceModel.dateFormatter.string(from: createdOn)
        try container.encode(datetimeString, forKey: .createdOn)

        let datetimeString2 = ResourceModel.dateFormatter.string(from: updatedOn)
        try container.encode(datetimeString2, forKey: .updatedOn)
    }
    
    func validForm() -> String {
        if description.isEmpty {
            return "Description is required!"
        }
        
        if fileName.isEmpty {
            return "File is required!"
        }
        
        
        return ""
    }
}
