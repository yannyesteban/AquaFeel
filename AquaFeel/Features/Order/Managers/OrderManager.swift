//
//  OrderManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/6/24.
//

/*
 This contract is valid only with the signed approval of the employee management staff at Aquafeel Solutions head office.
 */

import Foundation

struct OrdersResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int
    var data: [OrderModel]
}

struct OrderResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int?
    var data: OrderModel
    var message: String
}

class OrderManager: ObservableObject {
    @Published var order: OrderModel!
    @Published var orders: [OrderModel] = []
    
    func createOrder(buyer1: BuyerModel, buyer2: BuyerModel, address: String, city: String, state: String, zip: String, system1: SystemModel, system2: SystemModel, promotion: String, installation: InstallModel, people: Int, creditCard: Bool, check: Bool, price: PriceModel) {
        order = OrderModel(id: UUID().uuidString, buyer1: buyer1, buyer2: buyer2, address: address, city: city, state: state, zip: zip, system1: system1, system2: system2, promotion: promotion, installation: installation, people: people, creditCard: creditCard, check: check, price: price)
    }

    func list(userId: String) async -> [NotificationModel] {
        let q = LeadQuery().add(.userId, userId)
        let path = "/orders/list"
        let params = q.get()
        let method = "GET"

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: OrdersResponseData = try await fetching(config: info)

            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.orders = response.data
                }
            }

        } catch {
            print(error.localizedDescription)
        }

        return []
    }
    
    func details(leadId: String) async -> OrderModel{
        let q = LeadQuery().add(.leadId, leadId)
        let path = "/orders/details"
        let params = q.get()
        let method = "GET"
        
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)
        
        do {
            let response: OrderResponseData = try await fetching(config: info)
            
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
                self.order = OrderModel()
               
            }
            
            print(error.localizedDescription)
        }
        
        return OrderModel()
    }

    func save(mode: RecordMode) async throws {
        var params: [String: String?]?

        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/orders/add"
        case .edit:
            path = "/orders/edit"
        case .delete:
            let q = LeadQuery().add(.id, order._id)
            params = q.get()
            path = "/orders/delete"
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
            let response: OrderResponseData = try await fetching(body: order, config: info)
            DispatchQueue.main.async {
                self.order = response.data
            }

        } catch {
            throw error
        }
    }
}
