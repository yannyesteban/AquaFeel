//
//  UserManagerView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/4/24.
//

import SwiftUI

struct UserManagerView: View {
    @StateObject var userManager = UserManager()
    
    @Binding var selected: User?
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return userManager.users
        } else {
            return userManager.users.filter { $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        //NavigationView {
        List {
            ForEach(filteredUsers, id: \.self._id) { user in
                NavigationLink(destination: UserFormView(completed: .constant(false), user: user)) {
                    UserRowView(user: user)
                        
                }
               
            }
        }
        
        .searchable(text: $searchText)
        
        .navigationTitle("Users")
        .onAppear{
            userManager.search()
        }
    }
    
    
}

#Preview {
    UserManagerView(selected: .constant (User()))
}
