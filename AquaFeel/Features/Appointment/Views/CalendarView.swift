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
    var date: Date
    @State private var isCreateLeadActive = false
    @State var filter = ""

    // @StateObject var lead2 = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var manager = LeadManager(autoLoad: false)
    // @StateObject var user = UserManager()

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
                    NavigationLink(destination: CreateLead(profile: profile, lead: $manager.leads[index], manager: manager, userId: profile.userId) { _ in }) {
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
                } else  if manager.lastResult == 0 {
                        Text("no leads")
                }
                
            }

            
            .onAppear {
                print("onAppear 1.0...", profile.userId)

                manager.userId = profile.userId
                manager.role = profile.role
                manager.token = profile.token

              
            }
            .onAppear {
                print("onAppear 2.0...", profile.userId)
                manager.user = profile.userId
                let leadQuery = LeadQuery()
                    .add(.field, "appointment_date")
                    .add(.statusId, "613bb4e0d6113e00169fefa9")
                    .add(.quickDate, "custom")

                    .add(.fromDate, formatDateToString(date))

                    .add(.toDate, formatDateToString(date))
                    // .add(.searchKey, "all")
                    .add(.offset, "0")
                    .add(.limit, "1000")
                // .add(.searchValue, "jose")
                manager.list(query: leadQuery)

                // manager.search()
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        manager.reset()
                        manager.load(count: 9)

                    } label: {
                        HStack {
                            // Text("Reset")
                            Image(systemName: "gobackward")
                        }
                        // .font(.caption)
                        // .fontWeight(.bold)
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Leads: \(shortDate(date))")

            
        }.sheet(isPresented: $isFilterModalPresented) {
            FilterOption(filter: $manager.filter, filters: $manager.leadFilter, statusList: manager.statusList, usersList: manager.users) {
                print("reseteando")
                manager.reset()
            }
            .onAppear {
                // lead2.statusAll()
            }

            Button(action: {
                // Acción para mostrar la ventana modal con filtros
                isFilterModalPresented.toggle()
            }) {
                Text("Close")
                /* Image(systemName: "slider.horizontal.3") // Icono de sistema para filtros
                 .foregroundColor(.blue)
                 .font(.system(size: 20)) */
            }
            .padding()
        }

        .onAppear {
            // print(":::::::", store.token)
            // manager.user = store.id
            // manager.token = store.token
            // manager.role = store.role

            manager.role = profile.role
            manager.token = profile.token
        }
    }
}

struct CalendarView: View {
    var profile: ProfileManager

    @State private var isDateSelected = false
    @StateObject var manager: AppointmentManager = AppointmentManager(filterMode: .all)
    @State private var lastSelectedDate: Date?

    var body: some View {
        NavigationStack {
            AquaCalendar(selected: $lastSelectedDate, month: $manager.month, specialDates: manager.specialDates)
                .navigationDestination(isPresented: $isDateSelected) {
                    AppointmentList2(profile: profile, date: lastSelectedDate ?? Date())
                }
                .onChange(of: lastSelectedDate) { _ in
                    isDateSelected = true
                }
        }
        .onAppear {
            manager.userId = profile.userId
        }
    }
}

#Preview {
    CalendarView(profile: ProfileManager())
}

struct xxxx: View {
    @State private var selectedIdentifier: Calendar.Identifier = .gregorian
    @State private var selectedDate: Date?
    @State private var month: Date?
    @State private var myTest = "0"
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
            AquaCalendar(selected: $selectedDate, month: $month, calendarIdentifier: selectedIdentifier)
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
