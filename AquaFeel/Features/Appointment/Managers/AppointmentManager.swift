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

func date30DaysBefore() -> Date? {
    // Get the current date
    let currentDate = Date()

    // Create a Gregorian calendar
    let calendar = Calendar(identifier: .gregorian)

    // Get the date 30 days before the current date
    if let dateMinus30Days = calendar.date(byAdding: .day, value: -30, to: currentDate) {
        return dateMinus30Days
    } else {
        return nil
    }
}

class AppointmentManager: ObservableObject {
    @Published var leads: [LeadModel] = []
    @Published var filterMode: LeadModeFilter = .all
    @Published var userId = ""
    @Published var showLeads: Bool = false

    @Published var selectedDate = Date()
    @Published var selectedMonth = Date()

    @Published var specialDates: [DateComponents] = []
    @Published var month: Date?
    @Published var groups: [String: [LeadModel]] = [:]
    private var cancellables: Set<AnyCancellable> = []
    init(filterMode: LeadModeFilter = .all) {
        self.filterMode = filterMode

        $month

            .debounce(for: .seconds(0.0), scheduler: RunLoop.main)
            .sink { [weak self] date in

                if let date {
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
        let q = LeadQuery()
            .add(.userId, userId)
            .add(.field, showLeads ? "created_on" : "appointment_date")
            .add(.offset, "0")
            .add(.limit, "1000")
        // .add(.quickDate, "custom")

        if filterMode == .today {
            _ = q.add(.quickDate, "custom")

                .add(.fromDate, formatDateToString2(getFromDate()))
                .add(.toDate, formatDateToString2(getToDate()))
        } else if filterMode == .last30 {
            _ = q.add(.quickDate, "custom")

                .add(.fromDate, formatDateToString(date30DaysBefore() ?? Date()))
                .add(.toDate, formatDateToString(Date()))
        } else if filterMode == .favorite {
            _ = q.add(.favorite, "true")
                .add(.field, "")
        }

        let path = "/leads/get2"

        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: path, token: "", params: q.get())

        do {
            let response: LeadsRequest = try await fetching(config: info)

            DispatchQueue.main.async {
                self.leads = response.leads
            }

        } catch {
            throw error
        }
    }

    func getFromDate() -> Date {
        let currentDate = Date()

        // Crear un calendario gregoriano
        let calendar = Calendar.current

        // Obtener los componentes de la fecha actual
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)

        // Establecer la hora a las 12:00
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0

        // Crear la fecha de inicio con la hora establecida a las 12:00
        guard let fromDate = calendar.date(from: dateComponents) else {
            fatalError("No se pudo crear la fecha de inicio")
        }

        return fromDate
    }

    func getToDate() -> Date {
        let currentDate = Date()

        let calendar = Calendar(identifier: .gregorian)

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)

        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59

        guard let toDate = calendar.date(from: dateComponents) else {
            fatalError("No se pudo crear la fecha de inicio")
        }

        return toDate
    }

    func listOLD() async throws {
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

        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: path, token: "", params: q.get())

        do {
            let response: LeadsRequest = try await fetching(config: info)

            DispatchQueue.main.async {
                self.leads = response.leads
            }

        } catch {
            throw error
        }
    }

    func listByMonth(myDate: Date) async throws -> [String: [LeadModel]]? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: myDate)
        guard let firstDateOfMonth = calendar.date(from: components) else {
            return nil
        }

        guard let lastDateOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDateOfMonth) else {
            return nil
        }

        let lastDateAdjusted = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDateOfMonth)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateStart = dateFormatter.string(from: firstDateOfMonth)
        let dateEnd = dateFormatter.string(from: lastDateAdjusted)

        let path = "/leads/get-by-month"
        let params: [String: String?]? = nil
        let method = "POST"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        // let info = ApiConfig(method: "POST", host: "api.aquafeelvirginia.com", path: "/leads/get-by-month", token: "", params: nil)
        let body = AppointmentRequest(user_id: userId, date_start: dateStart, date_end: dateEnd)
        do {
            let response: LeadsRequest = try await fetching(body: body, config: info)
            let groups = groupLeadsByDate(leads: response.leads)

            return groups

        } catch {
            throw error
        }
    }

    func formatDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    func formatDateToString2(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Para asegurar que el formato sea en inglés (USA) y no afecte a las conversiones
        return dateFormatter.string(from: date)
    }

    func listApp(myDate: Date) async throws -> [String: [LeadModel]]? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: myDate)
        guard let firstDateOfMonth = calendar.date(from: components) else {
            return nil
        }

        guard let lastDateOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDateOfMonth) else {
            return nil
        }

        let lastDateAdjusted = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: lastDateOfMonth)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dateStart = formatDateToString2(firstDateOfMonth) // dateFormatter.string(from: firstDateOfMonth)
        let dateEnd = formatDateToString2(lastDateAdjusted) // dateFormatter.string(from: lastDateAdjusted)

        let q = LeadQuery()
            .add(.userId, userId)
            .add(.field, "appointment_date")
            // .add(.statusId, "613bb4e0d6113e00169fefa9")
            .add(.quickDate, "custom")

            .add(.fromDate, dateStart)

            .add(.toDate, dateEnd)
            // .add(.searchKey, "all")
            .add(.offset, "0")
            .add(.limit, "1000")
        // .add(.searchValue, "jose")

        let path = "/leads/get"
        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        // let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/leads/get", token: "", params: q.get())

        do {
            let response: LeadsRequest = try await fetching(config: info)
            let groups = groupLeadsByDate(leads: response.leads)

            return groups

        } catch {
            throw error
        }
    }

    func groupLeadsByDate(leads: [LeadModel]) -> [String: [LeadModel]] {
        var groupedLeads = [String: [LeadModel]]()

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"

        // var isoDateFormatter = DateFormatter()
        // isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        // isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        // isoDateFormatter.locale = Locale(identifier: "en_US_POSIX") // Para asegurar que el formato sea en inglés (USA) y no afecte a las conversiones

        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for lead in leads {
            if let date = isoDateFormatter.date(from: lead.appointment_date) {
                let dateString = dateFormatter.string(from: date)
                if var leadsForDate = groupedLeads[dateString] {
                    leadsForDate.append(lead)
                    groupedLeads[dateString] = leadsForDate
                } else {
                    groupedLeads[dateString] = [lead]
                }
            }
        }

        return groupedLeads
    }

    func getDates(groups: [String: [LeadModel]]?) -> [DateComponents] {
        var dates: [DateComponents] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let groups {
            for (key, _) in groups {
                if let date = dateFormatter.date(from: key) {
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
                    dates.append(dateComponents)
                }
            }
        }

        return dates
    }

    func doTask(date: Date) {
        Task {
            let values = try? await listApp(myDate: date)

            if let values {
                DispatchQueue.main.async {
                    self.groups = values
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
