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
    
    var profile:ProfileManager
    @EnvironmentObject var store: MainStore<UserData>

    
    @State public var showOption: Bool = false

    @State var lead: LeadModel = LeadModel()

    @State private var date = Date()
    @State private var isDateSelected = false
    //@State private var selectedDate = Date()

    
    @StateObject var manager = LeadManager(autoLoad: true, limit: 2000, maxLoads: 510)
    
    //@State var manager = LeadManager()
    var placeManager = PlaceManager()

    @State var startLocation = CLLocationCoordinate2D(latitude: 25.7134396, longitude: -80.2800688)
    
    
    @State private var selectedIdentifier: Calendar.Identifier = .gregorian
    @State private var selectedDate: Date?
    @State private var selectedDate2: Date?
    @State private var myTest = "0"
    
    
    var body: some View {
        NavigationStack {
            /*
             TabView {
             Route()
             //.badge(2)
             .tabItem {
             Label("Home", systemImage: "house")
             }
             .navigationTitle("Configuración")

             //MapView()
             //MapScreen()
             LeadMap()
             .edgesIgnoringSafeArea(.all)
             .tabItem {
             Label("Statics", systemImage: "car.fill")
             }
             testLeadList()
             //.badge("!")
             .tabItem {
             Label("Lead", systemImage: "person.badge.plus")
             }
             .navigationBarTitle("Leads List")

             }*/
            Form {
                //Text("Role: \(profile.role)")
                //Text("User: \(profile.userId)")
                Text("Appointments")
                CalendarView(profile: ProfileManager())
                    
                //ContentView2024()
                    //.padding(0)
                    //.fixedSize(horizontal: false, vertical: true)
                //CalendarView(profile: profile)
                /*
                DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .onChange(of: date, perform: { newDate in
                    // Cuando la fecha cambia, activar la navegación
                    isDateSelected = true

                    selectedDate = newDate
                })
                */
                .navigationDestination(isPresented: $isDateSelected) {
                    //Text(selectedDate?.formattedDate() ?? "") // Pass selected date
                }
                /*
                 NavigationLink {
                     LeadMap(location: startLocation)
                         .edgesIgnoringSafeArea(.all)
                 } label: {
                     Label("Create Route", systemImage: "globe")
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
                    // RouteView(leads: [])
                } label: {
                    Label("Routes", systemImage: "arrow.triangle.swap")
                }
                */
                NavigationLink {
                    AppointmentList(profile: profile, showLeads: true, filterMode: .today, userId: profile.info._id)
                } label: {
                    Label("Lead Created Today", systemImage: "person")
                }
                
                NavigationLink {
                    AppointmentList(profile: profile,filterMode: .today, userId: profile.info._id)
                } label: {
                    DayIconView(date: Date())
                    
                    Text("Appointment Set Today")
                }
                
                NavigationLink {
                    AppointmentList(profile: profile, filterMode: .last30, userId: profile.info._id)
                } label: {
                    Label("Appointment Set Past 30 Days", systemImage: "calendar")
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
                    .environmentObject(store)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // ToolbarItem(placement: .automatic) {
                    Button {
                        showOption = true
                    } label: {
                        Image(systemName: "gear")
                    }

                    NavigationLink {
                        CreateLead(profile: profile, lead: $lead, mode: 1, manager: manager, userId: profile.info._id ) {_ in
                        }

                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            HStack {
                NavigationLink {
                    LeadMap(profile: profile, manager: manager, location: startLocation)
                        .edgesIgnoringSafeArea(.all)
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
                /*NavigationLink {
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
                    VStack {
                        Image(systemName: "chart.bar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)

                        Text("Extra")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()*/
                NavigationLink {
                    VStack {
                        RouteListView(profile: profile)
                    }
                } label: {
                    VStack {
                        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        
                        Text("Routes")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                Spacer()
               
                NavigationLink {
                    LeadListScreen(profile: profile)

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
            print("::", profile.token, ":", profile.userId, ":", profile.role)
           
                DispatchQueue.main.async {
                    print(profile.token, profile.role, profile.id, profile.user)
                    
                    if let filters = profile.info.leadFilters {
                        manager.leadFilter = filters
                    }
                    
                    manager.token = profile.token
                    manager.role = profile.info.role
                    manager.user = profile.info._id
                    if manager.leads.isEmpty {
                        //manager.reset()
                        manager.runLoad()
                    }
                    print("yesss", profile.info.isVerified, ":", profile.token)
                }
                
           
            
            print("//////////////////\n\n",profile)
            
            print("//////////////////\n\n")
            //manager.token = store.token
            placeManager.start()
            /*
            if let leadFilters = loginManager.leadFilters {
                print("2024 2025 2026")
                manager.leadFilter = leadFilters
            }
             */
           
           /*
            manager.token = store.token
            manager.role = store.role
            manager.user = store.id
            */
            
            
            //manager.runLoad()
            // manager.loadAll()
        }
        .onReceive(profile.$info, perform: { p in
            
        })
        .onReceive(store.$id) { id in
            
           
            print("----> last user id", id, store.role, store.id)
            //manager.user = id
            /*
            manager.token = store.token
            manager.role = store.role
            manager.user = id
            
            if manager.leads.isEmpty {
                manager.reset()
                manager.runLoad()
            }
            */
            print("<---- last user id", id, store.role, store.id)
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

#Preview {
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
