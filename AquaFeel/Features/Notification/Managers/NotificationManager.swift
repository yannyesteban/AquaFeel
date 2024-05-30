//
//  NotificationManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 21/5/24.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    var userId: String = ""
    var token: String = ""
    var role: String = ""

    @Published var notifications: [NotificationModel] = []

    
    static func removeAll() {
        print("removing all notifications!")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    static func start(userId: String, timeBefore: Int) async {
        
        
        
        guard let leads = try? await getLeads(userId: userId) else {
            print("no leads")
            return
        }

        NotificationManager.loadLeads(leads: leads, timeBefore: timeBefore)
    }

    static func loadLeads(leads: [LeadModel], timeBefore: Int) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let existingIdentifiers = Set(requests.map { $0.identifier })

            for lead in leads {
                if !existingIdentifiers.contains(lead.id) {
                    NotificationManager.scheduleNotification(for: lead, timeBefore: Double(timeBefore) * 60)
                }
            }
        }
    }

    static func scheduleNotification(for lead: LeadModel, timeBefore: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Lead for Today")
        content.body =  String(localized: "Appointment with: \(lead.first_name) \(lead.last_name)")
        content.sound = UNNotificationSound.default

        let dateFormatter: ISO8601DateFormatter = {
            // let formatter = DateFormatter()
            // formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Ajusta el formato según tus necesidades
            // formatter.locale = Locale(identifier: "en_US_POSIX")

            let isoDateFormatter = ISO8601DateFormatter()
            isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return isoDateFormatter
        }()

        guard lead.appointment_date != "",
              let appointmentDate = dateFormatter.date(from: lead.appointment_date) else {
            print("no valid date: \(lead.id)")
            return
        }

        // Calcular la fecha y hora de la notificación según la configuración
        let notificationDate = appointmentDate.addingTimeInterval(-timeBefore)

        print(lead.appointment_date, notificationDate)
        // Crear el trigger
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        // Crear la solicitud de notificación
        let request = UNNotificationRequest(identifier: lead.id, content: content, trigger: trigger)

        // Programar la notificación
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Notification for \(lead.first_name) \(lead.last_name)")
            }
        }
    }

    static func initialize(userId: String) async {
        let configs = await getNotifications(userId: userId)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for config in configs {
            if config.isActive {
                let content = UNMutableNotificationContent()
                content.title = config.name
                content.body = config.message
                content.sound = UNNotificationSound.default

                var trigger: UNNotificationTrigger?

                if config.type == .interval {
                    let interval: TimeInterval
                    switch config.unit {
                    case .hours:
                        interval = TimeInterval(config.interval * 3600)
                    case .minutes:
                        interval = TimeInterval(config.interval * 60)
                    case .days:
                        interval = TimeInterval(config.interval * 86400)
                    case .seconds:
                        if config.repeats && config.interval < 60 {
                            interval = TimeInterval(60)
                        } else {
                            interval = TimeInterval(config.interval)
                        }
                    }
                    trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: config.repeats)
                } else if config.type == .datetime || config.type == .time {
                    var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: config.datetime)

                    if config.type == .time {
                        print(config.datetime)
                        dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: config.datetime)
                    }

                    trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: config.repeats)
                }

                if let trigger = trigger {
                    let request = UNNotificationRequest(identifier: config.id, content: content, trigger: trigger)

                    do {
                        try await UNUserNotificationCenter.current().add(request)
                        print("Notification: \(config.id)")
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio"
        content.body = "Esta es una notificación de prueba."
        content.sound = UNNotificationSound.default

        // Configurar el trigger de la notificación
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

        // Crear la solicitud
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Agregar la solicitud al centro de notificaciones
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al programar la notificación: \(error.localizedDescription)")
            } else {
                print("Notificación programada")
            }
        }

        let center = UNUserNotificationCenter.current()
        Task {
            do {
                // Set the badge count to 3.
                try await center.setBadgeCount(3)
            } catch {
                // Handle any errors.
            }
        }
    }

    func load(userId: String) async throws {
        let q = LeadQuery().add(.userId, userId)
        let path = "/notifications/list"
        let params = q.get()
        let method = "GET"

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        do {
            let response: NotificationsResponse = try await fetching(config: info)

            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.notifications = response.list
                }
            } else {
                print("Error in list sellers")
            }

        } catch {
            print(error.localizedDescription)
            throw error
        }
    }

    static func dateDaysAfter(days: Int) -> Date? {
        // Get the current date
        let currentDate = Date()

        // Create a Gregorian calendar
        let calendar = Calendar(identifier: .gregorian)

        // Get the date 30 days before the current date
        if let dateMinus30Days = calendar.date(byAdding: .day, value: days, to: currentDate) {
            return dateMinus30Days
        } else {
            return nil
        }
    }

    static func getNotifications(userId: String) async -> [NotificationModel] {
        let q = LeadQuery().add(.userId, userId)
        let path = "/notifications/list"
        let params = q.get()
        let method = "GET"

        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: NotificationsResponse = try await fetching(config: info)

            if response.statusCode == 200 {
                return response.list
            }

        } catch {
            print(error.localizedDescription)
        }

        return []
    }

    static func getLeads(userId: String) async throws -> [LeadModel] {
        let q = LeadQuery()
            .add(.userId, userId)
            .add(.field, "appointment_date")
            .add(.offset, "0")
            .add(.limit, "1000")
            .add(.quickDate, "custom")
            .add(.fromDate, formatDateToString(Date()))
            .add(.toDate, formatDateToString(NotificationManager.dateDaysAfter(days: 30) ?? Date()))
            

        let path = "/leads/get"

        let params: [String: String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: "", params: params, port: APIValues.port)

        do {
            let response: LeadsRequest = try await fetching(config: info)

            return response.leads

        } catch {
            print("error")
        }

        return []
    }

    func save(body: NotificationModel, mode: RecordMode, completion: @escaping (Result<NotificationModel, Error>) -> Void) async {
        var path = ""
        var method = "POST"

        let q = LeadQuery().add(.id, body.id)

        switch mode {
        case .new:
            path = "/notifications/add"
        case .edit:
            path = "/notifications/edit"
        case .delete:
            path = "/notifications/delete"
            method = "DELETE"
        default:
            return
        }

        let params: [String: String?]? = q.get()
        // let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)

        do {
            let response: NotificationResponse = try await fetching(body: body, config: info)

            if response.statusCode == 201 {
                completion(.success(response.notification))

            } else if response.statusCode == 400 {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
            }

        } catch {
            completion(.failure(NSError(domain: "APIError", code: 400, userInfo: [NSLocalizedDescriptionKey: "API returned an error"])))
            // throw error
        }
    }
}
