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
    let jsonData = """
        {
        "count": 13,
        "list": [
        {
            "isDisabled": false,
            "_id": "613bb202d6113e00169fef86",
            "name": "UC",
            "image": "uploads/1631343830004-UC.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb254d6113e00169fef89",
            "name": "NI",
            "image": "uploads/1631343845914-NI.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb38dd6113e00169fef9e",
            "name": "INGL",
            "image": "uploads/1631343865433-INGL.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb40bd6113e00169fefa3",
            "name": "RENT",
            "image": "uploads/1631343874770-RENT.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb468d6113e00169fefa6",
            "name": "R",
            "image": "uploads/1631343881420-R.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb4e0d6113e00169fefa9",
            "name": "APPT",
            "image": "uploads/1631343888314-APPT.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb535d6113e00169fefac",
            "name": "DEMO",
            "image": "uploads/1631343893634-DEMO.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb5e1d6113e00169fefaf",
            "name": "WIN",
            "image": "uploads/1631343901475-WIN.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb64ed6113e00169fefb2",
            "name": "NHO",
            "image": "uploads/1631343907583-NHO.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb6b3d6113e00169fefb5",
            "name": "SM",
            "image": "uploads/1631343921358-SM.png"
        },
        {
            "isDisabled": false,
            "_id": "613bb70ad6113e00169fefb8",
            "name": "MYCL",
            "image": "uploads/1631343929498-MYCL.png"
        },
        {
            "isDisabled": false,
            "_id": "644bf787cea03d0f64217f19",
            "name": "NM",
            "image": "uploads/1682700167965-NEL.png"
        },
        {
            "isDisabled": false,
            "_id": "644d2f65cea03d0f642199b5",
            "name": "R2",
            "image": "uploads/1682780005679-R2.png"
        }
        ]
        }
        """.data(using: .utf8)!
    
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
            do {
                // Decodificar el JSON a un array de StatusId
                let decodedStatusList = try JSONDecoder().decode(StatusResponse.self, from: jsonData)
                // Asignar el array decodificado a la lista statusList
                statusList = decodedStatusList.list
            } catch {
                print("Error decodificando JSON: \(error)")
            }
            
            //throw error
        }
    }
}
