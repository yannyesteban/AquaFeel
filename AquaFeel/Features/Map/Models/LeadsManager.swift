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
        DispatchQueue.main.async {
            self.waiting = true
            self.updated = false
        }
        
        let leadsSelected = leads.filter { $0.isSelected }
        
        let ids: [String] = leadsSelected.map { $0.id }
        
        let body = BulkSeller(created_by: owner._id, ids: ids)
        
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/bulk-assign-seller", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            DispatchQueue.main.async {
                self.waiting = false
                
                if response.statusCode == 200 {
                    self.updated = true
                }
                print(response.statusCode ?? 0)
            }

        } catch {
            DispatchQueue.main.async {
                self.waiting = false
                
            }
            throw error
        }
    }

    func deleteBulk() async throws {
        
        DispatchQueue.main.async {
            self.waiting = true
            self.updated = false
        }
        
        let leadsSelected = leads.filter { $0.isSelected }
        
        let ids: [String] = leadsSelected.map { $0.id }
        
        let body = BulkDelete(leadIds: ids)
        
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/delete-bulk", token: token, params: nil)

        
        
        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            DispatchQueue.main.async {
                self.waiting = false
                print(response.statusCode ?? 0)
                if response.statusCode == 200 {
                    self.updated = true
                }
            }

        } catch {
            DispatchQueue.main.async {
                self.waiting = false
            }
            throw error
        }
    }

    func bulkStatusUpdate() async throws {
        DispatchQueue.main.async {
            self.waiting = true
            self.updated = false
        }
        let leadsSelected = leads.filter { $0.isSelected }
        
        let ids: [String] = leadsSelected.map { $0.id }
        
        let body = BulkStatus(status_id: statusId._id, ids: ids)
        print(statusId, ids)
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/bulk-status-update", token: token, params: nil)

        do {
            let response: BulkStatusResponse = try await fetching(body: body, config: info)
            DispatchQueue.main.async {
                self.waiting = false
                print(response.statusCode ?? 0)
                if response.statusCode == 200 {
                    self.updated = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.waiting = false
            }
            throw error
        }
    }
}
