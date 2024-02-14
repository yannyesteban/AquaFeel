//
//  Route.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/1/24.
//

import SwiftUI

struct Route: View {
    @State private var date = Date()
    
    
    var body: some View {
        NavigationStack{
            Form{
                
                
                Text("Appointments")
                DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                
                NavigationLink("Routes"){
                    Text("NO")
                }
                
                NavigationLink("Leads"){
                    testLeadList()
                }
            }
            
           
        }
        
        
    }
}

#Preview {
    Route()
}
