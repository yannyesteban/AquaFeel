//
//  AppointmentManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/3/24.
//
import Combine
import Foundation
import SwiftUI

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

    @Published var dates: [Date] = []
    @Published var specialDates: [DateComponents] = []
    @Published var month: Date? 
    private var cancellables: Set<AnyCancellable> = []
    init(filterMode: LeadModeFilter = .all) {
        print("AppointmentManager init ")
        self.filterMode = filterMode
        
        $month
        
            .debounce(for: .seconds(0.0), scheduler: RunLoop.main)
            .sink { [weak self] date in
               
                if let date  {
                    
                    print("hello weak self 1.0", date)
                    self?.doTask(date: date)
                }
                
            }
            .store(in: &cancellables)
        
        
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

    func listByMonth(month: Int) {
        let calendar = Calendar.current
        // let components = calendar.dateComponents(
    }

    func listByMonth(myDate: Date) async throws -> [String: [LeadModel]]? {
       
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: myDate)
        guard let firstDateOfMonth = calendar.date(from: components) else {
            print("Error")
            return nil
        }

        guard let lastDateOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDateOfMonth) else {
            print("Error")
            return nil
        }

        let lastDateAdjusted = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDateOfMonth)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateStart = dateFormatter.string(from: firstDateOfMonth)
        let dateEnd = dateFormatter.string(from: lastDateAdjusted)

        print("Primer \(userId) día del mes:", dateStart, dateEnd)

        let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/get-by-month", token: "", params: nil)
        let body = AppointmentRequest(user_id: userId, date_start: dateStart, date_end: dateEnd)
        do {
            let response: LeadsRequest = try await fetching(body: body, config: info)
            // DispatchQueue.main.async {
            // self.leads = response.leads
            let groups = groupLeadsByDate(leads: response.leads)
            print("self.leads.count", response.leads.count)

            return groups
            // }

            // leads = response.leads

            // print(leads, "\n\n")
            // print(grpups)

        } catch {
            print("error", error.localizedDescription)
            throw error
        }
    }
    
    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    func listApp(myDate: Date) async throws -> [String: [LeadModel]]? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: myDate)
        guard let firstDateOfMonth = calendar.date(from: components) else {
            print("Error")
            return nil
        }
        
        guard let lastDateOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDateOfMonth) else {
            print("Error")
            return nil
        }
        
        let lastDateAdjusted = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDateOfMonth)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateStart = dateFormatter.string(from: firstDateOfMonth)
        let dateEnd = dateFormatter.string(from: lastDateAdjusted)
        
        
        
        
        let q = LeadQuery()
            .add(.userId, userId)
            .add(.field, "appointment_date")
            .add(.statusId, "613bb4e0d6113e00169fefa9")
            .add(.quickDate, "custom")
        
            .add(.fromDate, dateStart)
        
            .add(.toDate, dateEnd)
        // .add(.searchKey, "all")
            .add(.offset, "0")
            .add(.limit, "1000")
        // .add(.searchValue, "jose")
        
        
        
        print("Primer \(userId) día del mes:", dateStart, dateEnd)
        
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/get", token: "", params: q.get())
        //let body = AppointmentRequest(user_id: userId, date_start: dateStart, date_end: dateEnd)
        do {
            let response: LeadsRequest = try await fetching(config: info)
            // DispatchQueue.main.async {
            // self.leads = response.leads
            let groups = groupLeadsByDate(leads: response.leads)
            print("self.leads.count", response.leads.count)
            
            return groups
            // }
            
            // leads = response.leads
            
            // print(leads, "\n\n")
            // print(grpups)
            
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

                // print(dateString)

                // Agregar el registro al diccionario agrupado por la fecha (ignorando la hora)
                if var leadsForDate = groupedLeads[dateString] {
                    leadsForDate.append(lead)
                    groupedLeads[dateString] = leadsForDate
                } else {
                    groupedLeads[dateString] = [lead]
                }
            }
        }
        // print("\n\n", groupedLeads["2024-03-04"]?.count)
        return groupedLeads
    }

    func getDates(groups: [String: [LeadModel]]?) -> [DateComponents] {
        var dates: [DateComponents] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let groups {
            for (key, value) in groups {
                if let date = dateFormatter.date(from: key) {
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    dates.append(dateComponents)
                    // print("Key:", key, value.count)
                }
            }
        }

        return dates
    }
    
    
    func doTask(date:Date) {
        print("La variable month ha cambiado a \(date)")
        
        
        print("my last mes es ", date)
        Task {
            let values = try? await listApp(myDate: date)
            
            print("values?.count", values?.count)
            
            if let values {
                DispatchQueue.main.async {
                    self.specialDates = self.getDates(groups: values)
                }
            }
        }
    }
}

/*
 #Preview {
     CalendarView(profile: ProfileManager())
 }
 */
/*
 #Preview {
     AppointmentList(profile: ProfileManager(), showLeads: true, filterMode: .last30, userId: "")//DD2EMns3y"
 }
 */
