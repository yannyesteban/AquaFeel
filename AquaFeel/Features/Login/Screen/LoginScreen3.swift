//
//  LoginScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import SwiftUI

struct LoginScreen3: View {
    @Binding var userData: UserData
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel(email: "", password: "")
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void
    
    @State private var alert = false;
    @State private var texto = ""
    var body: some View {
        
        ZStack{
            Color(.white).ignoresSafeArea()
            VStack{
                HStack{
                    Text("Aquafeel").font(.title2).foregroundStyle(Color.accentColor)
                    Text("2.0").font(.title2)
                }.padding().bold()
                
                Image("Logo1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundColor(Color.blue)
                    .backgroundStyle(.yellow)
                
                Text("Welcome back!")
                    .font(.title)
                    .padding()
                
                Form{
                    TextField(
                        "Email",
                        text: $userData.user
                        
                    )
                    .font(.title2)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(width: .infinity, height: 40)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    
                    
                    SecureField(
                        "Password",
                        text: $userData.pass
                    )
                    .font(.title2)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(width: .infinity, height: 40)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    
                    
                    Button(
                        action: viewModel.login,
                        label: {
                            Text("Log in")
                            
                            
                            
                            /*.font(.system(size: 24, weight: .bold, design: .default))
                             .frame(maxWidth: .infinity, maxHeight: 60)
                             .foregroundColor(Color.white)
                             .background(Color.blue)
                             .cornerRadius(10)*/
                        }
                    )
                    
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .shadow(radius: 3)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                                        
                }
                               
                
                Text("Forgot Password?")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(25)
                
                    .foregroundStyle(Color.orange)
                    .onTapGesture {
                        
                    }
                Spacer()
                Button("Register"){
                    alert = true
                }.alert("Error", isPresented: $alert){
                    Button("Ok", role: .cancel){
                        
                    }
                }
                
                
            }
        }
        
        if(1==0){
            ZStack{
                Color(.white).ignoresSafeArea()
                VStack {
                    HStack{
                        Text("Aquafeel").font(.title2).foregroundStyle(Color.accentColor)
                        Text("2.0").font(.title2)
                    }.padding().bold()
                    //Spacer()
                    Image("Logo1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .foregroundColor(Color.blue)
                        .backgroundStyle(.yellow)
                    
                    Text("Welcome back")
                        .font(.title)
                        .padding()
                    
                    Form{
                        
                        
                        Section("Contact Info"){
                            TextField("First Name", text: $texto)
                            TextField("Last Name", text: $texto)
                        }
                    }
                    TextField(
                        "Email",
                        text: $userData.user
                        
                    ).autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    //.padding()
                    
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.top, 20)
                    
                    
                        .padding(.horizontal, 30)
                        .padding(.bottom, 15)
                    Divider()
                    SecureField(
                        "Password",
                        text: $userData.pass
                    )
                    .padding(30)
                    .padding(.top, 20)
                    
                    Button(
                        action: viewModel.login,
                        label: {
                            Text("Log in")
                            /*.font(.system(size: 24, weight: .bold, design: .default))
                             .frame(maxWidth: .infinity, maxHeight: 60)
                             .foregroundColor(Color.white)
                             .background(Color.blue)
                             .cornerRadius(10)*/
                        }
                    )
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .shadow(radius: 3)
                    .padding()
                    
                    Text("Forgot Password?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(25)
                    
                        .foregroundStyle(Color.orange)
                        .onTapGesture {
                            
                        }
                    Button("Register"){
                        alert = true
                    }
                }
                
                
                
                
            }
            
            
            VStack {
                
                
                
                VStack {
                    Section(){
                        TextField(
                            "Email",
                            text: $userData.user
                            
                        )
                    }
                    //.navigationTitle("email")
                    
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.top, 20)
                    
                    Divider()
                    
                    Section() {
                        TextField(
                            "Password",
                            text: $userData.pass
                        )
                        .padding(.top, 20)
                        
                    }
                    
                    Divider()
                }
                .alert("Error", isPresented: $alert){
                    Button("Ok", role: .cancel){
                        
                    }
                }
                
                Spacer()
                Button("Register"){
                    alert = true
                }
                
            }
            .padding(30)
            .onChange(of: scenePhase){phase in
                if phase == .inactive{
                    print("save action")
                    saveAction()
                }
                
            }
        }
        
        
        
    }
}

#Preview {
    //@State var store = UserData()
    LoginScreen3(userData: .constant(UserData())){
        print("error one")
    }
}

