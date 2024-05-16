//
//  Route.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/1/24.
//

import SwiftUI

struct RouteX: View {
    @State private var date = Date()
    @State private var isDateSelected = false
    
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
                .onChange(of: date, perform: { newDate in
                    // Cuando la fecha cambia, activar la navegación
                    isDateSelected = true
                    print(newDate)
                })
                
                .navigationDestination(isPresented: $isDateSelected) {
                    Text("xxxx") // Pass selected date
                    
                }
                /*
                NavigationLink {
                    LeadMap()
                        .edgesIgnoringSafeArea(.all)
                } label: {
                    Label("Create Route", systemImage: "globe")
                }
                */
                NavigationLink {
                    Text("Routes")
                } label: {
                    Label("Routes", systemImage: "arrow.triangle.swap")
                }
                
                /*
                NavigationLink {
                    LeadListScreen(profie: ProfileManager(), userId: "", role: "ADMIN")
                } label: {
                    Label("Lead", systemImage: "person.badge.plus")
                }
                */
                
                NavigationLink {
                    Text("...")
                } label: {
                    Label("Extra", systemImage: "chart.bar")
                }
            }
            
            
        }
        
        
    }
}

#Preview {
    RouteX()
}
