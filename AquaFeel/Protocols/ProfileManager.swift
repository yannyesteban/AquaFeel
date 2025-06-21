//
//  LoginManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 20/1/24.
//

import CoreLocation
import Foundation
import SwiftUI

struct PasswordResponse: Codable, NeedStatusCode {
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
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case firstName
        case lastName
        case role
        case avatar
    }
}

struct ProfileLocation: Codable {
    let id: String
    let latitude: String
    let longitude: String
    var status: String = ""
}

struct ProfileStatus: Codable {
    let id: String
    var status: String = ""
}

struct ProfileLocationResponse: Codable, NeedStatusCode {
    let message: String
    let profile: Profile
    var statusCode: Int?
}

struct AllSellersResponse: Codable, NeedStatusCode {
    let users: [User]
    var statusCode: Int?
}

class ProfileManager: LoginProtocol, ObservableObject {
    @Published var leadFilters = LeadFilter()

    @Published var user: String = ""
    @Published var pass: String = ""
    @Published var auth: Bool = false
    @Published var begin: Bool = false
    @Published var isLoading = false

    @Published var error = false

    @Published var userId: String = "" // xLv4wI2TM - DD2EMns3y"
    @Published var token: String = ""
    @Published var role: String = "" // ADMIN   - SELLER"
    @Published var id: String = ""
    @Published var avatar: String = ""

    @Published var info: User = User()

    @Published var myTest: String = "myTest"

    @Published var waiting = false
    @Published var colorScheme: ColorScheme = .light

    @Published var schemeMode = SchemeMode.user
    @Published var language = AppLanguage.user
    @Published var mapApi = AppMapApi.googleMaps
    @Published var offline = false
    @Published var playBackground = false

    @Published var notifications = false
    @Published var timeBefore = 60
    @Published var useCalendar = false
    
    @Published var mapTheme = MapTheme.user
    @Published var maximumClusterZoom:UInt = 13
    @Published var minimumClusterSize:UInt = 10

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

        let path = "/auth/login"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/auth/login", token: token, params: nil)

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

        let path = "/users/details"
        let params: [String: String?]? = query.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/users/details", token: token, params: query.get())

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
                        var components = URLComponents()
                        components.scheme = APIValues.scheme
                        components.host = APIValues.host
                        components.path = "/uploads/" + avatar
                        components.port = APIValues.port
                        self.avatar = components.url?.absoluteString ?? ""
                        self.info.avatar = components.url?.absoluteString ?? ""

                        // print(self.info.avatar, components.url?.absoluteString)
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.error = true
                    self.auth = false
                    self.isLoading = false
                }
                print("error \(error)")
                throw error
            }
        }
    }

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

                self.schemeMode = self.store.schemeMode
                self.language = self.store.language
                self.mapApi = self.store.mapApi
                self.offline = self.store.offline
                self.playBackground = self.store.playBackground

                self.notifications = self.store.notifications
                self.timeBefore = self.store.timeBefore
                self.useCalendar = self.store.useCalendar
                self.avatar = self.store.info.avatar ?? ""
                
                
                self.mapTheme = self.store.mapTheme
                self.maximumClusterZoom = self.store.maximumClusterZoom
                self.minimumClusterSize = self.store.minimumClusterSize
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

            store.schemeMode = schemeMode
            store.language = language
            store.mapApi = mapApi
            store.offline = offline
            store.playBackground = playBackground

            store.notifications = notifications
            store.timeBefore = timeBefore
            store.useCalendar = useCalendar

            store.mapTheme = mapTheme
            store.maximumClusterZoom = maximumClusterZoom
            store.minimumClusterSize = minimumClusterSize
            
            
            
            try await saveFile(userData: store, name: "LoginStore1.data")
        } catch {
            print(error)
        }
    }

    func saveProfile() async throws {
        DispatchQueue.main.async {
            self.waiting = true
        }

        let path = "/profile/edit"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let apiInfo = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let apiInfo = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/profile/edit", token: token, params: nil)

        // let info = ApiConfig(scheme: "http", method: method, host: "127.0.0.1", path: path, token: token, params: nil, port : "4000")

        do {
            let _: ProfileResponse = try await fetching(body: info, config: apiInfo)

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

    func setStatus() async throws {
        let body = ProfileStatus(id: userId, status: "connected")

        let path = "/profile/set-status"
        let params: [String: String?]? = nil
        let method = "PUT"
        let scheme = APIValues.scheme
        let apiInfo = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let apiInfo = ApiConfig(method: "PUT", host: "api.aquafeelvirginia.com", path: "/profile/set-location", token: token, params: nil)

        do {
            let response: ProfileLocationResponse = try await fetching(body: body, config: apiInfo)

            if response.statusCode == 201 {
                DispatchQueue.main.async {
                    self.waiting = false
                }
            } else {
                print("Error in set the localization")
            }

        } catch {
            throw error
        }
    }

    func setLocation(position: CLLocationCoordinate2D) async throws {
        let body = ProfileLocation(id: userId, latitude: String(position.latitude), longitude: String(position.longitude))

        let path = "/profile/set-location"
        let params: [String: String?]? = nil
        let method = "PUT"
        let scheme = APIValues.scheme
        let apiInfo = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let apiInfo = ApiConfig(method: "PUT", host: "api.aquafeelvirginia.com", path: "/profile/set-location", token: token, params: nil)

        do {
            let response: ProfileLocationResponse = try await fetching(body: body, config: apiInfo)

            if response.statusCode == 201 {
               
                DispatchQueue.main.async {
                    self.waiting = false
                }
            } else {
                print("Error in set the localization")
            }

        } catch {
            throw error
        }
    }

    func changePassword(email: String, oldPassword: String, newPassword: String) async throws -> PasswordResponse {
        DispatchQueue.main.async {
            self.waiting = true
        }
        let body = PasswordModel(email: email, oldPassword: oldPassword, newPassword: newPassword)

        let path = "/auth/changePassword"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let apiInfo = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let apiInfo = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/auth/changePassword", token: token, params: nil)

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

    func uploadAvatar(image: UIImage) {
        guard let url = URL(string: "\(APIValues.scheme)://\(APIValues.host):\(APIValues.port)/profile/upload-avatar") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.8)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: data) { responseData, _, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }

            guard let responseData = responseData else {
                print("No data received in response")
                return
            }

            let decoder = JSONDecoder()
            do {
                let object = try decoder.decode(ProfileResponse.self, from: responseData)
                if let avatar = object.profile.avatar {
                    DispatchQueue.main.async {
                        var components = URLComponents()
                        components.scheme = APIValues.scheme
                        components.host = APIValues.host
                        components.path = "/uploads/" + avatar
                        components.port = APIValues.port

                        self.info.avatar = components.url?.absoluteString ?? ""
                        self.avatar = components.url?.absoluteString ?? ""
                    }
                }

            } catch {
                print(error.localizedDescription)
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                print("Response JSON: \(jsonResponse)")
            }
        }.resume()
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
        /*
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
         */
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
