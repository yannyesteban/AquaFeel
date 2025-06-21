//
//  HomeScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

import CoreLocation
import EventKit
import SwiftUI
import UserNotifications

extension Date {
    func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
}

struct DayIconView: View {
    let date: Date

    var body: some View {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        RoundedRectangle(cornerRadius: 10)
            .frame(width: 36, height: 36)
            .foregroundColor(Color.blue) // Cambia el color según tu preferencia
            .overlay(
                Text("\(day)")
                    .foregroundColor(.white)
                    .font(.headline)
            )
    }
}

struct HomeScreen: View {
    var profile: ProfileManager
    // @EnvironmentObject var store: MainStore<UserData>

    @State public var showOption: Bool = false

    @State var lead: LeadModel = LeadModel()

    @State private var date = Date()
    @State private var isDateSelected = false
    // @State private var selectedDate = Date()

    //@StateObject var manager = LeadManager(autoLoad: true, limit: 2000, maxLoads: 2000)
    @StateObject var manager = LeadManager(autoLoad: false, limit: 2000, maxLoads: 3000)

    // @State var manager = LeadManager()
    var placeManager = PlaceManager()

    @State var startLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @State private var selectedIdentifier: Calendar.Identifier = .gregorian
    @State private var lastSelectedDate: Date?
    @State private var selectedDate2: Date?
    // @State private var myTest = "0"
    @State private var updated = false
    @State private var updated2 = false

    @StateObject var traceManager = TraceManager()

    @State private var lastPick: String? = nil
    var body: some View {
        NavigationStack {
            Form {
                // Text("Role: \(profile.role)")
                // Text("User: \(profile.userId)")

                HStack {
                    Text("Appointments")

                    if lastPick != nil {
                        Text("of")
                        Text(shortDate(lastSelectedDate ?? Date()))
                            .bold()
                        Spacer()
                        Button(action: {
                            self.lastPick = nil
                        }) {
                            Text("Hide")
                                .foregroundColor(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(5)
                        }
                    }
                }
                CalendarView(profile: profile, updated: $updated, lastSelectedDate: $lastSelectedDate, lastPick: $lastPick)
                    .fixedSize(horizontal: false, vertical: true)

                if lastPick == nil {
                    
                    NavigationLink {
                        TaskListView(profile: profile, updated: $updated)
                        
                    } label: {
                        Label("Task To Do", systemImage: "checklist")
                    }
                    
                    
                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, showLeads: true, filterMode: .today, userId: profile.info._id)
                    } label: {
                        Label("Lead Created Today", systemImage: "person")
                    }

                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .today, userId: profile.info._id)
                    } label: {
                        /* DayIconView(date: Date())
                         Text("Appointment Set Today") */

                        Label("Appointment Set Today", systemImage: "clock")
                    }

                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .last30, userId: profile.info._id)
                    } label: {
                        Label("Appointment Set Past 30 Days", systemImage: "calendar")
                    }
                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .favorite, userId: profile.info._id)
                    } label: {
                        Label("Favorites", systemImage: "heart")
                    }

                    /*
                     NavigationLink {
                         ResourceListView(profile: profile)
                     } label: {
                         Label("Resources", systemImage: "doc.richtext.fill")
                     }
                      */
                    NavigationLink {
                        ContractListView( /* profile: profile */ )
                    } label: {
                        if #available(iOS 17.0, *) {
                            Label("Contracts", systemImage: "book.pages")
                        } else {
                            Label("Contracts", systemImage: "scroll.fill")
                        }
                    }
                }

                /*
                 NavigationLink {
                     LeadListScreen()
                 } label: {
                     Label("Lead", systemImage: "person.badge.plus")
                 }
                 */
                /*
                 NavigationLink {
                     VStack {
                         Image(systemName: "exclamationmark.triangle.fill")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .foregroundColor(.orange)
                             .frame(width: 50, height: 50)

                         Text("Under Construction")
                             .font(.headline)
                             .foregroundColor(.orange)
                     }
                 } label: {
                     Label("Extra", systemImage: "chart.bar")
                 }
                  */
            }

            // .navigationTitle("Home")

            .sheet(isPresented: $showOption) {
                SettingView(loginManager: profile)
                // .environmentObject(store)
            }
            .toolbar {
                if lastPick != nil {
                    ToolbarItemGroup(placement: .navigation) {
                        NavigationLink {
                            AppointmentList(profile: profile, updated: $updated, showLeads: true, filterMode: .today, userId: profile.info._id)
                        } label: {
                            Label("", systemImage: "person")
                        }

                        NavigationLink {
                            AppointmentList(profile: profile, updated: $updated, filterMode: .today, userId: profile.info._id)
                        } label: {
                            DayIconView(date: Date())

                            // Text("Appointment Set Today")
                        }
                        NavigationLink {
                            AppointmentList(profile: profile, updated: $updated, filterMode: .last30, userId: profile.info._id)
                        } label: {
                            Label("", systemImage: "calendar")
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    // ToolbarItem(placement: .automatic) {
                    Button {
                        showOption = true
                    } label: {
                        Image(systemName: "gear")
                    }

                    NavigationLink {
                        ResourceListView(profile: profile)
                    } label: {
                        Label("Resources", systemImage: "doc.richtext.fill")
                    }
                    /*
                     NavigationLink {
                         CreateLead(profile: profile, lead: $lead, mode: 1, manager: manager, updated: $updated) { _ in
                         }

                     } label: {
                         Image(systemName: "plus")
                     }
                      */
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // ToolbarItem(placement: .automatic) {
                    /*
                     Button {
                         showOption = true
                     } label: {
                         Image(systemName: "gear")
                     }
                     */

                    NavigationLink {
                        CreateLead(profile: profile, lead: $lead, mode: 1, manager: manager, updated: $updated) { _ in
                            
                        }

                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            if lastPick != nil && false {
                HStack {
                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, showLeads: true, filterMode: .today, userId: profile.userId)
                    } label: {
                        Label("", systemImage: "person")
                    }

                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .today, userId: profile.userId)
                    } label: {
                        DayIconView(date: Date())

                        // Text("Appointment Set Today")
                    }
                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .last30, userId: profile.userId)
                    } label: {
                        Label("", systemImage: "calendar")
                    }
                }
            }
            /*
             NavigationLink {
                 AppleMapScreen(profile: profile, updated: $updated, leadManager: manager, location: startLocation)

                 // .edgesIgnoringSafeArea(.all)
             } label: {
                 VStack {
                     Image(systemName: "map.fill")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 30, height: 30)
                         .foregroundColor(.blue)

                     Text("Map")
                         .font(.caption)
                         .foregroundColor(.blue)
                 }
             }
             Spacer()
              */

            HStack {
                NavigationLink {
                    HomeMap(profile: profile, updated: $updated, leadManager: manager, location: startLocation)

                    // .edgesIgnoringSafeArea(.all)
                } label: {
                    VStack {
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)

                        Text("Map")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()

                NavigationLink {
                    VStack {
                        RouteListView(profile: profile)
                    }
                } label: {
                    VStack {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "car.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }

                        Text("Routes")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()

                NavigationLink {
                    LeadListScreen(profile: profile, updated: $updated)

                } label: {
                    VStack {
                        Image(systemName: "person.badge.plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)

                        Text("Leads")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                if profile.role == "ADMIN" {
                    Spacer()

                    NavigationLink {
                        AdminScreen(profile: profile)

                    } label: {
                        VStack {
                            Image(systemName: "shield")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            Text("Admin")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                } else {
                    Spacer()

                    NavigationLink {
                        AdminScreen2(profile: profile)

                    } label: {
                        VStack {
                            Image(systemName: "chart.pie.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)

                            Text("Stats")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding(.horizontal, 50)
        }
        .environmentObject(manager)
        .onAppear {
            
           
            Task {
                // await NotificationManager.initialize(userId: profile.userId)
                if profile.notifications {
                    await NotificationManager.start(userId: profile.userId, timeBefore: profile.timeBefore)
                }

                if profile.useCalendar {
                    await CalendarManager.start(userId: profile.userId)
                }
            }
            placeManager.setLocation()

            DispatchQueue.main.async {
                if let filters = profile.info.leadFilters {
                    manager.leadFilter = filters
                }

                manager.token = profile.token

                manager.userId = profile.userId
                manager.role = profile.role

                if manager.leads.isEmpty {
                    manager.runLoad()
                }

                if let userDefaults = UserDefaults(suiteName: "group.aquafeelvirginia.com.AquaFeel") {
                    userDefaults.set(profile.userId, forKey: "userId")
                }
            }

            placeManager.start()
        }
        .onChange(of: updated) { value in
            if value {
                Task {
                    //await manager.loadInitialData()
                }
                //manager.handleFilterChange()
                //manager.search()
            }
            updated = false
            
        }

        .onReceive(placeManager.$location) { newValue in

            if let location = newValue {
                self.startLocation = location
            }
        }

        .onReceive(traceManager.$position) { position in

            if let position {
                Task {
                    try? await profile.setLocation(position: position)
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
}



#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}

struct MainAppScreenHomeScreenPreview: View {
    @StateObject var loginManager = ProfileManager()
    @StateObject private var store = MainStore<UserData>() // AppStore()
    var body: some View {
        HomeScreen(profile: loginManager)
            .environmentObject(store)
    }
}

#Preview("Main") {
    MainAppScreenPreview()
}
