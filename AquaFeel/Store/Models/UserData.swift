//
//  AppData.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation

enum SchemeMode:Int, Codable {
    case user = 0
    case light = 1
    case dark = 2
}

enum AppLanguage:Int, Codable {
    case user = 0
    case english = 1
    case spanish = 2
}

enum AppMapApi:Int, Codable {
    case googleMaps = 0
    case appleMaps = 1
    case openStreet = 2
}

struct UserData:  Codable, SimplyInitializable {
    
    var id: String
    var name: String
    var user: String
    var userId: String
    var pass: String
    var token: String
    var role : String
    
    var isBlocked: Bool
    var isVerified: Bool
    var auth: Bool
    var test:String = "yanny Nuñez TEST One"
    var info: User = User()
    
    var schemeMode = SchemeMode.user
    var language = AppLanguage.user
    var mapApi = AppMapApi.googleMaps
    var offline = false
    var playBackground = false
    var notifications = false
    var timeBefore = 60
    var useCalendar = false
    
    
    init() {
            // Llama al inicializador principal con un valor predeterminado
            self.init(name: "")
        }
    
    init(id: String = "", name: String = "", email: String = "", userId: String = "", password: String = "", token: String = "", role: String = "", isBlocked: Bool = true, isVerified: Bool = false, auth: Bool = false) {
        self.id = id
        self.name = name
        self.user = email
        self.userId = userId
        self.pass = password
        self.token = token
        self.role = role
        self.isBlocked = isBlocked
        
        self.isVerified = isVerified
        self.auth = auth
        
    }
    
    
}

struct Address: Identifiable, Codable {
    
    let id: UUID
    var appOrSuite: String
    var city: String
    var state: String
    var zip: String
    var country: String
    
    var longitude: String
    var latitude: String
    var streetAddress: String
    
    init(id: UUID = UUID(), appOrSuite: String = "", city: String = "", state: String = "", zip: String = "", country: String = "", longitude: String = "", latitude: String = "", streetAddress: String = "") {
        self.id = id
        self.appOrSuite = appOrSuite
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.longitude = longitude
        self.latitude = latitude
        self.streetAddress = streetAddress
    }
    
    
}

struct Lead: Identifiable, Codable {
    
    let id: UUID
    
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var phoneNumber2: String
    var email: String
    var addres: Address
    var appointmentDate: Date
    var appointmentTime: Date
    var status: Int
    
    var note: String
    
    
    init(id: UUID = UUID(), firstName: String = "", lastName: String = "", phoneNumber: String = "", phoneNumber2: String = "", email: String = "", addres: Address = Address(), appointmentDate: Date = Date(), appointmentTime: Date = Date(), status: Int = 0, note: String = "") {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.phoneNumber2 = phoneNumber2
        self.email = email
        self.addres = addres
        self.appointmentDate = appointmentDate
        self.appointmentTime = appointmentTime
        self.status = status
        self.note = note
    }
    
    
    
    
}
