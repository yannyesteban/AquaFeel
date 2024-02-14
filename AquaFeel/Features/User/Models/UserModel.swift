//
//  UserModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/2/24.
//

import Foundation

struct LeadFilter: Codable {
    struct Status: Codable {
        let isDisabled: Bool
        let _id: String
        let name: String
        let image: String
    }
    
    struct DateFilters: Codable {
        let selectedDateFilter: String
        let selectedQuickDate: String
        let fromDate: String
        let toDate: String
    }
    
    let selectedStatuses: [Status]
    let dateFilters: DateFilters
    let selectedOwner: [String]
}

struct User: Codable {
    let isBlocked: Bool
    let isVerified: Bool
    let assignedSellers: [String]
    let leadFilters: LeadFilter
    let _id: String
    let email: String
    let firstName: String
    let lastName: String
    let password: String
    let role: String
    let createdAt: String
    let updatedAt: String
    let __v: Int
    let latitude: Double
    let longitude: Double
    
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
        longitude: Double = 0.0
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
    }
}

func fetch<T:Decodable>(config: ApiConfig, completion: @escaping (Result<T, Error>) -> Void) {
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
    //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Configure URLSession task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedResponse))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Start the task
    task.resume()
}

class UserModel: ObservableObject {
    
    @Published var user: User = User()
    
    @Published var first_name: String = "yanyesteban@gmail.com"
    @Published var last_name: String = "Acceso1024"
    
    @Published var data: LeadModel = LeadModel()
    
    @Published var leads: [LeadModel] = []
    @Published var statusList: [StatusId] = []
    @Published var mode = 0
    
    init(first_name: String = "", last_name: String = "") {
        self.first_name = first_name
        self.last_name = last_name
    }
    
    
    
    func get(query: LeadQuery) {
        
        
        let info = ApiConfig(method:"GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: query.get())
        
        
        fetch(config: info) { (result: Result<User, Error>) in
            switch result {
            case .success(let user):
                print("Get User:", user.firstName)
                print(user)
                self.user = user
            case .failure(let error):
                print("Error updating:", error)
            }
        }
        
      
    }
    
    
    func loadAll() {
        
        //let param = LeadsApiParam()
        
        let info = ApiConfig(method:"GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).sendRequest { data in
            DispatchQueue.main.async{
                self.first_name = "que Cool"
                self.leads = data.leads
                
                
            }
            
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func loadAll(query: LeadQuery) {
        
        
        
        // Crear un diccionario usando los casos del enum como claves y asignarles valores de cadena iguales a sus nombres
        var dictionary: [LeadAllQuery: String] = [:]
        
        for myCase in LeadAllQuery.allCases {
            print(myCase.rawValue)
            dictionary[myCase] = myCase.rawValue
        }
        
        
        
        
        
        let info = ApiConfig(method:"GET", host: "api.aquafeelvirginia.com", path: "/leads/list-all", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).sendGet(query: query.get()) { data in
            DispatchQueue.main.async{
                self.first_name = "que Cool"
                self.leads = data.leads
                
                
            }
            
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func statusAll() {
        
        //let param = LeadsApiParam()
        
        
        
        let info = ApiConfig(method:"GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
        ApiFetch<LeadsApiParam, StatusModel>(
            info: info, parameters: nil
        ).sendRequest { data in
            DispatchQueue.main.async{
                self.first_name = "que Cool"
                self.statusList = data.list
                
                
            }
            
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func save<D : Codable>(body: D, mode: ModeSave = .edit){
        
        var path: String
        
        switch mode {
        case .add:
            path = "/leads/add"
        case .edit:
            path = "/leads/edit"
        case .delete:
            path = "/leads/delete"
            
        }
        
        
        let info = ApiConfig(method:"POST", host: "api.aquafeelvirginia.com", path: path, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("/n/n/....../n")
                print(jsonString)
                //return
            }
        }catch{
            
        }
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).fetch(body: body, config: info) { result in
            switch result {
            case .success(let response):
                print("Update successful:", response)
            case .failure(let error):
                print("Error updating:", error)
            }
        }
        
        
    }
    
    func delete(query: LeadQuery){
        let info = ApiConfig(method:"DELETE", host: "api.aquafeelvirginia.com", path: "/leads/delete", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: query.get())
        
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).fetch(config: info) { result in
            switch result {
            case .success(let response):
                print("Update successful:", response)
            case .failure(let error):
                print("Error updating:", error)
            }
        }
    }
    
    func showSatus(){
        
        statusAll()
    }
}
