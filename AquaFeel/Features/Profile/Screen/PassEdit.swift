//
//  PassEdit.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 8/3/24.
//

import SwiftUI

struct PassEdit: View {
    @ObservedObject var loginManager: ProfileManager

    @Binding var completed: Bool

    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""

    @State private var confirmPassword: String = ""

    @State var user = User()
    @StateObject var manager = UserManager()

    @State var ok = false
    @State var error = false
    @State var message = ""
    var passwordsMatch: Bool {
        return newPassword == confirmPassword
    }

    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailPredicate.evaluate(with: user.email)
    }

    var isPasswordValid: Bool {
        return newPassword.count >= 8
    }

    var isFormValid: Bool {
        if oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
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
                Section(header: Text("")) {
                    TextField("Email", text: $loginManager.info.email)

                    SecureField("Old Password", text: $oldPassword)

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
                            Task {
                                let result = try? await loginManager.changePassword(email: loginManager.info.email, oldPassword: oldPassword, newPassword: newPassword)
                                if let result = result {
                                
                                    
                                    
                                    if result.statusCode == 200 {
                                        message = result.message
                                        ok = true
                                    } else{
                                        message = result.message
                                        error = true
                                    }
                                }
                                
                            }

                            /*

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
                              */

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
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
        }
        .padding()
        .onAppear {
            //resetForm()
        }
        .alert(message, isPresented: $error) {
            Button("Ok", role: .cancel) {
            }
        }
        .alert("Account Created Successfully", isPresented: $ok) {
            Button("Ok") {
                completed = true
                print(completed)
                // print(store.userData.auth)
            }
        } message: {
            Text("Password updated sucessfully")
        }
    }

    private func resetForm() {
        oldPassword = ""
        newPassword = ""
        confirmPassword = ""
    }
}

struct PassEdit_Previews1: PreviewProvider {
    static var previews: some View {
        PassEdit(loginManager: ProfileManager(), completed: .constant(false))
    }
}
