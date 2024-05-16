//
//  UserFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/4/24.
//

import SwiftUI

enum Role: String, CaseIterable {
   
    case SELLER
    case MANAGER
    case ADMIN
}


struct UserFormView: View {
    @Binding var completed: Bool
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State var user = User()
    @StateObject var userManager = UserManager()
    
    @State var ok = false
    @State var error = false
    @State var message = ""
    
    @State var showErrorMessage = false
    @State var errorMessage = ""
    @State var waiting = false
    
    var passwordsMatch: Bool {
        return user.password == confirmPassword
    }
    
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: user.email)
    }
    
    var isPasswordValid: Bool {
        return user.password.count >= 8
    }
    
    var isFormValid: Bool {
        if user.email.isEmpty || user.firstName.isEmpty || user.lastName.isEmpty  {
            message = "All fields are required"
            error = true
            return false
        }
        
        if !isEmailValid {
            message = "Invalid email format"
            error = true
            return false
        }
        /*
        if !isPasswordValid {
            message = "Password must be at least 8 characters long"
            error = true
            return false
        }
         */
        
        return true
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Email", text: $user.email)
                    
                    TextField("First Name", text: $user.firstName)
                    
                    TextField("Last Name", text: $user.lastName)
                    
                    //SecureField("Password", text: $user.password)
                    
                    //SecureField("Confirm Password", text: $confirmPassword)
                    
                    if !passwordsMatch {
                        Text("Passwords do not match")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                
                Section(header: Text("Role")) {
                    Picker("Role", selection: $user.role) {
                        ForEach(Role.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Verification")) {
                    Toggle("Verified", isOn: $user.isVerified)
                }
                
                
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        .padding()
        
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if waiting {
                    ProgressView("")
                    
                } else {
                    Button {
                        //errorMessage = loginManager.validProfile()
                        waiting = true
                        if !isFormValid {
                            error = true
                            
                            return
                        }
                        
                      
                        userManager.save(body: user, mode: .edit){ _, record in
                            waiting = false
                            if let record = record {
                                if record.user != nil {
                                    ok = true
                                } else {
                                    message = record.message
                                    error = true
                                }
                                
                            } else {
                                message = "Error Unknown"
                                error = true
                            }
                        }
                        
                    } label: {
                        Label("Save", systemImage: "externaldrive.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .onAppear {
            //resetForm()
        }
        .alert(message, isPresented: $error) {
            Button("Ok", role: .cancel) {
            }
        }
        .alert("User Record was modified Successfully", isPresented: $ok) {
            Button("Ok") {
                completed = true
                print(completed)
                // print(store.userData.auth)
            }
        } message: {
            Text(message)
        }
    }
    
    private func resetForm() {
        user = User()
        user.role = "SELLER"
        confirmPassword = ""
    }
}

#Preview {
    UserFormView(completed: .constant(false))
}
