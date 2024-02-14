//
//  PassView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct PassView: View {
    @State var oldPass = ""
    @State var newPass = ""
    @State var confirmPass = ""
    
    var body: some View {
        NavigationStack {
            
            Form{
                
                Section(""){
                    SecureField("Old Password", text: $oldPass)
                    
                }
                .font(.headline)
                .autocapitalization(.none)
                .disableAutocorrection(true)
               
                Section(""){
                    SecureField("New Password", text: $newPass)
                    SecureField("Confirm New Password", text: $confirmPass)
                    
                }
                .font(.headline)
                
                .autocapitalization(.none)
                .disableAutocorrection(true)
                

            }
            
            .navigationTitle("Change Password")
            
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
    PassView()
}
