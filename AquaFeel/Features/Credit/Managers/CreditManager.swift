//
//  CreditManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/7/24.
//

import Foundation

struct CreditsResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int
    var data: [CreditModel]
}

struct CreditResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int?
    var data: CreditModel
    var message: String
}

class CreditManager: ObservableObject {
    @Published var credit: CreditModel!
    @Published var credits: [CreditModel] = []
    
    
    
    func list(userId: String) async -> [NotificationModel] {
        let q = LeadQuery().add(.userId, userId)
        let path = "/credit/list"
        let params = q.get()
        let method = "GET"
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        do {
            let response: CreditsResponseData = try await fetching(config: info)
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.credits = response.data
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func details(leadId: String) async -> CreditModel{
        let q = LeadQuery().add(.leadId, leadId)
        let path = "/credit/details"
        let params = q.get()
        let method = "GET"
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        do {
            let response: CreditResponseData = try await fetching(config: info)
            
            if response.statusCode == 200 {
                return response.data
                //DispatchQueue.main.async {
                //self.order = response.data
                //}
            } else {
                /*DispatchQueue.main.async {
                 self.order = OrderModel()
                 print("ONE")
                 }*/
            }
            
        } catch {
            DispatchQueue.main.async {
                self.credit = CreditModel()
                print("Two")
            }
            
            print(error.localizedDescription)
        }
        
        return CreditModel()
    }
    
    func save(mode: RecordMode) async throws {
        var params: [String: String?]?
        
        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/credit/add"
        case .edit:
            path = "/credit/edit"
        case .delete:
            let q = LeadQuery().add(.id, credit._id)
            params = q.get()
            path = "/credit/delete"
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
            let response: CreditResponseData = try await fetching(body: credit, config: info)
            DispatchQueue.main.async {
                self.credit = response.data
            }
            
        } catch {
            throw error
        }
    }
}
