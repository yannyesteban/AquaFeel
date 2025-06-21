//
//  CalendarView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/3/24.
//

import SwiftUI

extension Date {
    // Método para obtener el primer día del mes
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    // Método para obtener el último día del mes
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth())!
        return startOfNextMonth
    }

    // Método para formatear la fecha como texto
    func formattedDate2() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter.string(from: self)
    }
}

func formatDateToString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
}

func dateRangeString(for date: Date) -> (String, String) {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(bySettingHour: 0, minute: 59, second: 59, of: startOfDay)!

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

    let startDateString = dateFormatter.string(from: startOfDay)
    let endDateString = dateFormatter.string(from: endOfDay)

    return (startDateString, endDateString)
}

func shortDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d" // "MMMM" representa el nombre completo del mes y "d"

    return dateFormatter.string(from: date)
}

struct AppointmentList2: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    var date: Date
    @State private var isCreateLeadActive = false
    @State var filter = ""

    // @StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var manager = LeadManager(autoLoad: false)
    

    @State private var isFilterModalPresented = false

    @State private var numbers: [Int] = Array(1 ... 20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()

    // @Binding var selectedLeads: [LeadModel]
    // @State var selectedLeads: Set<LeadModel> = []

    // @EnvironmentObject var store: MainStore<UserData>
    /*
     func toggleLeadSelection(_ lead: LeadModel) {
         if let index = selectedLeads.firstIndex(of: lead) {
             selectedLeads.remove(at: index) // Si ya está seleccionado, lo eliminamos
         } else {
             selectedLeads.append(lead) // Si no está seleccionado, lo añadimos
         }
     }
     */
    func loadMoreContent() {
        if !isLoading {
            isLoading = true
            // This simulates an asynchronus call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let moreNumbers = numbers.count + 1 ... numbers.count + 20
                numbers.append(contentsOf: moreNumbers)
                isLoading = false
                if numbers.count > 250 {
                    isFinished = true
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    NavigationLink(destination: CreateLead(profile: profile, lead: $manager.leads[index], manager: manager, updated: $updated) { _ in }) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                                // .fontWeight(.semibold)
                                // .foregroundStyle(.blue)

                                Text("\(manager.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }

                if manager.lastResult == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .foregroundColor(.red)
                } else if manager.lastResult == 0 {
                    Text("no leads")
                }
            }

            .onAppear {
                manager.userId = profile.userId
                manager.role = ""
                manager.token = profile.token
            }
            .onAppear {
                manager.userId = profile.userId
                let leadQuery = LeadQuery()
                    .add(.field, "appointment_date")
                    // .add(.statusId, "613bb4e0d6113e00169fefa9")
                    .add(.quickDate, "custom")

                    .add(.fromDate, formatDateToString(date))

                    .add(.toDate, formatDateToString(date))
                    // .add(.searchKey, "all")
                    .add(.offset, "0")
                    .add(.limit, "1000")
                // .add(.searchValue, "jose")
                //manager.list(query: leadQuery)
                Task {
                    try? await manager.list(query: leadQuery)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        manager.reset()
                        manager.load(count: 9)

                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                        }

                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Leads: \(shortDate(date))")

        }.sheet(isPresented: $isFilterModalPresented) {
            FilterOption(profile: profile, filter: $manager.filter, filters: $manager.leadFilter, statusList: manager.statusList, usersList: manager.users) {
                manager.reset()
            }

            Button(action: {
                isFilterModalPresented.toggle()
            }) {
                Text("Close")
            }
            .padding()
        }

        .onAppear {
            manager.role = profile.role
            manager.token = profile.token
        }
    }
}

struct AppointmentByDate: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    var date: Date
    @State private var isCreateLeadActive = false
    @State var filter = ""

    // @StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var manager = LeadManager(autoLoad: false)
    

    @State private var isFilterModalPresented = false

    @State private var numbers: [Int] = Array(1 ... 20)
    @State private var isLoading = false
    @State private var isFinished = false
    @State var lead: LeadModel = LeadModel()

    // @Binding var selectedLeads: [LeadModel]
    // @State var selectedLeads: Set<LeadModel> = []

    // @EnvironmentObject var store: MainStore<UserData>
    /*
     func toggleLeadSelection(_ lead: LeadModel) {
     if let index = selectedLeads.firstIndex(of: lead) {
     selectedLeads.remove(at: index) // Si ya está seleccionado, lo eliminamos
     } else {
     selectedLeads.append(lead) // Si no está seleccionado, lo añadimos
     }
     }
     */
    func loadMoreContent() {
        if !isLoading {
            isLoading = true
            // This simulates an asynchronus call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let moreNumbers = numbers.count + 1 ... numbers.count + 20
                numbers.append(contentsOf: moreNumbers)
                isLoading = false
                if numbers.count > 250 {
                    isFinished = true
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    NavigationLink(destination: CreateLead(profile: profile, lead: $manager.leads[index], manager: manager, updated: $updated) { _ in }) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                                // .fontWeight(.semibold)
                                // .foregroundStyle(.blue)

                                Text("\(manager.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }

                if manager.lastResult == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.black)
                        .foregroundColor(.red)
                } else if manager.lastResult == 0 {
                    Text("no leads")
                }
            }

            .onAppear {
                manager.userId = profile.userId
                manager.role = ""
                manager.token = profile.token
            }
            .onAppear {
                manager.userId = profile.userId
                let leadQuery = LeadQuery()
                    .add(.field, "appointment_date")
                    // .add(.statusId, "613bb4e0d6113e00169fefa9")
                    .add(.quickDate, "custom")

                    .add(.fromDate, formatDateToString(date))

                    .add(.toDate, formatDateToString(date))
                    // .add(.searchKey, "all")
                    .add(.offset, "0")
                    .add(.limit, "1000")
                // .add(.searchValue, "jose")
                Task {
                    try? await manager.list(query: leadQuery)
                }
                //manager.list(query: leadQuery)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        manager.reset()
                        manager.load(count: 9)

                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                        }

                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Leads: \(shortDate(date))")

        }.sheet(isPresented: $isFilterModalPresented) {
            FilterOption(profile: profile, filter: $manager.filter, filters: $manager.leadFilter, statusList: manager.statusList, usersList: manager.users) {
                manager.reset()
            }

            Button(action: {
                isFilterModalPresented.toggle()
            }) {
                Text("Close")
            }
            .padding()
        }

        .onAppear {
            manager.role = profile.role
            manager.token = profile.token
        }
    }
}

struct CalendarView: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    @State private var isDateSelected = false
    @StateObject var manager: AppointmentManager = AppointmentManager(filterMode: .all)
    @Binding var lastSelectedDate: Date?

    @State private var picked: Bool = false

    @Binding var lastPick: String?
    @State var leads: [LeadModel] = []
    var body: some View {
        NavigationStack {
            AquaCalendar(selected: $lastSelectedDate, month: $manager.month, picked: $picked, specialDates: manager.specialDates)
                .navigationDestination(isPresented: $isDateSelected) {
                    AppointmentList2(profile: profile, updated: $updated, date: lastSelectedDate ?? Date())
                }
                .onChange(of: lastSelectedDate) { _ in
                    // isDateSelected = true
                }
                .onChange(of: picked) { _ in
                    withAnimation {
                        if let date = lastSelectedDate {
                            let lastDate = formatDateToString(date)

                            if lastDate != lastPick {
                                leads = manager.groups[lastDate] ?? []
                                
                                leads.sort { lead1, lead2 in
                                    return lead1.appointment_time < lead2.appointment_time
                                }
                                
                                manager.leads = leads
                                if leads.count > 0 {
                                    lastPick = lastDate
                                } else {
                                    lastPick = nil
                                }

                            } else {
                                lastPick = nil
                            }
                        }
                    }
                }
        }

        .onAppear {
            manager.userId = profile.userId

            if let date = manager.month {
                manager.doTask(date: date)
            }
        }

        // VStack(alignment: .leading){

        if lastPick != nil {
            List {
                ForEach(manager.leads.indices, id: \.self) { index in
                    NavigationLink(destination: CreateLead(profile: profile, lead: $manager.leads[index], manager: LeadManager(autoLoad: false), updated: $updated) { _ in }) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 30, height: 30)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)")
                                    // .fontWeight(.semibold)
                                    // .foregroundStyle(.blue)

                                    Text("\(formattedTime(from: manager.leads[index].appointment_time))")
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }

        // }
    }
}

#Preview {
    CalendarView(profile: ProfileManager(), updated: .constant(false), lastSelectedDate: .constant(nil), lastPick: .constant(nil))
}

struct xxxx: View {
    @State private var selectedIdentifier: Calendar.Identifier = .gregorian
    @State private var selectedDate: Date?
    @State private var month: Date?
    @State private var myTest = "0"
    @State private var picked: Bool = false
    private var textDate: String {
        guard let selectedDate else {
            return "Date not selected"
        }

        let formatter = DateFormatter()

        formatter.dateStyle = .medium

        return formatter.string(from: selectedDate)
    }

    var body: some View {
        ScrollView {
            Text("Hola \(myTest)")
            // TextField("value", selected: $selectedDate)
            Text(textDate)
                .font(.largeTitle)
            AquaCalendar(selected: $selectedDate, month: $month, picked: $picked, calendarIdentifier: selectedIdentifier)
            // ContentView2024()        .scaledToFit()

            Picker("", selection: $selectedIdentifier) {
                Text("Gregorian")
                    .tag(Calendar.Identifier.gregorian)
                Text("hebrew")
                    .tag(Calendar.Identifier.hebrew)
                Text("buddhist")
                    .tag(Calendar.Identifier.buddhist)
            }

            /*
             AquaCalendar(calendarIdentifier: selectedIdentifier)
                 .scaledToFit()*/
        }
        // .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    xxxx()

    // .font(.system(size: 25, weight: .bold, design: .serif))
}

#Preview {
    MainAppScreenHomeScreenPreview()
}
