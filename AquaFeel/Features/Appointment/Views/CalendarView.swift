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
        let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
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

// https://api.aquafeelvirginia.com/leads/list-all?limit=20&offset=0&quickDate=custom&field=appointment_date&toDate=2024-03-15T18:48:00.000Z&fromDate=2024-03-01T18:48:00.000Z&status_id=613bb4e0d6113e00169fefa9

struct LeadPicker2: View {
    var profile:ProfileManager
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
    
    //@Binding var selectedLeads: [LeadModel]
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
                    NavigationLink(destination:  CreateLead(lead: $manager.leads[index], manager: manager, userId: profile.userId){_ in}) {
                        HStack{
                            SuperIconViewViewWrapper(status: getStatusType(from: manager.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                
                                Text("\(manager.leads[index].first_name) \(manager.leads[index].last_name)" )
                                //.fontWeight(.semibold)
                                //.foregroundStyle(.blue)
                                
                                Text( "\(manager.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                                
                            }
                            
                        }
                        
                    }
                }
                
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .foregroundColor(.red)
                    
            }
            
            /* List($lead.leads.indices, id: \.self) { index in
             
             NavigationLink(destination:  CreateLead(lead: $lead.leads[index], manager: lead2){}) {
             HStack{
             SuperIconViewViewWrapper(status: getStatusType(from: lead.leads[index].status_id.name))
             .frame(width: 34, height: 34)
             VStack(alignment: .leading) {
             
             Text("\(lead.leads[index].first_name) \(lead.leads[index].last_name)" )
             //.fontWeight(.semibold)
             //.foregroundStyle(.blue)
             
             Text( "\(lead.leads[index].street_address)")
             .foregroundStyle(.gray)
             
             }
             
             }
             
             }
             
             } */
            
            .onAppear {
                print("onAppear...")
                
                manager.role = profile.role
                manager.token = profile.token
                
               
                // let leadQuery = LeadQuery()
                // .add(.limit , "10")
                // .add(.searchKey, "all")
                // .add(.searchValue, "yanny")
                
                // lead.load(count: 3)
                // print(9999)
                // user.list(){}
            }
            .onAppear {
               
                
                
                let leadQuery = LeadQuery()
                    .add(.field, "appointment_date")
                    .add(.statusId, "613bb4e0d6113e00169fefa9")
                    .add(.quickDate, "custom")
                
                    .add(.fromDate, formatDateToString(date))
                
                    .add(.toDate, formatDateToString(date))
                //.add(.searchKey, "all")
                    .add(.offset, "0")
                    .add(.limit, "1000")
                //.add(.searchValue, "jose")
                manager.list(query:leadQuery)
                
                //manager.search()
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
            .navigationBarTitle("Leads \(date.formatted())")
            
            
            // HStack{
            /* Divider()
             .padding(.horizontal, 20)
             
             //.overlay(VStack{Divider().offset(x: 0, y: 15)})
             Divider()
             .padding(.bottom, 10)
             .padding(.horizontal, 20)
             */
            
            // }
            
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
    
    
    @State private var date = Date()
    @State private var isDateSelected = false
    @State private var selectedDate = Date()
    
    @StateObject var manager:AppointmentManager = AppointmentManager(filterMode: .all)
    
    @State var firstDate = ""
    @State var lastDate = ""
    
    @State private var dates: Set<DateComponents> = []
    
    @State var a = Date()
    @State var b = Date()
    
    
    
    let allowedDates = [
        Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 11))!,
        Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 24))!
    ]
    
    
    var body: some View {
        NavigationStack{
      
            
            
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
                firstDate = newDate.startOfMonth().formattedDate2()
                lastDate = newDate.endOfMonth().formattedDate2()
                Task{
                    try? await manager.listByMonth(myDate: newDate)
                }
                
            })
            
            .navigationDestination(isPresented: $isDateSelected) {
                //Text(selectedDate.formattedDate2()) // Pass selected date
                LeadPicker2(profile: profile, date: date)
            }
        }
        .onAppear{
            
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.year = 2024
            dateComponents.month = 3
            dateComponents.day = 11
            
            a = calendar.date(from: dateComponents) ?? Date()
            
            dateComponents.year = 2024
            dateComponents.month = 3
            dateComponents.day = 4
            b = calendar.date(from: dateComponents) ?? Date()
            
            
            let date = Date()
            let (start, end) = dateRangeString(for: date)
            print("Rango de tiempo para \(date): de \(start) a \(end)")
        }
        .task{
            try? await manager.listByMonth(myDate: date)
        }
        
    }
}

#Preview {
    CalendarView(profile: ProfileManager())
}
