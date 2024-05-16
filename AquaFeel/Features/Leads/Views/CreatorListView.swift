//
//  CreatorListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/5/24.
//

import SwiftUI

struct CreatorListView: View {
    @Binding var selected: CreatorModel
    @ObservedObject var viewModel: CreatorManager
    
    @ObservedObject var adminManager = AdminManager()
    
    // @State var selected = false
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.creators.filter {
                    $0.firstName.localizedCaseInsensitiveContains(viewModel.searchText) ||
                    $0.lastName.localizedCaseInsensitiveContains(viewModel.searchText) || viewModel.searchText == ""
                }) { creator in
                    
                    HStack {
                        Text("\(creator.firstName) \(creator.lastName)")
                        
                            .onTapGesture {
                                viewModel.shouldDismissSheet = false
                                selected = creator
                            }
                        if creator._id == selected._id {
                            Image(systemName: creator._id == selected._id ? "checkmark.circle.fill" : "circle")
                            // .foregroundColor(.gray) // Consistent checkbox color
                        }
                    }
                    .foregroundColor(creator._id == selected._id ? .accentColor : .primary)
                }
            }
            .searchable(text: $viewModel.searchText)
            .navigationBarTitle("Owners List", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                viewModel.shouldDismissSheet = false
            }) {
                Image(systemName: "xmark") // Use "xmark" or any other SF Symbol
            })
        }
        .task {
            try? await adminManager.getUsers()
            
        }
        
        .onReceive(adminManager.$allSellers) { users in
            
            viewModel.creators = users.map { user in
                CreatorModel(
                    _id: user._id, // Asegúrate de tener una propiedad que puedas utilizar como _id
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName
                )
            }
        }
    }
}

