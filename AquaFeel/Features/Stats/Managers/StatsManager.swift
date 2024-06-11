//
//  StatsManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/4/24.
//

import Foundation
import SwiftUI

struct StatsFilter: Codable {
    var selectedDateFilter: String = ""
    var selectedQuickDate: String = ""
    var fromDate: Date = .init()
    var toDate: Date = .init()
    var status: [String] = []
    var selectedOwner: [String] = []
}

struct StatsItemInfo: Identifiable, Equatable {
    let name: String
    let count: Int
    let color: Color
    var id: String { return name }
}

class StatsManager: ObservableObject {
    var profile: ProfileManager = ProfileManager()
    @Published var stats: [EmployeeStats] = []
    @Published var stats1: [StatsModel1] = []
    @Published var count: Int?
    @Published var leads: [LeadModel] = []
    @Published var filter = StatsFilter()
    @Published var statusCounts: [StatusType: Int] = [:]
    @Published var items: [StatsItemInfo] = []
    @Published var showAll = true
    var limit = 2000
    var offset = 0
    func setProfile(profile: ProfileManager) {
        self.profile = profile
    }

    func load() async throws {
        let q = LeadQuery()
            .add(.limit, "1000")
            .add(.offset, "0")

        let path = "/stats/list"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: profile.token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/stats/list", token: profile.token, params: q.get())

        DispatchQueue.main.async {
            self.count = nil
        }

        do {
            let response: EmployeeStatsResponse = try await fetching(config: info)
            DispatchQueue.main.async {
                self.stats = response.stats
                self.count = response.count
            }

        } catch {
            throw error
        }
    }
    
    func load1() async throws {
        let q = LeadQuery()
            .add(.limit, "1000")
            .add(.offset, "0")
        
        let path = "/stats/list2"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: profile.token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/stats/list", token: profile.token, params: q.get())
        
        DispatchQueue.main.async {
            self.count = nil
        }
        
        do {
            let response: StatsResponse = try await fetching(config: info)
            DispatchQueue.main.async {
                
                self.stats1 = response.data
                self.count = response.count
                
                
                //print(response.data)
                //print(response.data)
               
            }
            
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
    
    
    func list(query: LeadQuery? = nil, limit: Int = 2000, offset: Int = 0) async throws -> [LeadModel]{
        
        
        let q: LeadQuery
        
        if let _query = query {
            q = _query
        } else {
            q = LeadQuery()
        }
        _ = q
            .add(.offset, String(offset))
            .add(.limit, String(limit))
        
        
        
        if !filter.status.isEmpty {
            _ = q
                .add(.statusId, filter.status.map { $0 }.joined(separator: ","))
        }
        if !filter.selectedOwner.isEmpty {
            _ = q
                .add(.ownerId, filter.selectedOwner.joined(separator: ","))
        }
        
       
        var path = "/leads/get"
        
        if profile.role == "MANAGER" || profile.role == "ADMIN" {
            path = "/leads/list-all"
        } else {
            _ = q.add(.userId, profile.userId)
        }
        
        
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: profile.token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: path, token: profile.token, params: q.get())
        
        do {
            let response: LeadsRequest = try await fetching(config: info)
            // DispatchQueue.main.async {
            return response.leads
            
            // }
            
        } catch {
            throw error
        }
        
    }

    func list() async throws -> [LeadModel] {
        let q = LeadQuery()

        _ = q
            .add(.offset, String(offset))
            .add(.limit, String(limit))
            .add(.fromDate, filter.fromDate.formattedDate2())
            .add(.toDate, filter.toDate.formattedDate2())

            .add(.quickDate, TimeOption.custom.rawValue)
            .add(.field, DateFind.createOn.rawValue)

        if !filter.status.isEmpty {
            _ = q
                .add(.statusId, filter.status.map { $0 }.joined(separator: ","))
        }
        if !filter.selectedOwner.isEmpty {
            _ = q
                .add(.ownerId, filter.selectedOwner.joined(separator: ","))
        }
        
        print("TOKEN 2.0", profile.role, profile.userId)
        
        var path = "/leads/get"
        
        if profile.role == "MANAGER" || profile.role == "ADMIN" {
            path = "/leads/list-all"
        } else {
            _ = q.add(.userId, profile.userId)
        }
        
       
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: profile.token, params: params, port: APIValues.port)
        

        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: path, token: profile.token, params: q.get())

        do {
            let response: LeadsRequest = try await fetching(config: info)
            // DispatchQueue.main.async {
            return response.leads

            // }

        } catch {
            throw error
        }
    }

    func appointmentByDate() async -> [String : [LeadModel]]{
        
        let q = LeadQuery()
            .add(.fromDate, filter.fromDate.formattedDate2())
            .add(.toDate, filter.toDate.formattedDate2())
        
            .add(.quickDate, TimeOption.custom.rawValue)
            .add(.field, DateFind.appointmentDate.rawValue)
       
        
        let leads: [LeadModel] = try! await list(query: q, limit: 2000, offset: 0)
        
        let group: [String: [LeadModel]] = LeadModel.groupLeadsByDate(leads: leads)
        
        return group
    }
    
    func groupByStatus() async throws {
        var leads: [LeadModel] = []

        do {
            leads = try await list()

        } catch {
            throw error
        }

        DispatchQueue.main.async {
            self.statusCounts = [:]
            self.items = []
        }

        for lead in leads {
            DispatchQueue.main.async {
                let id = getStatusType(from: lead.status_id.name)

                if let count = self.statusCounts[id] {
                    self.statusCounts[id] = count + 1
                } else {
                    self.statusCounts[id] = 1
                }
            }
        }

        let allStatus: [StatusType] = [.uc, .ni, .ingl, .rent, .r, .appt, .demo, .win, .nho, .sm, .nm, .mycl, .r2]

        DispatchQueue.main.async {
            if self.showAll {
                for statusId in allStatus {
                    if let item = self.statusCounts[statusId] {
                        self.items.append(.init(name: statusId.rawValue.uppercased(), count: item, color: StatsManager.getColor(name: statusId.rawValue)))
                    } else {
                        self.items.append(.init(name: statusId.rawValue.uppercased(), count: 0, color: StatsManager.getColor(name: statusId.rawValue)))
                    }
                }
            } else {
                for (statusId, count) in self.statusCounts {
                    self.items.append(.init(name: statusId.rawValue.uppercased(), count: count, color: StatsManager.getColor(name: statusId.rawValue)))
                }
            }
        }
    }

    static func getColor(name: String) -> Color {
        let lowercaseStatus = name.lowercased()

        switch lowercaseStatus {
        case "uc":
            return ColorFromHex("#CC6F3F")
        case "ni":
            return .black
        case "ingl":
            return ColorFromHex("#CC96C6")
        case "rent":
            return ColorFromHex("#34499A")
        case "r":
            return ColorFromHex("#A3C100")
        case "appt":
            return ColorFromHex("#2BBBEB")
        case "demo":
            return ColorFromHex("#7E7F7F")
        case "win":
            return ColorFromHex("#0056A3")
        case "nho":
            return ColorFromHex("#FFE000")
        case "sm":
            return ColorFromHex("#6769AF")
        case "mycl":
            return ColorFromHex("#00ACD3")
        case "nm":
            return ColorFromHex("#00ff00")
        case "r2":
            return ColorFromHex("#00ffff")
        default:
            return ColorFromHex("#FFA500")
        }
    }
    
    func getDate(from dateString:String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
       
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return Date()
        }
        
        
    }
    
    
}
