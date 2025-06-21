//
//  Manager.swift
//  AquafeelExtension
//
//  Created by Yanny Esteban on 11/6/24.
//

import Foundation

struct UserData:  Codable {
    
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
    //var info: User = User()
    
    //var schemeMode = SchemeMode.user
    //var language = AppLanguage.user
    //var mapApi = AppMapApi.googleMaps
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

func fileURL(name: String) throws -> URL {
    try FileManager.default.url(for: .documentDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: false)
    .appendingPathComponent(name)
}

func loadFile<T: Codable>(name: String) async throws -> T {
    
    if let userDefaults = UserDefaults(suiteName: "group.aquafeelvirginia.com.AquaFeel") {
        let value = userDefaults.string(forKey: "userId")
        
    }
    
    
    
    let fileURL = try fileURL(name: name)
    
    do {
        let data1 = try Data(contentsOf: fileURL)
    } catch {
        print(error)
    }
    
   
    guard let data = try? Data(contentsOf: fileURL) else {
        
        throw APIError.urlError // YourErrorType.fileReadError // Reemplaza YourErrorType con el tipo de error que desees
    }
    
    do {
        let userData = try JSONDecoder().decode(T.self, from: data)
        return userData
    } catch {
        throw error // YourErrorType.jsonDecodingError // Reemplaza YourErrorType con el tipo de error que desees
    }
}

func realDate(text: String) -> Date {
    
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    if let date = isoDateFormatter.date(from: text) {
        return date
    } else {
        return Date()
    }
    
    
    /*
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
     //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
     
     if let date = dateFormatter.date(from: text) {
     return date
     } else {
     // If the conversion fails, returns the current date as the default value
     return Date()
     }
     */
}

struct StatusId: Codable {
    var isDisabled: Bool?
    var _id: String
    var name: String
    var image: String
    // var __v: Int?
    
    enum CodingKeys: String, CodingKey {
        case _id
        case isDisabled
        case name
        case image
    }
    
    init(isDisabled: Bool? = false, _id: String = "", name: String = "", image: String = "") {
        self.isDisabled = isDisabled
        self._id = _id
        self.name = name
        self.image = image
        // self.__v = __v
    }
    /*
     init(from decoder: Decoder) throws {
     let container = try decoder.container(keyedBy: CodingKeys.self)
     
     _id = try container.decode(String.self, forKey: ._id)
     isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled) ?? false
     name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
     image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
     
     }
     */
}

struct CreatorModel: Codable, Identifiable {
    var id: String { _id }
    var _id: String = ""
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
}

struct LeadModel: Codable,  Equatable, Hashable {
    var id: String
    var business_name: String
    var first_name: String
    var last_name: String
    var phone: String
    var phone2: String
    var email: String
    var street_address: String
    var apt: String
    var city: String
    var state: String
    var zip: String
    var country: String
    var longitude: String
    var latitude: String
    var appointment_date: String
    var appointment_time: String
    var status_id: StatusId
    var created_by: CreatorModel
    var note: String
    var owned_by: String? = ""
    var user_id: String = ""
    
    var isSelected: Bool
    var mode: Int = 2
    
    var routeOrder: Int
    var createdOn: Date
    var updatedOn: Date
    
    var history : [LeadModel] = []
    var pending = false
    var favorite: Bool = true
    
    
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case business_name
        case first_name
        case last_name
        case phone
        case phone2
        case email
        case street_address
        case apt
        case city
        case state
        case zip
        case country
        case longitude
        case latitude
        case appointment_date
        case appointment_time
        case status_id
        case note
        /*
         case owned_by
         case created_on
         case updated_on*/
        // case user_id = "created_by"
        case _id = "id"
        // case created_by = "user_id"
        case created_by
        case user_id
        case isSelected
        case owned_by
        case createOn = "created_on"
        case updatedOn = "updated_on"
        case history
        case favorite
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Utiliza una propiedad única como base para generar el hash
    }
    
    static func == (lhs: LeadModel, rhs: LeadModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.business_name == rhs.business_name &&
        lhs.first_name == rhs.first_name &&
        lhs.last_name == rhs.last_name &&
        lhs.phone == rhs.phone &&
        lhs.phone2 == rhs.phone2 &&
        lhs.email == rhs.email &&
        lhs.street_address == rhs.street_address &&
        lhs.apt == rhs.apt &&
        lhs.city == rhs.city &&
        lhs.state == rhs.state &&
        lhs.zip == rhs.zip &&
        lhs.country == rhs.country &&
        lhs.longitude == rhs.longitude &&
        lhs.latitude == rhs.latitude &&
        lhs.appointment_date == rhs.appointment_date &&
        lhs.appointment_time == rhs.appointment_time &&
        lhs.status_id._id == rhs.status_id._id &&
        lhs.created_by._id == rhs.created_by._id &&
        lhs.note == rhs.note &&
        lhs.owned_by == rhs.owned_by &&
        lhs.user_id == rhs.user_id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        business_name = try container.decodeIfPresent(String.self, forKey: .business_name) ?? ""
        first_name = try container.decodeIfPresent(String.self, forKey: .first_name) ?? ""
        last_name = try container.decodeIfPresent(String.self, forKey: .last_name) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        phone2 = try container.decodeIfPresent(String.self, forKey: .phone2) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        street_address = try container.decodeIfPresent(String.self, forKey: .street_address) ?? ""
        apt = try container.decodeIfPresent(String.self, forKey: .apt) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        zip = try container.decodeIfPresent(String.self, forKey: .zip) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        
        // Other properties (adapt decoding logic as needed):
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude) ?? ""
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude) ?? ""
        
        appointment_date = try container.decodeIfPresent(String.self, forKey: .appointment_date) ?? ""
        appointment_time = try container.decodeIfPresent(String.self, forKey: .appointment_time) ?? ""
        let date = try container.decodeIfPresent(String.self, forKey: .createOn) ?? ""
        createdOn = realDate(text: date)
        
        let date2 = try container.decodeIfPresent(String.self, forKey: .updatedOn) ?? ""
        favorite = try container.decodeIfPresent(Bool.self, forKey: .favorite) ?? false
        updatedOn = realDate(text: date2)
        
        
        if container.contains(.status_id) {
            do {
                // Try to decode status_id as an object
                status_id = try container.decode(StatusId.self, forKey: .status_id)
            } catch {
                // If it fails, try to decode status_id as a string and create an instance of StatusId
                if let statusIdString = try? container.decode(String.self, forKey: .status_id) {
                    status_id = StatusId(_id: statusIdString)
                } else {
                    // If both options fail, rethrow the original error
                    throw error
                }
            }
        } else {
            status_id = StatusId(_id: "")
        }
        do {
            created_by = try container.decode(CreatorModel.self, forKey: .created_by)
        } catch {
            if let createdByString = try? container.decode(String.self, forKey: .created_by) {
                created_by = CreatorModel(_id: createdByString)
            } else {
                created_by = CreatorModel(_id: "")
                // throw error
            }
        }
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        owned_by = try container.decodeIfPresent(String.self, forKey: .owned_by) ?? ""
        user_id = try container.decodeIfPresent(String.self, forKey: .user_id) ?? ""
        
        // status_id = try container.decode(StatusId.self, forKey: .status_id)
        
        // created_by = try container.decode(CreatorModel.self, forKey: .created_by)
        
        /*
         owned_by = try container.decode(String.self, forKey: .owned_by)
         created_on = try container.decode(String.self, forKey: .created_on)
         updated_on = try container.decode(String.self, forKey: .updated_on)*/
        isSelected = true
        user_id = created_by._id
        routeOrder = 0
        
        history = try container.decodeIfPresent([LeadModel].self, forKey: .history) ?? []
        /*
         
         if !(-90 ... 90).contains(position.latitude) {
         position = .init(latitude: 0.0, longitude: 0.0)
         }
         
         if !(-180 ... 180).contains(position.longitude) {
         position = .init(latitude: 0.0, longitude: 0.0)
         }
         */
    }
    
    init(from json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw NSError(domain: "LeadModel", code: 1, userInfo: ["message": "Error"])
        }
        do {
            let decoder = JSONDecoder()
            
            let decodedLead = try decoder.decode(LeadModel.self, from: data)
            
            self = decodedLead
        } catch {
            print(error)
            throw error
        }
    }
    
    init(
        id: String = "",
        business_name: String = "",
        first_name: String = "",
        last_name: String = "",
        phone: String = "",
        phone2: String = "",
        email: String = "",
        street_address: String = "",
        apt: String = "",
        city: String = "",
        state: String = "",
        zip: String = "",
        country: String = "",
        longitude: String = "",
        latitude: String = "",
        appointment_date: String = "",
        appointment_time: String = "",
        status_id: StatusId = StatusId(),
        note: String = "",
        /*
         owned_by: String = "",
         
         updated_on: String = "",*/
        created_by: CreatorModel = CreatorModel(_id: ""),
        user_id: String = "",
        // isSelected = true
        mode: Int = 2,
        createdOn: Date = Date(),
        updatedOn: Date = Date()
    ) {
        self.id = id
        self.business_name = business_name
        self.first_name = first_name
        self.last_name = last_name
        self.phone = phone
        self.phone2 = phone2
        self.email = email
        self.street_address = street_address
        self.apt = apt
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.longitude = longitude
        self.latitude = latitude
        self.appointment_date = appointment_date
        self.appointment_time = appointment_time
        self.status_id = status_id
        self.note = note
        /*
         self.owned_by = owned_by
         self.created_on = created_on
         self.updated_on = updated_on*/
        self.created_by = created_by
        isSelected = true
        self.mode = mode
        routeOrder = 0
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: ._id)
        try container.encode(business_name, forKey: .business_name)
        try container.encode(first_name, forKey: .first_name)
        try container.encode(last_name, forKey: .last_name)
        try container.encode(phone, forKey: .phone)
        try container.encode(phone2, forKey: .phone2)
        try container.encode(email, forKey: .email)
        try container.encode(street_address, forKey: .street_address)
        try container.encode(apt, forKey: .apt)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zip, forKey: .zip)
        try container.encode(country, forKey: .country)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(latitude, forKey: .latitude)
        
        if !appointment_date.isEmpty {
            try container.encode(appointment_date, forKey: .appointment_date)
        }
        
        try container.encode(appointment_time, forKey: .appointment_time)
        try container.encode(status_id._id, forKey: .status_id)
        try container.encode(note, forKey: .note)
        try container.encode(created_by._id, forKey: .user_id)
        try container.encode(favorite, forKey: .favorite)
        // try container.encode(user_id, forKey: .user_id)
    }
    
    
    
    
    
    
    
    
    
    func validForm() -> String {
        if first_name.isEmpty {
            return "First Name is required!"
        }
        
        if !email.isEmpty {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailTest.evaluate(with: email) {
                return "invalid Email format!"
            }
        }
        
        if status_id._id.isEmpty {
            return "Status field is required!"
        }
        
        
        
        if street_address.isEmpty {
            return "Address is required!"
        }
        
        if longitude.isEmpty || latitude.isEmpty {
            return "Address is invalid!"
        }
        
        return ""
    }
    
    static func groupLeadsByDate(leads: [LeadModel]) -> [String: [LeadModel]] {
        var groupedLeads = [String: [LeadModel]]()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        for lead in leads {
            if let date = isoDateFormatter.date(from: lead.appointment_date) {
                let dateString = dateFormatter.string(from: date)
                if var leadsForDate = groupedLeads[dateString] {
                    leadsForDate.append(lead)
                    groupedLeads[dateString] = leadsForDate
                } else {
                    groupedLeads[dateString] = [lead]
                }
            }
        }
        
        return groupedLeads
    }
}


func formattedTime(from text: String) -> String {
    let isoDateFormatter = ISO8601DateFormatter()
    isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    if let date = isoDateFormatter.date(from: text) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    } else {
        return "-"
    }
}

struct LeadsRequest: Codable {
    let leads: [LeadModel]
    let count: Int?
}

func formatDateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func formatDateToString2(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Para asegurar que el formato sea en inglés (USA) y no afecte a las conversiones
    return dateFormatter.string(from: date)
}

func getFromDate() -> Date {
    let currentDate = Date()
    
    // Crear un calendario gregoriano
    let calendar = Calendar.current
    
    // Obtener los componentes de la fecha actual
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
    
    // Establecer la hora a las 12:00
    dateComponents.hour = 0
    dateComponents.minute = 0
    dateComponents.second = 0
    
    // Crear la fecha de inicio con la hora establecida a las 12:00
    guard let fromDate = calendar.date(from: dateComponents) else {
        fatalError("No se pudo crear la fecha de inicio")
    }
    
    return fromDate
}

func getToDate() -> Date {
    let currentDate = Date()
    
    let calendar = Calendar(identifier: .gregorian)
    
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
    
    dateComponents.hour = 23
    dateComponents.minute = 59
    dateComponents.second = 59
    
    guard let toDate = calendar.date(from: dateComponents) else {
        fatalError("No se pudo crear la fecha de inicio")
    }
    
    return toDate
}



class WidgetManager: ObservableObject {
    @Published var leads: [LeadModel] = []
    //@Published var filterMode: LeadModeFilter = .all
    @Published var userId = ""
    @Published var token = ""
    @Published var role = ""
    @Published var showLeads: Bool = false
    
    @Published var store: UserData = .init()
    func load() async {
        do {
            store = try await loadFile(name: "LoginStore1.data")
            
            DispatchQueue.main.async {
                self.token = self.store.token
                self.role = self.store.role
                
                self.userId = self.store.userId
                
              
            }
            
        } catch {
            print(error)
        }
    }
    
    func list() async throws {
        
        
        let q = LeadQuery()
            .add(.userId, userId)
            .add(.field, showLeads ? "created_on" : "appointment_date")
            .add(.offset, "0")
            .add(.limit, "1000")
        // .add(.quickDate, "custom")
        
        
        _ = q.add(.quickDate, "custom")
        
            .add(.fromDate, formatDateToString2(getFromDate()))
            .add(.toDate, formatDateToString2(getToDate()))
        
        
        let path = "/leads/get2"
        
        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: path, token: "", params: q.get())
        
        do {
            let response: LeadsRequest = try await fetching(config: info)
            
            DispatchQueue.main.async {
                self.leads = response.leads
                
               
            }
            
        } catch {
            throw error
        }
    }
    
}
