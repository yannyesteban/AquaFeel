//
//  LeadDetailView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 21/2/24.
//

import SwiftUI

struct LeadDetailView: View {
    @State var lead: LeadModel
    @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
               
                HStack{
                    SuperIconViewViewWrapper(status: getStatusType(from: lead.status_id.name))
                        .frame(width: 34, height: 34)
                    VStack(alignment: .leading) {
                        
                        Text("Name: \(lead.first_name) \(lead.last_name)")
                        //.fontWeight(.semibold)
                        //.foregroundStyle(.blue)
                        
                        Text( "\(lead.street_address)")
                            .foregroundStyle(.gray)
                        
                    }
                    
                }
                Section("Status") {
                    HStack {
                        MyStatus(status: $lead.status_id, statusList: lead2.statusList)
                    }
                    
                }
                
                Section("Note") {
                    TextField("", text: $lead.note, axis: .vertical)
                        .lineLimit(2...4)
                    
                    
                }
                //Text("ID: \(lead.id)")
                //Text("Business Name: \(lead.business_name)")
                Text("Name: \(lead.first_name) \(lead.last_name)")
                //Text("Last Name: \(lead.last_name)")
                Text("Phone: \(lead.phone)")
                Text("Phone2: \(lead.phone2)")
                Text("Email: \(lead.email)")
                Text("Street Address: \(lead.street_address)")
                //Text("Apt: \(lead.apt)")
                //Text("City: \(lead.city)")
                //Text("State: \(lead.state)")
                //Text("Zip: \(lead.zip)")
                //Text("Country: \(lead.country)")
                //Text("Longitude: \(lead.longitude)")
                //Text("Latitude: \(lead.latitude)")
                //Text("Appointment Date: \(lead.appointment_date)")
                //Text("Appointment Time: \(lead.appointment_time)")
                //Text("Status ID: \(lead.status_id._id)")
                Text("Created By: \(lead.created_by._id)")
                Text("Note: \(lead.note)")
                
                // Puedes agregar más Text para otras propiedades del modelo
            }
            .padding(20)
        }
        .onAppear{
            lead2.statusAll()
        }
        //.navigationBarTitle("Lead Detail", displayMode: .inline)
    }
}


#Preview {
    //GeoPreview.XX()
    LeadDetailView(lead:LeadModel())
}
