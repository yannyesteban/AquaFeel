//
//  ModelManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import Foundation

struct ModelsResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int
    var data: [ModelModel]
}

struct ModelResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int?
    var data: ModelModel
    var message: String
}

class ModelManager: ObservableObject {
    @Published var model: ModelModel!
    @Published var models: [ModelModel] = []
    
    func createOrder(name: String) {
        model = ModelModel(_id: UUID().uuidString, name: name)
    }
    
    func list(userId: String) async  {
        let q = LeadQuery().add(.userId, userId)
        let path = "/models/list"
        let params = q.get()
        let method = "GET"
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        do {
            let response: ModelsResponseData = try await fetching(config: info)
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.models = response.data
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    func save(mode: RecordMode) async throws {
        var params: [String: String?]?
        
        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/models/add"
        case .edit:
            path = "/models/edit"
        case .delete:
            let q = LeadQuery().add(.id, model._id)
            params = q.get()
            path = "/models/delete"
            method = "DELETE"
        default:
            return
        }
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        /*
         do {
         let jsonData = try JSONEncoder().encode(order)
         if let jsonString = String(data: jsonData, encoding: .utf8) {
         print(jsonString)
         }
         }*/
        do {
            let response: ModelResponseData = try await fetching(body: model, config: info)
            DispatchQueue.main.async {
                self.model = response.data
            }
            
        } catch {
            throw error
        }
    }
}
