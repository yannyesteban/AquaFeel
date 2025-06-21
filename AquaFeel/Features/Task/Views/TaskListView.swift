//
//  TaskListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/9/24.
//

import SwiftUI

struct TaskListView: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    @StateObject var routeManager = RouteManager()
    @State var id: String = "65fe1d6f5cc75bdb59dc069a"
    @ObservedObject var taskManager = TaskManager()
    @StateObject var manager = LeadManager()
    var body: some View {
        
        
        //Section("Task to Do") {
            List {
                ForEach(routeManager.route.leads.indices, id: \.self) { index in
                    
                    NavigationLink(destination: CreateLead(profile: profile, lead: $routeManager.route.leads[index], manager: manager, updated: $updated) { _ in }) {
                        HStack {
                            SuperIconViewViewWrapper(status: getStatusType(from: routeManager.route.leads[index].status_id.name))
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading) {
                                Text("\(routeManager.route.leads[index].first_name) \(routeManager.route.leads[index].last_name)")
                                // .fontWeight(.semibold)
                                // .foregroundStyle(.blue)
                                
                                Text("\(routeManager.route.leads[index].street_address)")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    /*
                    NavigationLink(destination: LeadLocationView(profile: profile, lead: routeManager.route.leads[index], location: routeManager.route.leads[index].position)) {
                        Toggle(isOn: $routeManager.route.leads[index].isSelected) {
                            HStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: routeManager.route.leads[index].status_id.name))
                                    .frame(width: 34, height: 34)
                                VStack(alignment: .leading) {
                                    Text("\(routeManager.route.leads[index].first_name) \(routeManager.route.leads[index].last_name)")
                                    Text("\(routeManager.route.leads[index].street_address)")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue)) // Puedes ajustar el color del interruptor según tus preferencias
                    }
                     */
                }
            }
            .navigationBarTitle("Task to Do")
       // }
        
            .onAppear {
                routeManager.userId = profile.userId
                
                Task {
                    
                    await taskManager.load()
                        
                  
                    
                    if let route = taskManager.route {
                        id = route._id
                        routeManager.route = route
                    }
                    
                    do {
                        // try await detail(routeId: "64c82646b6b8eb6360a05382" )
                        try await routeManager.list()
                        //try! await routeManager.detail(routeId: id)
                    } catch {
                        print(error)
                    }
                }
                
               
            }
    }
}
