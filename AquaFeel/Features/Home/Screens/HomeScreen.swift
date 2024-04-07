//
//  HomeScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

import CoreLocation
import SwiftUI

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

    @StateObject var manager = LeadManager(autoLoad: true, limit: 2000, maxLoads: 2000)

    // @State var manager = LeadManager()
    var placeManager = PlaceManager()

    @State var startLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    @State private var selectedIdentifier: Calendar.Identifier = .gregorian
    @State private var lastSelectedDate: Date?
    @State private var selectedDate2: Date?
    @State private var myTest = "0"
    @State private var updated = false

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
                        AppointmentList(profile: profile, updated: $updated, showLeads: true, filterMode: .today, userId: profile.info._id)
                    } label: {
                        Label("Lead Created Today", systemImage: "person")
                    }

                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .today, userId: profile.info._id)
                    } label: {
                        DayIconView(date: Date())

                        Text("Appointment Set Today")
                    }

                    NavigationLink {
                        AppointmentList(profile: profile, updated: $updated, filterMode: .last30, userId: profile.info._id)
                    } label: {
                        Label("Appointment Set Past 30 Days", systemImage: "calendar")
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
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // ToolbarItem(placement: .automatic) {
                    Button {
                        showOption = true
                    } label: {
                        Image(systemName: "gear")
                    }

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
            }
            .padding(.horizontal, 50)
        }
        .onAppear {
            placeManager.setLocation()

            DispatchQueue.main.async {
                if let filters = profile.info.leadFilters {
                    manager.leadFilter = filters
                }

                manager.token = profile.token

                manager.userId = profile.userId
                manager.role = profile.role
                print("manager manager manager: ", manager.userId, manager.role)

                if manager.leads.isEmpty {
                    manager.runLoad()
                }
            }

            placeManager.start()
        }
        .onChange(of: updated) { value in
            if value {
                manager.search()
            }
            updated = false
        }

        .onReceive(placeManager.$location) { newValue in

            if let location = newValue {
                self.startLocation = location
            }
        }
    }
}

struct OptionA: View {
    var body: some View {
        Text("Hello, OptionA!")
    }
}

struct OptionB: View {
    var body: some View {
        Text("Hello, OptionB!")
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
