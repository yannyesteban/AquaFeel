//
//  BrandManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import Foundation

struct BrandsResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int
    var data: [BrandModel]
}

struct BrandResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int?
    var data: BrandModel
    var message: String
}

class BrandManager: ObservableObject {
    @Published var brand: BrandModel!
    @Published var brands: [BrandModel] = []
    
    func createOrder(name: String) {
        brand = BrandModel(_id: UUID().uuidString, name: name)
    }
    
    func list(userId: String) async  {
        let q = LeadQuery().add(.userId, userId)
        let path = "/brands/list"
        let params = q.get()
        let method = "GET"
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        do {
            let response: BrandsResponseData = try await fetching(config: info)
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.brands = response.data
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
            path = "/brands/add"
        case .edit:
            path = "/brands/edit"
        case .delete:
            let q = LeadQuery().add(.id, brand._id)
            params = q.get()
            path = "/brands/delete"
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
            let response: BrandResponseData = try await fetching(body: brand, config: info)
            DispatchQueue.main.async {
                self.brand = response.data
            }
            
        } catch {
            throw error
        }
    }
}
