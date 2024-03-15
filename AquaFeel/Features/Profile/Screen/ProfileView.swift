//
//  ProfileScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct ProfileView: View {
    
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    
    var body: some View {
        NavigationStack {
            
            Form{
                AvatarView(imageURL: URL(string: "avatar) ?? URL(string: "defaultAvatarURL")!)
                    .padding()
                Section("Basic Info"){
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    
                    /*HStack{
                        TextField("City", text: $texto)
                        TextField("State", text: $texto)
                    }
                    HStack{
                        
                        TextField("Zip Code", text: $texto)
                        TextField("Country", text: $texto)
                    }*/
                    
                }
                .font(.headline)
                //.navigationTitle("email")
                
                .autocapitalization(.none)
                .disableAutocorrection(true)
                //.padding(.top, 20)
                //.navigationTitle("Contact Info")
                //.accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                //.foregroundColor(.red)
                
                Section{
                    NavigationLink {
                        PassView()
                    } label: {
                        Text("Change Password")
                        // existing contents…
                    }
                }
                
                .font(.headline)
                
               
                
            }
            .background(.blue)
            .navigationTitle("Update Profile")
            
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    
                    Button("SAVE"){
                        
                    }
                    
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
