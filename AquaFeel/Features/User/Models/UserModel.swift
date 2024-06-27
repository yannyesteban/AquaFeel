//
//  UserModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/2/24.
//

import Foundation
import CoreLocation

struct RegisterRequest: Codable {
    let message: String
    let user: User?
    
}

struct UsersRequest: Codable {
    let users: [User]
    let count: Int
}


struct UserFilter {
    
    var textFilter =  ""
    var status: [String] = []
    var fromDate: Date? = nil
    var toDate: Date? = nil
    var dateField = ""
    var quickdate = "all_time"//yesterday, current_week current_month current_year custom
    var owner: [String] = []
    
    
}

struct DateFilters: Codable {
    var selectedDateFilter: String
    var selectedQuickDate: String
    var fromDate: String
    var toDate: String
}

struct LeadFilter: Codable {
    struct Status: Codable {
        var isDisabled: Bool
        var _id: String
        var name: String
        var image: String
        
        init(isDisabled: Bool = false, _id: String = "", name: String = "", image: String = "") {
            self.isDisabled = isDisabled
            self._id = _id
            self.name = name
            self.image = image
        }
    }
    
    struct DateFilters: Codable {
        var selectedDateFilter: String
        var selectedQuickDate: String
        var fromDate: String
        var toDate: String
        init(selectedDateFilter: String = DateFind.appointmentDate.rawValue, selectedQuickDate: String = TimeOption.allTime.rawValue, fromDate: String = "", toDate: String = "") {
            self.selectedDateFilter = selectedDateFilter
            self.selectedQuickDate = selectedQuickDate
            
            if fromDate == "" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                self.fromDate = dateFormatter.string(from: Date())
                self.toDate = dateFormatter.string(from: Date())
            } else {
                self.fromDate = fromDate
                self.toDate = toDate
            }
        }
    }
    
    var selectedStatuses: [Status]
    var dateFilters: DateFilters
    var selectedOwner: [String]
    
    init(selectedStatuses: [Status] = [], dateFilters: DateFilters = DateFilters(), selectedOwner: [String] = []) {
        self.selectedStatuses = selectedStatuses
        self.dateFilters = dateFilters
        self.selectedOwner = selectedOwner
    }
}

struct User: Codable {
    var isBlocked: Bool
    var isVerified: Bool
    var assignedSellers: [String]
    var leadFilters: LeadFilter?
    var _id: String
    var email: String
    var firstName: String
    var lastName: String
    var password: String = ""
    var role: String
    var createdAt: String
    var updatedAt: String
    var __v: Int?
    var latitude: Double?
    var longitude: Double?
    var avatar: String?
    
    var position: CLLocationCoordinate2D {
        get {
            guard let latitude = latitude, let longitude = longitude else {
                return kCLLocationCoordinate2DInvalid
            }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set(newPosition) {
            latitude = newPosition.latitude
            longitude = newPosition.longitude
        }
    }
    
    init(
        isBlocked: Bool = false,
        isVerified: Bool = false,
        assignedSellers: [String] = [],
        leadFilters: LeadFilter = LeadFilter(selectedStatuses: [], dateFilters: LeadFilter.DateFilters(selectedDateFilter: "", selectedQuickDate: "", fromDate: "", toDate: ""), selectedOwner: []),
        _id: String = "",
        email: String = "",
        firstName: String = "",
        lastName: String = "",
        password: String = "",
        role: String = "",
        createdAt: String = "",
        updatedAt: String = "",
        __v: Int = 0,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        avatar: String = ""
    ) {
        self.isBlocked = isBlocked
        self.isVerified = isVerified
        self.assignedSellers = assignedSellers
        self.leadFilters = leadFilters
        self._id = _id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.role = role
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.__v = __v
        self.latitude = latitude
        self.longitude = longitude
        self.avatar = avatar
    }
    
    enum CodingKeys: CodingKey {
        case isBlocked
        case isVerified
        case assignedSellers
        case leadFilters
        case _id
        case id
        case email
        case firstName
        case lastName
        case password
        case role
        case createdAt
        case updatedAt
        case __v
        case latitude
        case longitude
        case avatar
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<User.CodingKeys> = try decoder.container(keyedBy: User.CodingKeys.self)
        isBlocked = try container.decodeIfPresent(Bool.self, forKey: .isBlocked) ?? false
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified) ?? false
        assignedSellers = try container.decodeIfPresent([String].self, forKey: User.CodingKeys.assignedSellers) ?? []
        
        
        //isBlocked = try container.decode(Bool.self, forKey: User.CodingKeys.isBlocked)
        //isVerified = try container.decode(Bool.self, forKey: User.CodingKeys.isVerified)
        //assignedSellers = try container.decode([String].self, forKey: User.CodingKeys.assignedSellers)
        leadFilters = try container.decodeIfPresent(LeadFilter.self, forKey: User.CodingKeys.leadFilters)
        _id = try container.decode(String.self, forKey: User.CodingKeys._id)
        //email = try container.decode(String.self, forKey: User.CodingKeys.email)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        firstName = try container.decode(String.self, forKey: User.CodingKeys.firstName)
        lastName = try container.decode(String.self, forKey: User.CodingKeys.lastName)
        
        password = try container.decodeIfPresent(String.self, forKey: .password) ?? ""
        // self.password = try container.decode(String.self, forKey: User.CodingKeys.password)
        role = try container.decode(String.self, forKey: User.CodingKeys.role)
        createdAt = try container.decode(String.self, forKey: User.CodingKeys.createdAt)
        updatedAt = try container.decode(String.self, forKey: User.CodingKeys.updatedAt)
        __v = try container.decodeIfPresent(Int.self, forKey: User.CodingKeys.__v)
        latitude = try container.decodeIfPresent(Double.self, forKey: User.CodingKeys.latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: User.CodingKeys.longitude)
        avatar = try container.decodeIfPresent(String.self, forKey: User.CodingKeys.avatar)
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<User.CodingKeys> = encoder.container(keyedBy: User.CodingKeys.self)
        
        try container.encode(isBlocked, forKey: User.CodingKeys.isBlocked)
        try container.encode(isVerified, forKey: User.CodingKeys.isVerified)
        try container.encode(assignedSellers, forKey: User.CodingKeys.assignedSellers)
        try container.encodeIfPresent(leadFilters, forKey: User.CodingKeys.leadFilters)
        try container.encode(_id, forKey: User.CodingKeys._id)
        try container.encode(_id, forKey: User.CodingKeys.id)
        try container.encode(email, forKey: User.CodingKeys.email)
        try container.encode(firstName, forKey: User.CodingKeys.firstName)
        try container.encode(lastName, forKey: User.CodingKeys.lastName)
        try container.encode(password, forKey: User.CodingKeys.password)
        try container.encode(role, forKey: User.CodingKeys.role)
        try container.encode(createdAt, forKey: User.CodingKeys.createdAt)
        try container.encode(updatedAt, forKey: User.CodingKeys.updatedAt)
        try container.encodeIfPresent(__v, forKey: User.CodingKeys.__v)
        try container.encodeIfPresent(latitude, forKey: User.CodingKeys.latitude)
        try container.encodeIfPresent(longitude, forKey: User.CodingKeys.longitude)
        try container.encodeIfPresent(avatar, forKey: User.CodingKeys.avatar)
    }
}







func fetch<T2: Codable, T: Decodable>(body: T2, config: ApiConfig, completion: @escaping (Result<T, Error>) -> Void) {
    // URL of the API endpoint for updates
    
    var components = URLComponents()
    components.scheme = config.scheme ?? "https"
    components.host = config.host
    components.path = config.path
    components.port = Int(config.port ?? "80")
    
    guard let url = components.url else {
        return
    }
    
    print(url)
    // Create URLRequest
    var request = URLRequest(url: url)
    request.httpMethod = config.method
    
    // Set the request body with model data
    do {
        let jsonData = try JSONEncoder().encode(body)
        /*if let jsonString = String(data: jsonData, encoding: .utf8) {
         print(jsonString)
         }*/
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
        //print("JSON: ")
        print(String(decoding: data, as: UTF8.self))
        //print(";\n")
        do {
            // Decode the API response
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Start the task
    task.resume()
}

func fetch<T: Decodable>(config: ApiConfig, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask? {
    // URL of the API endpoint for updates
    
    
    var components = URLComponents()
    components.scheme = config.scheme
    components.host = config.host
    components.path = config.path
    components.port = Int(config.port ?? "80")
    
    if let params = config.params {
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    // Create URLRequest
    guard let url = components.url else {
        
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = config.method
    // Add the authorization header with the Bearer token
    request.addValue("Bearer \(config.token)", forHTTPHeaderField: "Authorization")
    // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Configure URLSession task
    print("begin: ", url)
    
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
        print("End: ", url)
        do {
            // Decode the API response
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Start the task
    task.resume()
    
    return task
}

class UserModel: ObservableObject {
    @Published var user: User = User()
    
    @Published var first_name: String = ""
    @Published var last_name: String = ""
    
    @Published var data: LeadModel = LeadModel()
    
    @Published var leads: [LeadModel] = []
    @Published var statusList: [StatusId] = []
    @Published var mode = 0
    @Published var token = ""
    init(first_name: String = "", last_name: String = "") {
        self.first_name = first_name
        self.last_name = last_name
    }
    
    
    func get(query: LeadQuery) {
        
        let path = "/users/details"
        let params: [String : String?]? = query.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: token, params: query.get())
        
        fetch(config: info) { (result: Result<User, Error>) in
            switch result {
            case let .success(user):
                DispatchQueue.main.async {
                    print("Get User:", user.firstName)
                    print(user)
                    self.user = user
                }
                
            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }
    
    func loadAll() {
        // let param = LeadsApiParam()
        
        let path = "/users/details"
        let params: [String : String?]? = [:]
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: token, params: [:])
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).sendRequest { data in
            DispatchQueue.main.async {
                
                self.leads = data.leads
            }
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func loadAll(query: LeadQuery) {
        // Crear un diccionario usando los casos del enum como claves y asignarles valores de cadena iguales a sus nombres
        var dictionary: [LeadAllQuery: String] = [:]
        
        for myCase in LeadAllQuery.allCases {
            
            dictionary[myCase] = myCase.rawValue
        }
        
        let path = "/leads/list-all"
        let params: [String : String?]? = [:]
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/list-all", token: token, params: [:])
        
        
        print("xxxxx 55 55 555 55 5 ")
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).sendGet(query: query.get()) { data in
            DispatchQueue.main.async {
                self.first_name = "que Cool"
                self.leads = data.leads
            }
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func statusAll() {
        // let param = LeadsApiParam()
        let path = "/status/list"
        let params: [String : String?]? = [:]
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: token, params: [:])
        
        ApiFetch<LeadsApiParam, StatusModel>(
            info: info, parameters: nil
        ).sendRequest { data in
            DispatchQueue.main.async {
                self.first_name = "que Cool"
                self.statusList = data.list
            }
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func save<D: Codable>(body: D, mode: ModeSave = .edit) {
        var path: String
        
        switch mode {
        case .add:
            path = "/leads/add"
        case .edit:
            path = "/leads/edit"
        case .delete:
            path = "/leads/delete"
        case .none:
            return
        }
        
        
        
        let params: [String : String?]? = [:]
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: path, token: token, params: [:])
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                print(jsonString)
                // return
            }
        } catch {
        }
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).fetch(body: body, config: info) { result in
            switch result {
            case let .success(response):
                print("Update successful:", response)
            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }
    
    func delete(query: LeadQuery) {
        
        let path = "/leads/delete"
        let params: [String : String?]? = query.get()
        let method = "DELETE"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "DELETE", host: "api.aquafeelvirginia.com", path: "/leads/delete", token: token, params: query.get())
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).fetch(config: info) { result in
            switch result {
            case let .success(response):
                print("Update successful:", response)
            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }
    
    func showSatus() {
        statusAll()
    }
}

