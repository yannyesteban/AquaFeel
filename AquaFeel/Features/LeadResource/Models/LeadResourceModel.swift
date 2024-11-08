//
//  LeadResourceModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/10/24.
//

//
//  ResourceModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/5/24.
//

import Foundation


struct LeadResourceResponse: Codable, NeedStatusCode {
    let message: String?
    let resource: LeadResourceModel?
    var statusCode: Int?
}

struct LeadResourcesResponse: Codable, NeedStatusCode {
    let message: String?
    let count: Int
    let list: [LeadResourceModel]
    var statusCode: Int?
}

struct LeadResourceModel: Identifiable, Codable {
    var id: String
    var leadId: String
    var fileName: String
    var description: String
    var type: ResourceType
    var active: Bool
    var createdBy: String
    //var createdOn: Date
    //var updatedOn: Date
    
    var recordMode: RecordMode = .none
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case leadId = "lead_id"
        case fileName = "file_name"
        case description
        case type
        case active
        case createdBy = "created_by"
        //case createdOn = "created_on"
        //case updatedOn = "updated_on"
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
    
    init(
        id: String = "",
        leadId: String = "",
        fileName: String = "",
        description: String = "",
        type: ResourceType = .image,
        active: Bool = true,
        createdBy: String = ""/*,
        createdOn: Date = .init(),
        updatedOn: Date = .init()*/
    ) {
        self.id = id
        self.leadId = leadId
        self.fileName = fileName
        self.description = description
        self.type = type
        self.active = active
        self.createdBy = createdBy
        //self.createdOn = createdOn
        //self.updatedOn = updatedOn
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        leadId = try container.decode(String.self, forKey: .leadId)
        fileName = try container.decode(String.self, forKey: .fileName)
        description = try container.decode(String.self, forKey: .description)
        type = try container.decode(ResourceType.self, forKey: .type)
        active = try container.decode(Bool.self, forKey: .active)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        //let createdOnString = try container.decode(String.self, forKey: .createdOn)
        //let updatedOnString = try container.decode(String.self, forKey: .updatedOn)
        /*
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
         */
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(leadId, forKey: .leadId)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(description, forKey: .description)
        try container.encode(type, forKey: .type)
        try container.encode(active, forKey: .active)
        try container.encode(createdBy, forKey: .createdBy)
        /*
        let datetimeString = ResourceModel.dateFormatter.string(from: createdOn)
        try container.encode(datetimeString, forKey: .createdOn)
        
        let datetimeString2 = ResourceModel.dateFormatter.string(from: updatedOn)
        try container.encode(datetimeString2, forKey: .updatedOn)
         */
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
