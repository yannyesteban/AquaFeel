//
//  LeadModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 27/1/24.
//

import Foundation

struct LeadsRequest: Codable {
    let leads: [LeadModel]
    let count: Int?
}

struct LeadFilterss: Codable {
    var selectedStatuses: [StatusId]
    var dateFilters: DateFilters
    var selectedOwner: [String]
}

struct LeadDetailRequest: Codable {
    let lead: LeadModel
}

struct LeadFilter2 {
    var textFilter = ""
    var status: [String] = []
    var fromDate = Date()
    var toDate = Date()
    var dateField = DateFind.appointmentDate
    var quickDate = TimeOption.allTime // yesterday, current_week current_month current_year custom
    var owner: [String] = []
}

enum DateFind: String, CaseIterable {
    case createOn = "created_on"
    case updatedOn = "updated_on"
    case appointmentDate = "appointment_date"
}

enum SFIcons: String, CaseIterable {
    case star
    case heart
    case sun = "sun.max"
    case moon
    // Add more symbols as needed
}

enum SortOption: String, CaseIterable {
    case dateCreated = "Date Created"
    case lastUpdated = "Last Updated"
    case appointmentDate = "Appointment Date"
}

enum TimeOption: String, CaseIterable {
    case allTime = "all_time"
    case custom
    case today
    case yesterday
    case currentWeek = "current_week"
    case currentMonth = "current_month"
    case currentYear = "current_year"
}

enum LeadAllQuery: String, CaseIterable {
    case field
    case fromDate
    case toDate
    case statusId = "status_id"
    case limit
    case offset
    case searchKey = "search_key"
    case searchValue = "search_value"
    case quickDate
    case id
    case userId = "user_id"
    case today
    case lastMonth = "last_month"
    case ownerId = "owner_id"
}

enum ModeSave: String {
    case delete
    case add
    case edit
}

struct LeadsModel: Codable {
    let leads: [LeadModel]
}

struct StatusModel: Codable {
    let list: [StatusId]
}

protocol AddressProtocol {
    // var first_name: String { get set }
    var street_address: String { get set }
    // var street: String { get set }
    var apt: String { get set }
    var city: String { get set }
    var state: String { get set }
    var zip: String { get set }
    var country: String { get set }
    var latitude: String { get set }
    var longitude: String { get set }
    
    
}

struct AddressModel2: AddressProtocol {
    
    var street_address: String
    var apt: String
    var city: String
    var state: String
    var zip: String
    var country: String
    var latitude: String
    var longitude: String
    var name: String =  "yanny"
    
    
    init(street_address: String = "", apt: String = "", city: String = "", state: String = "", zip: String = "", country: String = "", latitude: String = "", longitude: String = "") {
        self.street_address = street_address
        self.apt = apt
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct AddressModel: AddressProtocol {
    
    var street_address: String
    var apt: String
    var city: String
    var state: String
    var zip: String
    var country: String
    var latitude: String
    var longitude: String
    
    
    init(street_address: String = "", apt: String = "", city: String = "", state: String = "", zip: String = "", country: String = "", latitude: String = "", longitude: String = "") {
        self.street_address = street_address
        self.apt = apt
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct CreatorModel: Codable, Identifiable {
    var id: String { _id }
    var _id: String = ""
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
}

struct LeadAddress: Codable {
    var street_address: String?
    var street: String?
    var apt: String?
    var city: String?
    var state: String?
    var zip: String?
    var country: String?

    var latitude: String?
    var longitude: String?

    init(
        address: String? = "",
        street: String? = "",
        aptSuite: String? = "",
        city: String? = "",
        state: String? = "",
        zip: String? = "",
        country: String? = "",
        latitude: String? = "",
        longitude: String? = ""
    ) {
        street_address = address
        self.street = street
        apt = aptSuite
        self.city = city
        self.state = state
        self.zip = zip
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
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

struct LeadUpdateResponse: Codable {
    // Define las propiedades de la respuesta de la API, si es necesario
}

struct LeadDeleteResponse: Codable {
    // Define las propiedades de la respuesta de la API, si es necesario
}

struct LeadModel: Codable, AddressProtocol, Equatable, Hashable {
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
        mode: Int = 2
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
        // try container.encode(user_id, forKey: .user_id)
    }

    func makePhoneCall(_ newPhone: String = "") {
        let myPhone = newPhone != "" ? newPhone : phone

        if let phoneURL = URL(string: "tel://\(myPhone)") {
            UIApplication.shared.open(phoneURL) { success in
                if success {
                    print("Successful call to", myPhone)
                } else {
                    print("Error during the call to", myPhone)
                }
            }
        } else {
            print("Error in the call URL")
        }
    }

    func openGoogleMaps() {
        if latitude == "" || longitude == "" {
            return
        }

        if let url = URL(string: "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                redirectToAppStoreForGoogleMaps()
            }
        }
    }

    func sendSMS() {
        if let url = URL(string: "sms:\(phone)") {
            UIApplication.shared.open(url)
        }
    }

    private func redirectToAppStoreForGoogleMaps() {
        if let appStoreURL = URL(string: "https://apps.apple.com/us/app/google-maps/id585027354") {
            UIApplication.shared.open(appStoreURL)
        }
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

        return ""
    }
}

/*
 struct LeadModel: Codable {

     var _id: String?
     var business_name: String?
     var first_name: String?
     var last_name: String?
     var phone: String?
     var phone2: String?
     var email: String?
     var street_address: String?
     var apt: String?
     var city: String?
     var state: String?
     var zip: String?
     var country: String?
     var longitude: String?
     var latitude: String?
     var appointment_date: String?
     var appointment_time: String?
     var status_id: StatusId?

     init(_id: String? = "", business_name: String? = "", first_name: String? = "", last_name: String? = "", phone: String? = "", phone2: String? = "", email: String? = "", street_address: String? = "", apt: String? = "", city: String? = "", state: String? = "", zip: String? = "", country: String? = "", longitude: String? = "", latitude: String? = "", appointment_date: String? = "", appointment_time: String? = "", status_id: StatusId? = StatusId()) {
         self._id = _id
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
     }
 }
 */

import SwiftUI

class ObservableLeadModel: ObservableObject {
    @Published var id: String
    @Published var business_name: String
    @Published var first_name: String
    @Published var last_name: String
    @Published var phone: String
    @Published var phone2: String
    @Published var email: String
    @Published var street_address: String
    @Published var apt: String
    @Published var city: String
    @Published var state: String
    @Published var zip: String
    @Published var country: String
    @Published var longitude: String
    @Published var latitude: String
    @Published var appointment_date: String
    @Published var appointment_time: String
    @Published var status_id: StatusId

    init(_id: String = "", business_name: String = "", first_name: String = "", last_name: String = "", phone: String = "", phone2: String = "", email: String = "", street_address: String = "", apt: String = "", city: String = "", state: String = "", zip: String = "", country: String = "", longitude: String = "", latitude: String = "", appointment_date: String = "", appointment_time: String = "", status_id: StatusId = StatusId()) {
        id = _id
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
    }
}

struct ApiConfig {
    var scheme: String? = nil
    let method: String
    let host: String
    let path: String
    let token: String
    let params: [String: String?]?
    var port: String? = nil
}

struct LeadsApiParam: Codable {
    let x: String?

    init(x: String? = "") {
        self.x = x
    }
}

struct ApiFetch<M: Codable, T: Decodable> {
    var parameters: M?
    // private let token: String
    private let info: ApiConfig

    init(info: ApiConfig, parameters: M?) {
        self.info = info
        self.parameters = parameters
    }

    func sendGet(query: [String: String?], completion: @escaping (T) -> Void) {
        let scheme: String = "https"
        // let host: String = "api.aquafeelvirginia.com"
        // let path = "/auth/login"

        var components = URLComponents()
        components.scheme = scheme
        components.host = info.host
        components.path = info.path

        components.queryItems = [URLQueryItem(name: "limit", value: "2500"), URLQueryItem(name: "offset", value: "0")]
        for (key, value) in query {
            // print("-----> \(key) : \(value ?? "")")
            components.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        // components.queryItems = [ URLQueryItem(name: "limit", value: "100"),  URLQueryItem(name: "offset", value: "0")]

        // print(components.url)
        guard let url = components.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = info.method

        // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.addValue("Bearer \(info.token)", forHTTPHeaderField: "Authorization")
        if let parameters = parameters {
            do {
                request.httpBody = try JSONEncoder().encode(parameters)
            } catch {
                print("Unable to encode request parameters")
            }
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                print(String(decoding: data, as: UTF8.self))
                let response = try? JSONDecoder().decode(T.self, from: data)

                if let response = response {
                    // print(response)
                    print("Load Leads OK")
                    completion(response)

                } else {
                    print("....Unable to decode response JSON...")
                    if let error = error {
                        print("....Error: \(error.localizedDescription)")
                    }
                }

            } else {
                // Error: API request failed

                if let error = error {
                    print("....Error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    func sendRequest(completion: @escaping (T) -> Void) {
        let scheme: String = "https"
        // let host: String = "api.aquafeelvirginia.com"
        // let path = "/auth/login"

        var components = URLComponents()
        components.scheme = scheme
        components.host = info.host
        components.path = info.path

        components.queryItems = [URLQueryItem(name: "limit", value: "2500"), URLQueryItem(name: "offset", value: "0")]

        // print(components.url)
        guard let url = components.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = info.method

        // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.addValue("Bearer \(info.token)", forHTTPHeaderField: "Authorization")
        if let parameters = parameters {
            do {
                request.httpBody = try JSONEncoder().encode(parameters)
            } catch {
                print("Unable to encode request parameters")
            }
        }

        print(url)
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                // print(String(decoding: data, as: UTF8.self))
                let response = try? JSONDecoder().decode(T.self, from: data)

                if let response = response {
                    // print(response)
                    print("Load Leads OK 2.2")
                    completion(response)

                } else {
                    print("....Unable to decode response JSON...")
                    if let error = error {
                        print("....Error: \(error.localizedDescription)")
                    }
                }

            } else {
                // Error: API request failed

                if let error = error {
                    print("....Error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }

    func sendPost<T2: Codable>(lead: T2, token: String, completion: @escaping (Result<LeadUpdateResponse, Error>) -> Void) {
        // URL of the API endpoint for updates
        let apiUrl = URL(string: "https://api.aquafeelvirginia.com/leads/edit")!

        // Create URLRequest
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"

        // Set the request body with model data
        do {
            // print(lead.id, lead.user_id)
            // print(lead.status_id)
            let jsonData = try JSONEncoder().encode(lead)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // print(jsonString)
            }
            request.httpBody = jsonData

        } catch {
            completion(.failure(error))
            return
        }

        // Add the authorization header with the Bearer token
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Configure URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // Handle API response
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Response data is nil", code: 0, userInfo: nil)))
                return
            }

            // print(String(decoding: data, as: UTF8.self))

            do {
                // Decode the API response
                let decodedResponse = try JSONDecoder().decode(LeadUpdateResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }

        // Start the task
        task.resume()
    }

    func fetch<T2: Codable>(body: T2, config: ApiConfig, completion: @escaping (Result<LeadUpdateResponse, Error>) -> Void) {
        // URL of the API endpoint for updates

        var components = URLComponents()
        components.scheme = "https"
        components.host = config.host
        components.path = config.path

        guard let url = components.url else {
            return
        }

        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = config.method

        // Set the request body with model data
        do {
            let jsonData = try JSONEncoder().encode(body)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // print(jsonString)
            }
            request.httpBody = jsonData

        } catch {
            completion(.failure(error))
            return
        }

        // Add the authorization header with the Bearer token
        request.addValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Configure URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // Handle API response
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Response data is nil", code: 0, userInfo: nil)))
                return
            }

            print(String(decoding: data, as: UTF8.self))

            do {
                // Decode the API response
                let decodedResponse = try JSONDecoder().decode(LeadUpdateResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }

        // Start the task
        task.resume()
    }

    func fetch(config: ApiConfig, completion: @escaping (Result<LeadUpdateResponse, Error>) -> Void) {
        // URL of the API endpoint for updates

        var components = URLComponents()
        components.scheme = "https"
        components.host = config.host
        components.path = config.path
        if let params = config.params {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        // Create URLRequest
        guard let url = components.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = config.method
        // Add the authorization header with the Bearer token
        request.addValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
        // request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Configure URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            // Handle API response
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Response data is nil", code: 0, userInfo: nil)))
                return
            }

            // print(String(decoding: data, as: UTF8.self))

            do {
                // Decode the API response
                let decodedResponse = try JSONDecoder().decode(LeadUpdateResponse.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }

        // Start the task
        task.resume()
    }
}

class LeadQuery {
    private var map: [String: String?] = [:]

    func add(_ key: LeadAllQuery, _ value: String) -> LeadQuery {
        // print(key.rawValue)
        map[key.rawValue] = value
        return self
    }

    func getQuery() -> [URLQueryItem] {
        return map.map { URLQueryItem(name: $0.key, value: $0.value) }
    }

    func get() -> [String: String?] {
        map
    }
}

/*
 #Preview {
     LeadListScreen()
 }
 */
/*
 let lead: LeadModel = LeadModel(

 id: "65c906e5f4a97859d195db2c",
 business_name: "N/A",
 first_name: "Nuñez",
 last_name: "Yanny Panda",
 phone: "",
 phone2: "",
 email: "",

 street_address: "4444 Evergreen Drive, Woodbridge, Virginia, EE. UU.",
 apt: "",
 city: "Prince William County",
 state: "TX",
 zip: "22193",
 country: "Estados Unidos",
 longitude: "-77.3374901",
 latitude: "38.637312",

 appointment_date: "2024-02-01T05:45:00.000Z",
 appointment_time: "2024-02-08T22:00:27.000Z",
 status_id: StatusId(
 isDisabled: false,
 _id: "613bb4e0d6113e00169fefa9",
 name: "RENT",
 image: "uploads/1631343874770-RENT.png",
 __v: 0
 ),
 created_by: CreatorModel(_id: "xLv4wI2TM")

 )

 */
