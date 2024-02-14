//
//  CreateLead.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/1/24.
//

import SwiftUI

class MyViewModel: ObservableObject {
    // @Published ensures changes are observed by SwiftUI
    @Published var nombre = "yanny"
    
   
}

struct TextWithIcon: View {
    let text: String
    
    var body: some View {
        HStack {
           
            SuperIconViewViewWrapper(status: getStatusType(from: "NHO"))
                .frame(width: 30, height: 30)
        }
    }
}

struct DatePickerString: View {
    var title: String
    @Binding var text:String
    
    private var realDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: text) {
            return date
        } else {
            // If the conversion fails, returns the current date as the default value
            return Date()
        }
    }
    
    var body: some View {
        
        
        DatePicker(
            title,
            selection: Binding<Date>(
                get: { self.realDate },
                set: { newValue in
                    // Convert the new selected date to a string format and assign to the ObservableLeadModel
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    
                    text = dateFormatter.string(from: newValue)
                }
            ),
            
            displayedComponents: [.date, .hourAndMinute]
        )
    }
}

struct MyStatus: View {
    @Binding var status: StatusId
    
    @State var sta: StatusType = .appt
    @State private var isModalPresented = false
    
    var statusList : [StatusId]
    var body: some View {
        
        HStack {
            
            VStack{
                SuperIcon2(status: $sta)
                
                
                    .frame(width: 50, height: 50)
                Text(status.name)
                    .frame(width: 50, height: 30)
            }.onTapGesture {
                isModalPresented.toggle()
            }
            .onAppear(){
                print(status.name, "*********")
                sta = getStatusType(from: status.name)
            }
            .onChange(of: status.name) { newStatus in
                print(status.name, "...........................", newStatus)
                sta = getStatusType(from: newStatus)
                
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(statusList, id: \._id) { item in
                        // Utiliza Label para combinar una imagen y un texto
                        VStack{
                            
                            SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                            
                            
                                .frame(width: 30, height: 30)
                                .padding(5)
                                .onTapGesture{
                                    status = item
                                }
                            Text(item.name)
                                .frame(width: 50, height: 30)
                                .foregroundColor(.blue)
                        }
                        
                        
                        
                    }
                }
            }
            .padding(5)
            //.background(.gray.opacity(0.2))
        }.padding(0)
            .sheet(isPresented: $isModalPresented) {
                // Contenido de la modal, por ejemplo, una lista de SuperIconViewViewWrapper
                VStack{
                    SuperIcon2(status: $sta)
                    
                    
                        .frame(width: 50, height: 50)
                    Text("Status: \(status.name)")
                        //.frame(width: 50, height: 30)
                }
                .padding(10)
                Divider()
                ScrollView() {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                        ForEach(statusList, id: \._id) { item in
                            VStack{
                                SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                                    .frame(width: 50, height: 50)
                                    .padding(5)
                                    .onTapGesture {
                                        status = item
                                        isModalPresented.toggle()
                                    }
                                
                                Text(item.name)
                                    .frame(width: 50, height: 30)
                                    //.foregroundColor(.blue)
                            }.padding(0)
                            
                        }
                    }
                    
                   
                }
                .padding(30)
                    
                Button("back"){
                    isModalPresented.toggle()
                }
            }.padding(0)
        
        
    }
}

struct CreateLead: View {
    @State private var texto = ""
    @State private var date = Date()
    
    
    @Binding var lead: LeadModel
    //@StateObject var model1: LeadModel = LeadModel()
    @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    
    @State var deleteConfirm = false;
    
    @State var mode: Int = 2
    private func loadDataAndProcess() {
        lead2.statusAll()
    }
    var body: some View {
        
        NavigationStack {
            
            Form{
                
                Section("Contact Info"){
                    TextField("First Name", text: $lead.first_name)
                    TextField("Last Name", text: $lead.last_name)
                    TextField("Phone Number", text: $lead.phone)
                    TextField("Alternative Number", text: $lead.phone2)
                    TextField("Email Number", text: $lead.email)
                    //TextField("Street Address", text: $lead.street_address)
                    //TextField("Apt / Suite", text: $lead.apt)
                    //TextField("City", text: $lead.city)
                    //TextField("State", text: $lead.state)
                    //TextField("Zip Code", text: $lead.zip)
                    //TextField("Country", text: $lead.country)
                    
                   
                    
                    
                    

                    //AddressView(leadAddress: $lead as! Binding<any AddressProtocol>)
                    /*HStack{
                        TextField("City", text: $texto)
                        TextField("State", text: $texto)
                    }
                    HStack{
                        
                        TextField("Zip Code", text: $texto)
                        TextField("Country", text: $texto)
                    }*/
                    
                }
                .font(.headline)
                //.navigationTitle("email")
                
                .autocapitalization(.none)
                .disableAutocorrection(true)
                //.padding(.top, 20)
                //.navigationTitle("Contact Info")
                //.accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                //.foregroundColor(.red)
                
                Section("Status") {
                    HStack {
                        MyStatus(status: $lead.status_id, statusList: lead2.statusList)
                    }
                        
                }
                
                
                
                
                
                
                Section("Address"){
                    AddressView<LeadModel>(label: "write a address", leadAddress: $lead)
                }
               
                /*
                Section("Address"){
                    AddressView(label: "write a address", leadAddress: Binding(
                        get: { address  },
                        set: { address = $0 }
                    ))
                }
                
                */
                
                Section("Appointment / Callback time"){
                    DatePickerString(title: "Date", text: $lead.appointment_date)
                    DatePickerString(title: "Fecha", text: $lead.appointment_time)
                }
                
                .font(.headline)
                
                
                Section("Note") {
                    TextField("", text: $lead.note, axis: .vertical)
                        .lineLimit(2...4)
                               
                        
                }
                
            }
            .onChange(of: mode) { newMode in
                if newMode == 1 {
                    lead = LeadModel() // Reinicia el valor de lead cuando mode es 1
                }
            }
            .background(.blue)
            .navigationTitle("Create Lead")
            
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button{
                        //lead2.save(body: lead)
                        mode = 1
                        
                        let user = UserModel()
                        
                        let query = LeadQuery()
                            .add(.id,"AHXrBjRDi")
                        
                        user.get(query: query)
                        
                    } label : {
                        Label("new", systemImage: "plus")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    Button{
                        if mode == 1 {
                            lead.created_by._id = "AHXrBjRDi"
                            lead2.save(body: lead, mode: .add)
                        }else {
                            lead2.save(body: lead)
                        }
                        
                    } label : {
                        Label("Guardar", systemImage: "square.and.arrow.down")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    Button{
                        deleteConfirm = true
                    }label: {
                        Label("Eliminar", systemImage: "trash")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        //.background(Color.orange)
        //.accentColor(Color.yellow)
        .onAppear {
            loadDataAndProcess()
            
            
        }
        
        
        /*.confirmationDialog(
            "are you sure to delete record?",
            isPresented: $deleteConfirm
        ) {
            Button("Delete", role: .destructive) {
                lead2.delete(body: lead)
            }
            Button("Cancel", role: .cancel) {
                deleteConfirm = false
            }
        }*/
        .confirmationDialog(
            "Eliminar Elemento",
            isPresented: $deleteConfirm,
            actions: {
                Button("Eliminar", role: .destructive) {
                    print("delete \(lead.id)")
                    let leadQuery = LeadQuery()
                        
                        .add(.id, lead.id)
                    lead2.delete(query: leadQuery)
                }
            },
            message: {
                Text("are you sure to delete record?")
            }
        )
        
    }
    
    
}

struct TestCreateLead: View {
    //@State var lead = LeadModel()
    @State var nombrecito = "Juancito"
    @State var lead: LeadModel = LeadModel(
        id: "65c56f5ff4a97859d1955f89",
        business_name: "N/A",
        first_name: "Nuñez",
        last_name: "Yanny E",
        phone: "",
        phone2: "",
        email: "",
        
        street_address: "4220 Evergreen Drive, Woodbridge, Virginia, EE. UU.",
        apt: "",
        city: "Prince William County",
        state: "VA",
        zip: "22193",
        country: "Estados Unidos",
        longitude: "-77.3374901",
        latitude: "38.637312",
        
        appointment_date: "2024-02-01T05:45:00.000Z",
        appointment_time: "2024-02-08T22:00:27.000Z",
        status_id: StatusId()
        
        
        
        
      
    )
    var body: some View {
        CreateLead(lead : $lead)
            .onAppear{
               
               
            }
        //Text(lead.appointment_date)
        Text(lead.appointment_time)
    }
}

#Preview {
    TestCreateLead()
}
