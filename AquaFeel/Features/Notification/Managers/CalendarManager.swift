//
//  CalendarManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/5/24.
//

import Foundation
import EventKit

class CalendarManager: ObservableObject {
    
    static func start(userId: String) async {
        
        
        
        guard let leads = try? await NotificationManager.getLeads(userId: userId) else {
            print("no leads")
            return
        }
        
        addNewLeadsToCalendar(leads: leads)
    }
    
    static func addNewLeadsToCalendar(leads: [LeadModel]) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
        
        // Check if access to the calendar has been authorized
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized, .fullAccess:
            createEvents(for: leads, in: eventStore)
        case .notDetermined:
            // Request access to the calendar
            eventStore.requestAccess(to: .event) { granted, error in
                if granted {
                    self.createEvents(for: leads, in: eventStore)
                } else {
                    print("Calendar access not authorized: \(error?.localizedDescription ?? "")")
                }
            }
        case .denied, .restricted:
            print("Calendar access denied")
        
        case .writeOnly:
            print("Calendar access denied")
        @unknown default:
            print("Unhandled case")
        }
    }
    
    static func createEvents(for leads: [LeadModel], in eventStore: EKEventStore) {
        for lead in leads {
            guard !isEventExist(for: lead, in: eventStore) else {
                print("Event for the lead already exists in the calendar")
                continue
            }
            
            let event = EKEvent(eventStore: eventStore)
            event.title = "Appointment with \(lead.first_name) \(lead.last_name)"
            event.notes = "Appointment details: \(lead.street_address)"
            event.calendar = eventStore.defaultCalendarForNewEvents
            // Convert appointment date and time to a Date object
            
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
            
            //if let appointmentDate = dateFormatter.date(from: lead.appointmentDate) {
                event.startDate = appointmentDate
                event.endDate = appointmentDate.addingTimeInterval(3600) // Duration of one hour
            //}
            
            print("calendar: ", event.startDate, event.endDate)
            /*
            
            if let startDate = dateFormatter.date(from: "2024-05-25 10:00"),
               let endDate = dateFormatter.date(from: "2024-05-25 11:00") {
                addEventToCalendar(title: "Reunión con el Lead", startDate: startDate, endDate: endDate) { success, error in
                    if success {
                        print("Evento agregado al calendario")
                    } else {
                        if let error = error {
                            print("Error al agregar el evento: \(error)")
                        }
                    }
                }
            }
             */
            
            // Save the event to the calendar
            do {
              
                try eventStore.save(event, span: .thisEvent)
                print("Event saved to the calendar")
            } catch {
                print("Error saving event to calendar: \(error.localizedDescription)")
            }
        }
    }
    static func addEventToCalendar(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool, NSError?) -> Void) {
        let eventStore = EKEventStore()
        
        //let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                print("Permiso concedido ***")
            } else {
                print("Permiso denegado")
            }
        }
        
        eventStore.requestAccess(to: .event, completion: { granted, error in
            if granted && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    completion(true, nil)
                } catch let e as NSError {
                    completion(false, e)
                }
            } else {
                completion(false, error as NSError?)
            }
        })
    }
    static func isEventExist(for lead: LeadModel, in eventStore: EKEventStore) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: Date().addingTimeInterval(365 * 24 * 60 * 60), calendars: nil)
        let events = eventStore.events(matching: predicate)
        for event in events {
            if event.title == "Appointment with \(lead.first_name) \(lead.last_name)" {
                return true
            }
        }
        return false
    }
    
    
}
