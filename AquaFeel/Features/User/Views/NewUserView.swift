//
//  NewUserView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/5/24.
//

import SwiftUI

struct NewUserView: View {
    @Binding var completed: Bool
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State var user = User()
    @StateObject var manager = UserManager()
    
    @State var ok = false
    @State var error = false
    @State var message = ""
    
    @Environment(\.presentationMode) var presentationMode
    
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
        if user.email.isEmpty || user.firstName.isEmpty || user.lastName.isEmpty || user.password.isEmpty {
            message = "All fields are required"
            error = true
            return false
        }
        
        if !isEmailValid {
            message = "Invalid email format"
            error = true
            return false
        }
        
        if !isPasswordValid {
            message = "Password must be at least 8 characters long"
            error = true
            return false
        }
        
        return true
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Sign Up")) {
                    TextField("Email", text: $user.email)
                    
                    TextField("First Name", text: $user.firstName)
                    
                    TextField("Last Name", text: $user.lastName)
                    
                    SecureField("Password", text: $user.password)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                    
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
                
                                
                HStack {
                    Button("Reset") {
                        resetForm()
                    }
                    Spacer()
                    Button(
                        action: {
                            if !isFormValid {
                                return
                            }
                            
                            
                            
                            manager.save(body: user, mode: .add) { _, record in
                                
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
                            
                        },
                        label: {
                            Text("Register")
                        }
                    )
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .shadow(radius: 3)
                    // .padding()
                    
                    .disabled(!passwordsMatch)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
        }
        .padding()
        .onAppear {
            resetForm()
        }
        .alert(message, isPresented: $error) {
            Button("Ok", role: .cancel) {
            }
        }
        .alert("Account Created Successfully", isPresented: $ok) {
            Button("Ok") {
                completed = true
                presentationMode.wrappedValue.dismiss()
                // print(store.userData.auth)
            }
        } message: {
            Text("You should verify that user's credentials.")
        }
    }
    
    private func resetForm() {
        user = User()
        user.role = "SELLER"
        confirmPassword = ""
    }
}
