//
//  LoginScreen2.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

import SwiftUI

struct LoginView<MT: LoginMV>: View {
    
    //@Binding var userData : any LoginMV
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var loginModel:  MT
    @EnvironmentObject var store: MainStore<UserData>
    
    @State private var alert = false;
    @State private var texto = ""
       
    
    @State private var isLoading = false
    
    var body: some View {
                
        VStack {
            Form{
                
                
                
                TextField(
                    "Email",
                    text: $loginModel.user
                    
                )
                .font(.title2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                //.frame(width: .infinity, height: 40)
                //.frame(maxWidth: .infinity, maxHeight: 40)
                
                
                SecureField(
                    "Password",
                    text: $loginModel.pass
                )
                .font(.title2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                //.frame(width: .infinity, height: 40)
                //.frame(maxWidth: .infinity, maxHeight: 40)
                
                Button(
                    action: {
                        if isLoading {
                            return
                        }
                        isLoading = true
                        loginModel.login{
                            isLoading = false
                           
                        }
                    },
                    label: {
                        Text("Log in")
                    }
                )
                
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .shadow(radius: 3)
                .padding()
                //.frame(maxWidth: .infinity, alignment: .center)
                
                
            }
            
            if isLoading {
                ProgressView("Logging in...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
                
        Text("Forgot Password?")
            .font(.subheadline)
            .fontWeight(.semibold)
        
            .foregroundStyle(Color.orange)
            .onTapGesture {
                
            }
        
        Button("Register"){
            alert = true
        }.alert("Error", isPresented: $alert){
            Button("Ok", role: .cancel){
                print(store.userData.auth)
            }
        }
        
        
        
    }
}

#Preview {
    LoginView<LoginModelViewVM>().environmentObject(LoginModelViewVM())
}
