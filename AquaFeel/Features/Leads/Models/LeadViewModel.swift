//
//  LedViewModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 10/3/24.
//

import Foundation

/*
class LeadViewModel: ObservableObject {
    @Published var first_name: String = ""
    @Published var last_name: String = ""
    
    @Published var data: LeadModel = LeadModel()
    
    @Published var leads: [LeadModel] = []
    @Published var statusList: [StatusId] = []
    @Published var mode = 0
    
    @Published var selected: LeadModel?
    
    init(first_name: String, last_name: String) {
        self.first_name = first_name
        self.last_name = last_name
    }
    
    // @MainActor
    func loadAll() {
        print("............. loadAll 1.0")
        // let param = LeadsApiParam()
        
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/list-all", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
        ApiFetch<LeadsApiParam, LeadsModel>(
            info: info, parameters: nil
        ).sendRequest { data in
            DispatchQueue.main.async {
                self.first_name = "que Cool"
                self.leads = data.leads
            }
            
            // Login successful, navigate to the Home screen
        }
    }
    
    func loadAll(query: LeadQuery) {
        print("............. loadAll 2.0")
        
        // Crear un diccionario usando los casos del enum como claves y asignarles valores de cadena iguales a sus nombres
        var dictionary: [LeadAllQuery: String] = [:]
        
        for myCase in LeadAllQuery.allCases {
            // print(myCase.rawValue)
            dictionary[myCase] = myCase.rawValue
        }
        
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/list-all", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
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
        
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
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
    
    func save2(body: LeadModel, mode: ModeSave = .edit, completion: @escaping (Bool, LeadModel?) -> Void) {
        var path: String
        
        switch mode {
        case .add:
            path = "/leads/add"
        case .edit:
            path = "/leads/edit"
        case .delete:
            path = "/leads/delete"
        }
        
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: path, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: nil)
        
        fetch<LeadModel, LeadUpdateResponse>(body: body, config: info) { (result: Result<LeadModel /* LeadUpdateResponse */, Error>) in
            switch result {
            case let .success(lead):
                
                // print(lead)
                if let index = self.leads.firstIndex(where: { $0.id == body.id }) {
                    print("exito")
                    // Encuentra la posición del elemento en el array por su ID
                    
                    self.leads[index] = body // Actualiza el elemento en esa posición con el objeto modificado
                } else {
                    print("fracaso")
                }
                
                completion(true, lead)
            case let .failure(error):
                print("Error updating:", error)
                completion(false, nil)
            }
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
        }
        
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: path, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: [:])
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // print("/n/n/....../n")
                // print(jsonString)
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
        let info = ApiConfig(method: "DELETE", host: "api.aquafeelvirginia.com", path: "/leads/delete", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE", params: query.get())
        
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


*/
