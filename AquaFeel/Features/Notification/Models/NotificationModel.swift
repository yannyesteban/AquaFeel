//
//  NotificationModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 21/5/24.
//

import Foundation

enum NotificationType: String, Codable, CaseIterable, Identifiable {
    case appointment = "APPOINTMENT"
    case interval = "INTERVAL"
    case datetime = "DATETIME"
    case time = "TIME"

    var id: String { rawValue }

    init(from rawValue: String) {
        switch rawValue.uppercased() {
        case "APPOINTMENT":
            self = .appointment
        case "INTERVAL":
            self = .interval
        case "DATETIME":
            self = .datetime
        case "TIME":
            self = .time
        default:
            self = .time
        }
    }
}

enum TimeUnit: String, Codable, CaseIterable, Identifiable {
    case days = "DAYS"
    case hours = "HOURS"
    case minutes = "MINUTES"
    case seconds = "SECONDS"

    var id: String { rawValue }

    init(from rawValue: String) {
        switch rawValue.uppercased() {
        case "DAYS":
            self = .days
        case "HOURS":
            self = .hours
        case "MINUTES":
            self = .minutes
        case "SECONDS":
            self = .seconds
        default:
            self = .days
        }
    }
}

struct NotificationModel: Identifiable, Codable {
    var id: String
    var name: String
    var interval: Int
    var unit: TimeUnit
    var type: NotificationType
    var message: String
    var updatedOn: String
    var createdOn: String
    var createdBy: String
    var repeats: Bool
    var isActive: Bool
    var datetime: Date

    var recordMode: RecordMode = .none

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case interval
        case unit
        case type
        case message

        case createdOn = "created_on"
        case updatedOn = "updated_on"
        case createdBy = "created_by"
        case repeats

        case isActive = "is_active"
        case datetime
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
        name: String = "",
        interval: Int = 0,
        unit: TimeUnit = .days,
        type: NotificationType = .time,
        message: String = "",
        updatedOn: String = "",
        createdOn: String = "",
        createdBy: String = "",
        repeats: Bool = false,
        isActive: Bool = false,
        datetime: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.interval = interval
        self.unit = unit
        self.type = type
        self.message = message
        self.updatedOn = updatedOn
        self.createdOn = createdOn
        self.createdBy = createdBy
        self.repeats = repeats
        self.isActive = isActive
        self.datetime = datetime
        recordMode = .new
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        interval = try container.decode(Int.self, forKey: .interval)
        unit = TimeUnit(from: try container.decode(String.self, forKey: .unit))
        type = NotificationType(from: try container.decode(String.self, forKey: .type))
        message = try container.decode(String.self, forKey: .message)
        updatedOn = try container.decode(String.self, forKey: .updatedOn)
        createdOn = try container.decode(String.self, forKey: .createdOn)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        // createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        repeats = try container.decodeIfPresent(Bool.self, forKey: .repeats) ?? false
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false

        let text = try container.decodeIfPresent(String.self, forKey: .datetime) ?? ""

        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoDateFormatter.date(from: text) {
            datetime = date
        } else {
         
            datetime = Date()
        }

        recordMode = .edit
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(interval, forKey: .interval)
        try container.encode(unit, forKey: .unit)
        try container.encode(type, forKey: .type)
        try container.encode(message, forKey: .message)
        try container.encode(updatedOn, forKey: .updatedOn)
        try container.encode(createdOn, forKey: .createdOn)
        try container.encodeIfPresent(createdBy, forKey: .createdBy)
        try container.encodeIfPresent(repeats, forKey: .repeats)
        try container.encodeIfPresent(isActive, forKey: .isActive)

        let datetimeString = NotificationModel.dateFormatter.string(from: datetime)
        try container.encode(datetimeString, forKey: .datetime)
    }

    func validForm() -> String {
        if name.isEmpty {
            return "Name is required!"
        }

        if type == .interval && interval <= 0 {
            return "Interval is required!"
        }

        if message.isEmpty {
            return "Messagee field is required!"
        }

        return ""
    }
}

// Modelo para el contenedor de notificaciones
struct NotificationsResponse: Codable, NeedStatusCode {
    var statusCode: Int?

    let count: Int
    let list: [NotificationModel]
}

struct NotificationResponse: Codable, NeedStatusCode {
    var statusCode: Int?

    let notification: NotificationModel
}
