//
//  AppStore.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation
@MainActor
class AppStore: ObservableObject {
    @Published var userData: UserData = UserData()
    @Published var auth = Authentication()
    
    //@Published var user = LoginModelViewVM()
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("AquaFeel.data")
    }
    
    func load() async throws {
        let task = Task<UserData, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return UserData()
            }
            let userData = try JSONDecoder().decode(UserData.self, from: data)
            return userData
        }
        print("load user data")
        let userData = try await task.value
        self.userData = userData
    }
    
    func save(userData: UserData) async throws {
        print("save user data...")
        print(userData)
        let task = Task {
            let data = try JSONEncoder().encode(userData)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}

protocol SimplyInitializable {
    init()
}




@MainActor
class MainStore<T: SimplyInitializable & Identifiable & Codable>: ObservableObject {
    @Published var userData: T = T()
    @Published var auth = Authentication()
    @Published var user = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var test = "one"
    
    //@Published var user = LoginModelViewVM()
    
    
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("AquaFeel.data")
    }
    
    func load() async throws {
        let task = Task<T, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return T()
            }
            let userData = try JSONDecoder().decode(T.self, from: data)
            return userData
        }
        print("load generic data")
        let userData = try await task.value
        self.userData = userData
        
        let jsonData = try JSONEncoder().encode(userData)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("/n/n/....../n")
            print(jsonString)
            //return
        }
    }
    
    func save(userData: T) async throws {
        print("save generic data...")
        print(userData)
        let task = Task {
            let data = try JSONEncoder().encode(userData)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
