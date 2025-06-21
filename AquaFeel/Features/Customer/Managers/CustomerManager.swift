//
//  CustomerManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/10/24.
//

import Foundation

struct CustomersResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int
    var data: [CustomerModel]
}

struct CustomerResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    //var count: Int?
    var newCustomer: CustomerModel
    var message: String
}

class CustomertManager: ObservableObject {
    @Published var customer: CustomerModel!
    
    
    
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
              
                 }*/
            }
            
        } catch {
            DispatchQueue.main.async {
                self.credit = CreditModel()
               
            }
            
            print(error.localizedDescription)
        }
        
        return CreditModel()
    }
    
    func save(customer: CustomerModel, mode: RecordMode) async throws {
        //"mongodb://pepe2:12345678@localhost:27017/aquasoft?retryWrites=true&w=majority",//mongodb://pepe:12345678@localhost:27017/aquasoft
        let host = "localhost"
        let scheme = "http"
        let port = 8000
        
        var params: [String: String?]?
        
        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/api/customer/65a93f9bab93f0f3ac2cf6eb"
        case .edit:
            path = "/api/customer/" +  (customer.firstName ?? "")
        case .delete:
            let q = LeadQuery().add(.id, credit._id)
            params = q.get()
            path = "/credit/delete"
            method = "DELETE"
        default:
            return
        }
        
        
        
        //let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: host, path: path, token: "", params: params, port: port)
        /*
         do {
         let jsonData = try JSONEncoder().encode(order)
         if let jsonString = String(data: jsonData, encoding: .utf8) {
         print(jsonString)
         }
         }*/
        do {
            let response: CustomerResponseData = try await fetching(body: customer, config: info)
            DispatchQueue.main.async {
                self.customer = response.newCustomer
            }
            
        } catch {
            throw error
        }
    }
}
