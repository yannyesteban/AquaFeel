//
//  BasicLeadListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/4/24.
//

import SwiftUI

struct BasicLeadListView: View {
    @Binding var leads: [LeadModel]
    var body: some View {
        List {
            ForEach(leads.indices, id: \.self) { index in

                HStack {
                    SuperIconViewViewWrapper(status: getStatusType(from: leads[index].status_id.name))
                        .frame(width: 34, height: 34)
                    VStack(alignment: .leading) {
                        Text("\(leads[index].first_name) \(leads[index].last_name)")
                        // .fontWeight(.semibold)
                        // .foregroundStyle(.blue)

                        Text("\(leads[index].street_address)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}


struct SimpleLeadListView: View {
    @State var leads: [LeadModel] = []
    
    /*var sortedLeads: [LeadModel] {
               
        leads.sorted { $0.appointment_date > $1.appointment_date }
    }*/
    
    var body: some View {
        List {
            ForEach(leads.indices, id: \.self) { index in
                
                HStack {
                    VStack(alignment: .center) {
                        SuperIconViewViewWrapper(status: getStatusType(from: leads[index].status_id.name))
                            .frame(width: 34, height: 34)
                        Text(formattedTime(from: leads[index].appointment_time)).font(.footnote)
                    }.frame(width: 70)
                    VStack(alignment: .leading) {
                        Text("\(leads[index].first_name) \(leads[index].last_name)")
                        // .fontWeight(.semibold)
                        // .foregroundStyle(.blue)
                        
                        Text("\(leads[index].street_address)")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    leads.sort { $0.appointment_time < $1.appointment_time }
                }
            }
            
        }
    }
}

