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

struct CreateLead: View {
    @State private var texto = ""
    @State private var date = Date()
    
    
    @Binding var lead: LeadModel
    @State var address: AddressProtocol = LeadModel()
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
                
                Section("Address"){
                    AddressView(label: "write a address", leadAddress: $lead)
                }
                
                Section("Appointment / Callback time"){
                    DatePickerString(title: "Date", text: $lead.appointment_date)
                    DatePickerString(title: "Fecha", text: $lead.appointment_time)
                }
                
                .font(.headline)
                
                
                Section("Note") {
                    TextField("", text: $texto, axis: .vertical)
                        .lineLimit(2...4)
                               
                        
                }
                
            }
            .background(.blue)
            .navigationTitle("Create Lead")
            
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    
                    Button("SAVE"){
                        
                    }
                    Button{
                        
                    }label: {
                        Image(systemName: "square.and.arrow.down.on.square")
                                        //.symbolRenderingMode(.palette)
                                        .foregroundStyle(Color.pink, Color.green)
                    }
                }
            }
        }
        //.background(Color.orange)
        //.accentColor(Color.yellow)
        
        
    }
    
    
}

struct TestCreateLead: View {
    //@State var lead = LeadModel()
    @State var nombrecito = "Juancito"
    @State var lead: LeadModel = LeadModel(
        _id: "65c56f5ff4a97859d1955f89",
        business_name: "N/A",
        first_name: "Fuentes María",
        last_name: "Roxana e",
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
        Text(lead.appointment_date)
        Text(lead.appointment_time)
    }
}

#Preview {
    TestCreateLead()
}
