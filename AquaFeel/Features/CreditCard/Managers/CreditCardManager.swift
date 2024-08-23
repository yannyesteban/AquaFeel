//
//  CreditCardManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/8/24.
//

import Foundation

struct CreditCardsResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int
    var data: [CreditCardModel]
}

struct CreditCardResponseData: Codable, NeedStatusCode {
    var statusCode: Int?
    var count: Int?
    var data: CreditCardModel
    var message: String
}

class CreditCardManager: ObservableObject {
    @Published var creditCard: CreditCardModel!
    @Published var creditCards: [CreditCardModel] = []

    func list(userId: String) async -> [NotificationModel] {
        let q = LeadQuery().add(.userId, userId)
        let path = "/creditcard/list"
        let params = q.get()
        let method = "GET"

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: CreditCardsResponseData = try await fetching(config: info)

            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.creditCards = response.data
                }
            }

        } catch {
            print(1247)
            print(error.localizedDescription)
        }

        return []
    }

    func details(leadId: String) async -> CreditCardModel {
        let q = LeadQuery().add(.leadId, leadId)
        let path = "/creditcard/details"
        let params = q.get()
        let method = "GET"

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: CreditCardResponseData = try await fetching(config: info)

            if response.statusCode == 200 {
                return response.data
            }

        } catch {
            DispatchQueue.main.async {
                self.creditCard = CreditCardModel()
            }
        }

        return CreditCardModel()
    }

    func save(mode: RecordMode) async throws {
        var params: [String: String?]?

        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/creditcard/add"
        case .edit:
            path = "/creditcard/edit"
        case .delete:
            let q = LeadQuery().add(.id, creditCard._id)
            params = q.get()
            path = "/creditcard/delete"
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
            let response: CreditCardResponseData = try await fetching(body: creditCard, config: info)
            DispatchQueue.main.async {
                self.creditCard = response.data
            }

        } catch {
            throw error
        }
    }
}
