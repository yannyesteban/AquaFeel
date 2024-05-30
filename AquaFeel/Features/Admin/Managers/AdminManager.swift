//
//  AdminManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/4/24.
//

import Foundation

class AdminManager: ObservableObject {
    var userId: String = ""
    var token: String = ""
    var role: String = ""

    @Published var allSellers: [User] = []

    @Published var user: User?

    func getUsers() async throws {
        print("/users/list-all-sellers token: ", token)

        let path = "/users/list-all-sellers"
        let params: [String: String?]? = nil
        let method = "GET"

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        do {
            let response: AllSellersResponse = try await fetching(config: info)

            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.allSellers = response.users.filter { $0.role != "ADMIN" } // response.users
                }
            } else {
                print("Error in list sellers")
            }

        } catch {
            throw error
        }
    }
}
