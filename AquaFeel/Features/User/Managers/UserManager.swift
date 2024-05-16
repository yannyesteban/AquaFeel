//
//  UserManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/2/24.
//

import Combine
import Foundation

struct BlockResponse: Codable, NeedStatusCode {
    var message: String?
    var statusCode: Int?
}

class UserManager: ObservableObject {
    let userId: String = ""
    let token: String = ""

    @Published var users: [User] = []
    @Published var selected: LeadModel?
    @Published var textFilter = ""
    @Published var filter = LeadFilter2(textFilter: "")

    var page = 1
    // var offset = 3
    var limit = 1000
    var maxLoads = 0
    var userTotal = 0
    var autoLoad = false
    var resetData = false

    private var cancellables: Set<AnyCancellable> = []

    /*

     init() {

         $filter

             .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
             .sink { [weak self] filter in

                 self?.search()
             }
             .store(in: &cancellables)
     }
     */
    func getSellers() async throws {
        
        
        let path = "/users/list-all-sellers"
        let params: [String : String?]? = nil
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list-all-sellers", token: token, params: nil)

        do {
            let response: AllSellersResponse = try await fetching(config: info)

            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.users = response.users
                }
            } else {
                print("Error in list sellers")
            }

        } catch {
            throw error
        }
    }

    func list(query: LeadQuery? = nil, completion: (() -> Void)? = nil) {
        let offset = (page - 1) * limit

        let q: LeadQuery

        if let _query = query {
            q = _query
        } else {
            q = LeadQuery()
        }
        _ = q
            .add(.offset, String(offset))
            .add(.limit, String(limit))

        if filter.textFilter != "" {
            _ = q

                .add(.searchKey, "all")
                .add(.searchValue, filter.textFilter)
        }

        if !filter.status.isEmpty {
            _ = q
                .add(.statusId, filter.status.joined(separator: ","))
        }

        let path = "/users/list"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list", token: token, params: q.get())

        _ = fetch(config: info) { (result: Result<UsersRequest, Error>) in
            switch result {
            case let .success(data):

                DispatchQueue.main.async {
                    if data.users.count > 0 {
                        if self.resetData {
                            print("reset users")
                            self.users = data.users
                            self.resetData = false
                        } else {
                            self.users = data.users
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

            case let .failure(error):
                print("Error updating:", error)
            }
        }
    }
    
    
    func getUsers() async throws -> [User] {
        let q = LeadQuery()
            .add(.limit, "1000")
        
        let path = "/users/list"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/list", token: token, params: q.get())
        
        do {
            let reponse: UsersRequest = try await fetching(config: info)
            
            return reponse.users
            
        } catch {
            throw error
        }
    }
    
    func getUser(id: String) async throws -> User {
        let q = LeadQuery()
            .add(.id, id)
        
        let path = "/users/details"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: token, params: q.get())
        
        do {
            let user: User = try await fetching(config: info)
            
            return user
            
        } catch {
            throw error
        }
    }

    func save(body: User, mode: ModeSave = .edit, completion: @escaping (Bool, RegisterRequest?) -> Void) {
        var path: String
        var method = "POST"
        switch mode {
        case .add:
            path = "/users/add"
        case .edit:
            path = "/users/edit"
            method = "PUT"
        case .delete:
            path = "/users/delete"
            method = "DELETE"
        case .none:
            return
        }
        
        
        
        let params: [String : String?]? = nil
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        //let info = ApiConfig(method: method, host: "api.aquafeelvirginia.com", path: path, token: token, params: nil)

        fetch<User, RegisterRequest>(body: body, config: info) { (result: Result<RegisterRequest /* LeadUpdateResponse */, Error>) in
            switch result {
            case let .success(result):
                DispatchQueue.main.async {
                    print(result)

                    completion(true, result)
                }
            case let .failure(error):
                print("Error updating:", error)
                completion(false, nil)
            }
        }
    }

    func blockUser(body: User) async throws -> Bool {
        let q = LeadQuery().add(.id, body._id)
        
        let path = "/users/block"
        let params: [String : String?]? = q.get()
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/users/block", token: token, params: q.get())

        do {
            let response: BlockResponse = try await fetching(body: body, config: info)

            if response.statusCode == 201 {
                return true

            } else {
                return false
            }

        } catch {
            throw error
        }
    }

    func reset() {
        page = 1
        resetData = true
        textFilter = ""
        filter.textFilter = ""
        filter.status = []
        // leads = []
    }

    func search() {
        page = 1
        resetData = true
        list()

        // leads = []
    }

    func runLoad() {
        list(query: nil) {
            if self.users.count < self.maxLoads {
                self.runLoad()
            }
        }
    }

    func load(count: Int) {
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
