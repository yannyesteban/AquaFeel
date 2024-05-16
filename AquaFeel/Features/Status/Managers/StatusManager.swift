//
//  StatusManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/5/24.
//

import Foundation

class StatusManager: ObservableObject {
    @Published var statusList: [StatusId] = []
    @Published var lastStatus: StatusId?
    @Published var lastStatusType: StatusType?
    
    init() {
        Task {
            try? await list()
        }
    }
    
    func statusAll() {
        
        let path = "/status/list"
        let params: [String : String?]? = nil
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        
        Task {
            do {
                let response: StatusResponse = try await fetching(config: info)
                DispatchQueue.main.async {
                    self.statusList = response.list
                   
                }
                
            } catch {
                print("status list error")
                
            }
        }
        
        
        
    }
    
    func list() async throws {
        
        let path = "/status/list"
        let params: [String : String?]? = nil
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/status/list", token: "", params: nil)
        
        do {
            let response: StatusResponse = try await fetching(config: info)
            DispatchQueue.main.async {
                self.statusList = response.list
            }
            
        } catch {
            throw error
        }
    }
}
