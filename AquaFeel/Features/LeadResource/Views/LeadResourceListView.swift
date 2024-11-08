//
//  LeadResourceListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/10/24.
//

import SwiftUI

struct LeadResourceRow: View {
    let resource: LeadResourceModel
    
    var body: some View {
        HStack {
            Image(systemName: resource.type.iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(resource.description)
                    .font(.headline)
                Text("Type: \(resource.type.description.uppercased())")
                    .font(.subheadline)
            }
            Spacer()
            /*if resource.active {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }*/
        }
    }
}

struct LeadResourceListView: View {
    var profile: ProfileManager
    var leadId: String
    @StateObject var resourceManager = LeadResourceManager()
    @State private var resources: [LeadResourceModel] = []
    
    @State var resource = LeadResourceModel()
    
    var body: some View {
       
        NavigationStack {
            List(resourceManager.resources.filter { $0.active }) { resource in
                NavigationLink(destination: LeadResourceDetailView(resource: resource)) {
                    LeadResourceRow(resource: resource)
                }
            }
            .navigationTitle("Resources")
            
            .task {
                try? await resourceManager.list(leadId: leadId)
            }
        }
         
    }
}

