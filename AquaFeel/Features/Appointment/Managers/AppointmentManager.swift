//
//  AppointmentManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/3/24.
//
import SwiftUI
import Combine
import Foundation

struct AppointmentRequest: Codable {
    var user_id: String
    var date_start: String
    var date_end: String
}

class AppointmentManager: ObservableObject {
    @Published var leads: [LeadModel] = []
    @Published var filterMode: LeadModeFilter = .all
    @Published var userId = ""
    @Published var showLeads: Bool = false

    @Published var selectedDate = Date()
    @Published var selectedMonth = Date()
    
    @Published var dates:[Date] = []
    
    init(filterMode: LeadModeFilter = .all) {
        print("AppointmentManager init ")
        self.filterMode = filterMode
        /* Task{
             try? await list()
         } */
    }

    func setFilter(filterMode: LeadModeFilter = .all) {
        self.filterMode = filterMode

        Task {
            try? await list()
        }
    }

    func list() async throws {
        print("AppointmentManager List ", filterMode)
        let q = LeadQuery()
            .add(.userId, userId)

        if filterMode == .today {
            _ = q.add(.today, "true")
        } else if filterMode == .last30 {
            _ = q.add(.lastMonth, "true")
        }

        var path = "/leads/appointments"

        if showLeads {
            path = "/leads/get"
        }
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: path, token: "", params: q.get())

        do {
            let response: LeadsRequest = try await fetching(config: info)

            leads = response.leads

        } catch {
            print("error", error.localizedDescription)
            throw error
        }
    }

    func listByMonth(myDate: Date) async throws{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: myDate)
        guard let firstDateOfMonth = calendar.date(from: components) else {
            print("Error")
            return
        }

        guard let lastDateOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDateOfMonth) else {
            print("Error")
            return
        }

        let lastDateAdjusted = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDateOfMonth)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        print("Primer día del mes:", dateFormatter.string(from: firstDateOfMonth))
        let dateStart = dateFormatter.string(from: firstDateOfMonth)
        let dateEnd = dateFormatter.string(from: lastDateAdjusted)
        
        
        
        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/get-by-month", token: "", params: nil)
        let body = AppointmentRequest(user_id: userId, date_start: dateStart, date_end: dateEnd)
        do {
            let response: LeadsRequest = try await fetching(body: body, config: info)
            
            leads = response.leads
            
            let grpups = groupLeadsByDate(leads: leads)
            //print(leads, "\n\n")
            //print(grpups)
            
        } catch {
            print("error", error.localizedDescription)
            throw error
        }
    }
    
    
    func groupLeadsByDate(leads: [LeadModel]) -> [String: [LeadModel]] {
        var groupedLeads = [String: [LeadModel]]()
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        for lead in leads {
            // Convertir la fecha a un formato de día
           
            if let date = isoDateFormatter.date(from: lead.appointment_date) {
                dates.append(date)
                let dateString = dateFormatter.string(from: date)
                
                // Agregar el registro al diccionario agrupado por la fecha (ignorando la hora)
                if var leadsForDate = groupedLeads[dateString] {
                    leadsForDate.append(lead)
                    groupedLeads[dateString] = leadsForDate
                } else {
                    groupedLeads[dateString] = [lead]
                }
            }
        }
        print("\n\n", groupedLeads)
        return groupedLeads
    }
}


#Preview {
    AppointmentList(showLeads: true, filterMode: .last30, userId: "xLv4wI2TM")//DD2EMns3y"
}
