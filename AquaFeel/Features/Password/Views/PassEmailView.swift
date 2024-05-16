//
//  PassEmailView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/4/24.
//

import SwiftUI

struct FormRowView: View {
    var label: String
    @Binding var value: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }
}

struct PassEmailView: View {
    @State var email = ""
    @State var user = User()
    @StateObject var userManager = UserManager()
    @StateObject var passManager = PassManager()

    @State private var newPassword: String = ""

    @State private var confirmPassword: String = ""
    @State var error = false
    @State var message = ""
    @State var ok = false
    @State var waiting = false

    @Environment(\.presentationMode) var presentationMode

    var passwordsMatch: Bool {
        return newPassword == confirmPassword
    }

    var isPasswordValid: Bool {
        return newPassword.count >= 8
    }

    var isFormValid: Bool {
        if newPassword.isEmpty || confirmPassword.isEmpty {
            message = "All fields are required"
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
                if passManager.user._id == "" {
                    Section("please put your email") {
                        TextField("Email", text: $email)
                        if waiting {
                            HStack {
                                Spacer()
                                Text("Verifying")
                                ProgressView("")
                            }
                           
                        }
                        else {
                            Button(action: {
                                
                                Task {
                                    do {
                                        waiting = true
                                        try await passManager.getUserData(email: email)
                                        
                                        self.user = user
                                        
                                    } catch {
                                        self.error = true
                                        self.message = "User not found!"
                                        print("Error", error)
                                    }
                                    waiting = false
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Verify")
                                    
                                    Image(systemName: "magnifyingglass")
                                }
                            }
                        }
                        
                    }
                } else {
                    Section("Info") {
                        FormRowView(label: "Email:", value: $passManager.user.email)
                        FormRowView(label: "Name:", value: $passManager.user.firstName)
                        FormRowView(label: "Last Name:", value: $passManager.user.lastName)
                    }

                    Section("Enter New password") {
                        SecureField("New Password", text: $newPassword)

                        SecureField("Confirm new Password", text: $confirmPassword)

                        if !passwordsMatch {
                            Text("Passwords do not match")
                                .foregroundColor(.red)
                                .padding()
                        }
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
                                passManager.user.password = newPassword
                                userManager.save(body: passManager.user, mode: .edit) { isOk, _ in
                                    if isOk {
                                        message = "pass was updated"
                                        ok = true
                                    } else {
                                        message = "error pass was't updated"
                                        error = true
                                    }
                                }

                            },
                            label: {
                                Text("Change")
                            }
                        )
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .shadow(radius: 3)
                        // .padding()

                        .disabled(!passwordsMatch)
                    }
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
            }
        }
        .alert(message, isPresented: $error) {
            Button("Ok", role: .cancel) {
                
            }
        }
        .alert("Info", isPresented: $ok) {
            Button("Ok") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Password updated sucessfully")
        }
        .task {
           
        }
    }

    private func resetForm() {
        newPassword = ""
        confirmPassword = ""
    }
}

#Preview {
    PassEmailView()
}
