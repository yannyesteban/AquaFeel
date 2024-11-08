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
        
        let userData = try await task.value
        self.userData = userData
    }
    
    func save(userData: UserData) async throws {
        
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
class MainStore<T: SimplyInitializable & Codable>: ObservableObject {
    @Published var userData: T = T()
    @Published var auth = Authentication()
    @Published var id = ""
    @Published var user = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var role = ""
    @Published var token = ""
    @Published var avatar = ""
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
       
        let userData = try await task.value
        self.userData = userData
        
       
    }
    
    func save(userData: T) async throws {
        
        let task = Task {
            let data = try JSONEncoder().encode(userData)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
