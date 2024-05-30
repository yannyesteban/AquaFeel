//
//  ResourceEditList.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/5/24.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct ResourceEditDetail: View {
    let resource: ResourceModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Description: \(resource.description)")
            Text("Type: \(resource.type.id)")
            Text("Active: \(resource.active ? "Yes" : "No")")
            Text("Created By: \(resource.createdBy)")
            Text("Created On: \(resource.createdOn, formatter: dateFormatter)")
            Text("Updated On: \(resource.updatedOn, formatter: dateFormatter)")
        }
        .padding()
        .navigationTitle("Resource Details")
    }
}

struct ResourceEditList: View {
    var profile: ProfileManager
    @StateObject var resourceManager = ResourceManager()
    @State private var resources: [ResourceModel] = []

    @State private var showingAddResourceForm = false

    @State var resource = ResourceModel()

    var body: some View {
        NavigationStack {
            /*List {
                ForEach(resourceManager.resources.indices, id: \.self) { index in
                    NavigationLink(destination: ResourceForm(profile: profile, resourceManager: resourceManager, resources: $resources, resource: $resourceManager.resources[index], mode:.edit){  item, mode in
                        Task{
                            try? await resourceManager.list()
                        }
                    }) {
                        ResourceRow(resource: resourceManager.resources[index])
                    }
                }
                
                
            }*/
            
            
            List {
                ForEach($resourceManager.resources) { $item in
                    NavigationLink(destination: ResourceForm(profile: profile, resourceManager: resourceManager, resources: $resources, resource: $item, mode:.edit){  item, mode in
                        Task{
                            try? await resourceManager.list()
                        }
                    }) {
                        ResourceRow(resource: item)
                    }
                }
                //.onDelete(perform: deleteNotification)
            }
             
            /*List(resourceManager.resources) { resourcex in
                NavigationLink(destination: AddResourceForm(profile: profile, resourceManager: resourceManager, resources: $resources, resource: $resourcex)) {
                    ResourceRow(resource: resourcex)
                }
            }
             
             */
            .navigationTitle("Resources")
            .navigationBarItems(trailing: Button(action: {
                showingAddResourceForm = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddResourceForm) {
                ResourceForm(profile: profile, resourceManager: resourceManager, resources: $resources, resource: $resource, mode: .new){item, mode in
                    Task{
                        try? await resourceManager.list()
                    }
                }
            }
            .onAppear {
                Task{
                    try? await resourceManager.list()
                }
            }
            
        }
    }
}
