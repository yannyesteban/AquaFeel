//
//  LeadsManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 20/3/24.
//

import Foundation

struct BulkStatus: Codable {
    let status_id: String
    let ids: [String]
}

struct BulkSeller: Codable {
    let created_by: String
    let ids: [String]
}

struct BulkDelete: Codable {
    let leadIds: [String]
}

struct BulkStatusResponse: Codable, NeedStatusCode {
    var statusCode: Int?
    var message: String?
}

actor LeadsManager1: ObservableObject { // Ahora es thread-safe
    @MainActor @Published var leads: [LeadModel] = []
    // Resto de propiedades...
}

@MainActor
class LeadsManager: ObservableObject {
    @Published var leads: [LeadModel] = []
    @Published var statusId = StatusId()
    @Published var leadFilter = LeadFilter()
    @Published var userId: String = ""
    @Published var owner = CreatorModel()
    @Published var token: String = ""
    @Published var role: String = ""
    @Published var waiting = false
    @Published var updated = false

    func bulkAssignToSeller() async throws {
        // DispatchQueue.main.async {
        waiting = true
        updated = false
        // }

        let leadsSelected = leads.filter { $0.isSelected }

        let ids: [String] = leadsSelected.map { $0.id }

        let body = BulkSeller(created_by: owner._id, ids: ids)

        let path = "/leads/bulk-assign-seller"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/bulk-assign-seller", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)

            waiting = false

            if response.statusCode == 200 {
                updated = true
            }
            print(response.statusCode ?? 0)

        } catch {
            waiting = false
            throw error
        }
    }

    func deleteBulk() async throws {
        waiting = true
        updated = false

        let leadsSelected = leads.filter { $0.isSelected }

        let ids: [String] = leadsSelected.map { $0.id }

        let body = BulkDelete(leadIds: ids)

        let path = "/leads/delete-bulk"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/delete-bulk", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            waiting = false
            if response.statusCode == 200 {
                updated = true
            }
            print(response.statusCode ?? 0)

        } catch {
            waiting = false
            throw error
        }
    }

    func bulkStatusUpdate() async throws {
        waiting = true
        //updated = false
        let leadsSelected = leads.filter { $0.isSelected }

        let ids: [String] = leadsSelected.map { $0.id }

        let body = BulkStatus(status_id: statusId._id, ids: ids)

        let path = "/leads/bulk-status-update"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/bulk-status-update", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            DispatchQueue.main.async {
                self.waiting = false
                if response.statusCode == 200 {
                    self.updated = true
                }
            }
           
            print("response.statusCode ?? 0", response.statusCode ?? 0)
        } catch {
            waiting = false
            throw error
        }
    }
}
