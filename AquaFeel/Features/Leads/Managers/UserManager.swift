//
//  UserManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/2/24.
//

import Foundation
import Combine

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

class UserManager: ObservableObject {
    let userId: String = ""
    let token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcwNTYxMDY3NCwiZXhwIjoxNzEwNzk0Njc0fQ.5nPyOfuwOF3jOxm2lziG-_4jtDEqQmp9i3a6yBjIFCE"
    
    @Published var users: [User] = []
    @Published var selected: LeadModel?
    @Published var textFilter = ""
    @Published var filter = LeadFilter2(textFilter: "")
    
    var page = 1
    //var offset = 3
    var limit = 1000
    var maxLoads = 0
    var userTotal = 0
    var autoLoad = false
    var resetData = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    ///private var cancellables: Set<AnyCancellable> = []
    
    init() {
        // Aquí suscribimos a los cambios de textFilter
        /*$textFilter
         .debounce(for: .seconds(0.2), scheduler: RunLoop.main) // opcional: debounce para esperar un tiempo después de la última edición
         .sink { [weak self] newValue in
         
         // Aquí puedes realizar la lógica que deseas cada vez que textFilter cambie
         self?.search()
         }
         .store(in: &cancellables)
         
         $filter
         .map { $0.textFilter }
         .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
         .sink { [weak self] newValue in
         self?.search()
         }
         .store(in: &cancellables)
         */
        $filter
        
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] filter in
                print("hello")
                self?.search()
            }
            .store(in: &cancellables)
    }
    
    func list(query: LeadQuery? = nil, completion: (() -> Void)? = nil){
        
        let offset = (page - 1) * limit
        
        let q: LeadQuery
        
        if let _query =  query {
            q =  _query
        }else {
            q = LeadQuery()
        }
        _ = q
            .add(.offset, String(offset))
            .add(.limit , String(limit))
        
        
        if filter.textFilter != "" {
            
            _ = q
            
                .add(.searchKey, "all")
                .add(.searchValue, filter.textFilter)
        }
        
        if !filter.status.isEmpty {
            _ = q
                .add(.statusId, filter.status.joined(separator: ","))
        }
        
        let info = ApiConfig(method:"GET", host: "api.aquafeelvirginia.com", path: "/users/list", token: token, params: q.get())
        
        
        fetch(config: info) { (result: Result<UsersRequest, Error>) in
            switch result {
            case .success(let data):
                
                DispatchQueue.main.async{
                    if data.users.count > 0 {
                        if self.resetData {
                            print("reset users")
                            self.users =  data.users
                            self.resetData = false
                        }else{
                            self.users =  data.users
                        }
                        
                        if self.autoLoad {
                            self.maxLoads = data.count
                        }
                        //
                        self.userTotal = data.count
                        self.page += 1
                        completion?()
                    }
                    
                }
                
                
                
            case .failure(let error):
                print("Error updating:", error)
            }
        }
    }
    
    func save(body: User, mode: ModeSave = .edit, completion: @escaping (Bool, RegisterRequest?) -> Void) {
        var path: String
        
        switch mode {
        case .add:
            path = "/users/add"
        case .edit:
            path = "/users/edit"
        case .delete:
            path = "/users/delete"
        }
        
        
        
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: path, token: token, params: nil)
        
        fetch<User, RegisterRequest>(body: body, config: info) { (result: Result<RegisterRequest /* LeadUpdateResponse */, Error>) in
            switch result {
            case let .success(result):
                DispatchQueue.main.async {
                    
                   //print(result)
                    
                    completion(true, result)
                }
            case let .failure(error):
                print("Error updating:", error)
                completion(false, nil)
            }
        }
    }
    
    
    func reset(){
        page = 1
        resetData = true
        textFilter = ""
        filter.textFilter = ""
        filter.status = []
        //leads = []
    }
    
    func search(){
        page = 1
        resetData = true
        list()
        
        //leads = []
    }
    
    func runLoad(){
        
        list(query: nil){
            if self.users.count < self.maxLoads {
                self.runLoad()
            }
        }
    }
    
    func load(count:Int){
        maxLoads = count
        autoLoad = false
        runLoad()
    }
    
    func loadLeadsContinuously() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            print("\(self.users.count) < \(self.maxLoads) : ", self.users.count < self.maxLoads)
            while self.users.count < self.maxLoads {
                self.list()
            }
        }
    }
    
    
    
}
