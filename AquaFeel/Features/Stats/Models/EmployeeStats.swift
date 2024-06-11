//
//  EmployeeStats.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/4/24.
//

import Foundation
import SwiftUI

struct ChartData: Identifiable, Equatable {
    let name: String
    let count: Int
    let color: Color
    var id: String { return name }
}

struct EmployeeStatsResponse: Codable, NeedStatusCode {
    let stats: [EmployeeStats]
    let count: Int

    var statusCode: Int?
}

struct Stats1: Codable {
    let name: String
    let count: Int
}

struct StatsResponse: Codable, NeedStatusCode {
    let data: [StatsModel1]
    let count: Int

    var statusCode: Int?
}

struct StatsModel1: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let role: String
    let createdAt: String
    let updatedAt: String
    let stats: [Stats1]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case role
        case createdAt
        case updatedAt
        case stats
    }

    var orderedStats: [Stats1] {
        let allStatus: [StatusType] = [.uc, .ni, .ingl, .rent, .r, .appt, .demo, .win, .nho, .sm, .nm, .mycl, .r2]

        let statsDict = Dictionary(uniqueKeysWithValues: stats.map { ($0.name, $0.count) })
        return allStatus.map { status in
            Stats1(name: status.rawValue, count: statsDict[status.rawValue.uppercased()] ?? 0)
        }
    }
    
    var totalCount: Int {
        return stats.reduce(0) { $0 + $1.count }
    }
}

struct EmployeeStats: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let role: String
    let createdAt: String
    let updatedAt: String
    let stats: Stats

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case role
        case createdAt
        case updatedAt
        case stats
    }
}

struct Stats: Codable {
    let UCCount: Int
    let NICount: Int
    let INSTCount: Int
    let INGLCount: Int
    let RENTCount: Int
    let RCount: Int
    let APPTCount: Int
    let DEMOCount: Int
    let WINCount: Int
    let NHOCount: Int
    let SMCount: Int
    let MYCLCount: Int

    var list: [String: Int] {
        var data: [String: Int] = [:]

        data["UC"] = UCCount
        data["NI"] = NICount
        // data["INST"] = INSTCount
        data["INGL"] = INGLCount

        data["RENT"] = RENTCount
        data["R"] = RCount
        data["APPT"] = APPTCount
        data["DEMO"] = DEMOCount

        data["WIN"] = WINCount
        data["NHO"] = NHOCount
        data["SM"] = SMCount
        data["MYCL"] = MYCLCount

        return data
    }

    var chart: [ChartData] {
        var data: [ChartData] = []

        data.append(ChartData(name: "UC", count: UCCount, color: ColorFromHex("#CC6F3F")))
        data.append(ChartData(name: "NI", count: NICount, color: .black))
        // data.append(ChartData(name: "INST", count: INSTCount, color: ColorFromHex("#CC6F3F")))
        data.append(ChartData(name: "INGL", count: INGLCount, color: ColorFromHex("#CC96C6")))

        data.append(ChartData(name: "RENT", count: RENTCount, color: ColorFromHex("#34499A")))
        data.append(ChartData(name: "R", count: RCount, color: ColorFromHex("#A3C100")))
        data.append(ChartData(name: "APPT", count: APPTCount, color: ColorFromHex("#2BBBEB")))
        data.append(ChartData(name: "DEMO", count: DEMOCount, color: ColorFromHex("#7E7F7F")))

        data.append(ChartData(name: "WIN", count: WINCount, color: ColorFromHex("#0056A3")))
        data.append(ChartData(name: "NHO", count: NHOCount, color: ColorFromHex("#FFE000")))
        data.append(ChartData(name: "SM", count: SMCount, color: ColorFromHex("#6769AF")))
        data.append(ChartData(name: "MYCL", count: MYCLCount, color: ColorFromHex("#00ACD3")))

        return data
    }

    enum CodingKeys: String, CodingKey {
        case UCCount = "UC_count"
        case NICount = "NI_count"
        case INSTCount = "INST_count"
        case INGLCount = "INGL_count"
        case RENTCount = "RENT_count"
        case RCount = "R_count"
        case APPTCount = "APPT_count"
        case DEMOCount = "DEMO_count"
        case WINCount = "WIN_count"
        case NHOCount = "NHO_count"
        case SMCount = "SM_count"
        case MYCLCount = "MYCL_count"
    }
}
