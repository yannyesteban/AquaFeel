//
//  LeadsMapsView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/4/24.
//

import SwiftUI

struct LeadsMapsView: View {
    var profile: ProfileManager
    @ObservedObject var manager : LeadManager
    @ObservedObject var clusterTool: ClusterTool
    @Binding var updated: Bool
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var filteredLeads: [LeadModel] {
        if searchText.isEmpty {
            return manager.leads
        } else {
            return manager.leads.filter { $0.first_name.localizedCaseInsensitiveContains(searchText) || $0.last_name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredLeads.indices, id: \.self) { index in
                
                    HStack () {
                        SuperIconViewViewWrapper(status: getStatusType(from: filteredLeads[index].status_id.name))
                            .frame(width: 34, height: 34)
                        VStack(alignment: .leading) {
                            Text("\(filteredLeads[index].first_name) \(filteredLeads[index].last_name)")
                            // .fontWeight(.semibold)
                            // .foregroundStyle(.blue)
                            
                            Text("\(filteredLeads[index].street_address)")
                                .foregroundStyle(.gray)
                        }
                    }
                    .onTapGesture {
                        clusterTool.goto(lead: filteredLeads[index])
                        presentationMode.wrappedValue.dismiss()
                    }
               
                
                
            }
          /*
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.black)
                .foregroundColor(.red)
                .onAppear {
                    manager.list()
                }
           */
        }
        .searchable(text: $searchText, prompt: "Search Lead")
    }
}

#Preview("Main") {
    MainAppScreenPreview()
}
