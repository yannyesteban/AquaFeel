//
//  LoginManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 20/1/24.
//

import Foundation

struct PasswordResponse: Codable, NeedStatusCode{
    let message: String
    var statusCode: Int?
}

struct PasswordModel: Codable {
    var email: String
    var oldPassword: String
    var newPassword: String
}

struct ProfileResponse: Codable {
    let message: String
    let profile: Profile
}

struct Profile: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case firstName
        case lastName
        case role
    }
}


var SuperToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InhMdjR3STJUTSIsImVtYWlsIjoieWFubnllc3RlYmFuQGdtYWlsLmNvbSIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTcxMTExNjU5MCwiZXhwIjoxNzE2MzAwNTkwfQ.cBCnDu-4B7EhiYI45J3hId1_fOEITwzySY9QvW-UfcE"



class ProfileManager: LoginProtocol, ObservableObject {
    @Published var leadFilters = LeadFilter()

    @Published var user: String = ""
    @Published var pass: String = ""
    @Published var auth: Bool = false
    @Published var begin: Bool = false
    @Published var isLoading = false
    
    @Published var error = false

    @Published var userId: String = "xLv4wI2TM"//xLv4wI2TM - DD2EMns3y"
    @Published var token: String = SuperToken
    @Published var role: String = "SELLER"// ADMIN   - SELLER"
    @Published var id: String = ""

    @Published var info: User = User()

    @Published var myTest: String = "myTest"

    @Published var waiting = false

    var store: UserData = UserData()
    var saveAction: (Bool) -> Void = { _ in
    }

    init(user: String = "", password: String = "") {
        self.user = user
        pass = password
        Task {
            await load()
        }
        
    }

    func _login() async throws -> LoginResponse {
        let body = LoginFetch(
            email: user,
            password: pass
        )

        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/auth/login", token: token, params: nil)

        do {
            let response: LoginResponse = try await fetching(body: body, config: info)

            return response

        } catch {
            throw error
        }
    }

    func _userData(id: String) async throws -> User {
        let query = LeadQuery()
            .add(.id, id)

        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: token, params: query.get())

        do {
            let response: User = try await fetching(config: info)

            return response

        } catch {
            throw error
        }
    }

    func login(completion: @escaping (Bool, LoginFetch?) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = false
        }

        Task {
            do {
                let response: LoginResponse = try await _login()
                
                let userData = try await _userData(id: response.user?._id ?? "")
                
                DispatchQueue.main.async {
                    
                    self.error = false
                    self.isLoading = false
                    self.info = userData
                    self.user = userData.email

                    self.auth = true

                    self.token = response.token ?? ""
                    self.role = response.user?.role ?? ""
                    self.id = response.user?._id ?? ""
                    self.userId = response.user?._id ?? ""

                    if let filters = userData.leadFilters {
                        self.leadFilters = filters
                    }

                    if let avatar = userData.avatar {
                        self.info.avatar = "https://api.aquafeelvirginia.com/uploads/" + avatar
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.error = true
                    self.auth = false
                    self.isLoading = false
                    
                }
                print("error 1.0 \(error)")
                throw  error
                
            }
        }
    }
/*
    func login2(completion: @escaping (Bool, LoginFetch?) -> Void) {
        isLoading = true

        // return
        let body = LoginFetch(
            email: user,
            password: pass
        )

        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/auth/login", token: token, params: nil)

        fetch<LoginFetch, LoginResponse>(body: body, config: info) { (result: Result<LoginResponse /* LeadUpdateResponse */, Error>) in
            switch result {
            case let .success(data):
                DispatchQueue.main.async {
                    if let user = data.user {
                        self.user = user.email
                        self.auth = true
                        self.token = data.token!
                        self.id = user._id
                        self.role = user.role
                    } else {
                        self.user = ""
                        self.auth = false
                        self.token = ""
                        self.id = ""
                        self.role = ""
                    }
                    self.begin = true

                    completion(true, body)

                    self.saveAction(true)
                }
            case let .failure(error):
                self.begin = true
                print("Error updating:", error)
                completion(false, nil)
                self.saveAction(false)
            }

            self.isLoading = false
        }
    }
*/
    func isAuth() -> Bool {
        return auth
    }

    func load() async {
        do {
            store = try await loadFile(name: "LoginStore1.data")

            DispatchQueue.main.async {
                self.token = self.store.token
                self.role = self.store.role
                self.id = self.store.id
                self.userId = self.store.userId
                self.info = self.store.info
                self.myTest = self.store.role
            }

        } catch {
            print(error)
        }
    }

    func save() async {
        do {
            var store: UserData = UserData()
            store.token = token
            store.userId = userId
            store.role = role
            store.info = info
            store.id = id
            store.token = token

            try await saveFile(userData: store, name: "LoginStore1.data")
        } catch {
            print(error)
        }
    }

    func saveProfile() async throws {
        DispatchQueue.main.async {
            self.waiting = true
        }

        let apiInfo = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/profile/edit", token: token, params: nil)

        // let info = ApiConfig(scheme: "http", method: method, host: "127.0.0.1", path: path, token: token, params: nil, port : "4000")

        do {
            let response: ProfileResponse = try await fetching(body: info, config: apiInfo)

            
            DispatchQueue.main.async {
                self.waiting = false
            }

        } catch {
            DispatchQueue.main.async {
                self.waiting = false
            }
            throw error
        }
    }
    
    func changePassword(email: String, oldPassword: String, newPassword: String) async throws -> PasswordResponse{
        DispatchQueue.main.async {
            self.waiting = true
        }
        let body = PasswordModel(email: email, oldPassword: oldPassword, newPassword: newPassword)
        
        let apiInfo = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/auth/changePassword", token: token, params: nil)
        
        // let info = ApiConfig(scheme: "http", method: method, host: "127.0.0.1", path: path, token: token, params: nil, port : "4000")
        
        do {
            let response: PasswordResponse = try await fetching(body: body, config: apiInfo)
            
            DispatchQueue.main.async {
                self.waiting = false
            }
            
            return response
        } catch {
            
            DispatchQueue.main.async {
                self.waiting = false
            }
            throw error
        }
    }

    func validProfile() -> String {
        if info.firstName.isEmpty {
            return "First Name is required!"
        }

        if info.lastName.isEmpty {
            return "Last Name is required!"
        }

        return ""
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
    let fileURL = try fileURL(name: name)
    guard let data = try? Data(contentsOf: fileURL) else {
        throw APIError.networkError // YourErrorType.fileReadError // Reemplaza YourErrorType con el tipo de error que desees
    }

    do {
        let userData = try JSONDecoder().decode(T.self, from: data)
        return userData
    } catch {
        throw error // YourErrorType.jsonDecodingError // Reemplaza YourErrorType con el tipo de error que desees
    }
}

func saveFile<T: Codable>(userData: T, name: String) async throws {
    

    let data = try JSONEncoder().encode(userData)
    let outfile = try fileURL(name: name)
    try data.write(to: outfile)
}

func save2<T: Codable>(userData: T, name: String) async throws {
   
    let task = Task {
        let data = try JSONEncoder().encode(userData)
        let outfile = try fileURL(name: name)
        try data.write(to: outfile)
    }
    _ = try await task.value
}

/*
 func load<T: Codable>(name: String) async throws -> T {
     let task = Task<T, Error> {
         let fileURL = try fileURL(name: name)
         guard let data = try? Data(contentsOf: fileURL) else {
             return Data() as! T
         }
         let userData = try JSONDecoder().decode(T.self, from: data)
         return userData
     }
     print("load generic data")
     let userData = try await task.value
     //self.userData = userData
     /*
     let jsonData = try JSONEncoder().encode(userData)
     if let jsonString = String(data: jsonData, encoding: .utf8) {
         print("/n/n/....../n")
         print(jsonString)
         //return
     }
      */

     return userData
 }
 */
