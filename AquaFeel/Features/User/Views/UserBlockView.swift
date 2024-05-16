//
//  UserBlockView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/4/24.
//

import SwiftUI

struct UserBlockView: View {
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

    @State var blockConfirm = false
    @State var showMessage = false
    @State var effect = false

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
        if user.email.isEmpty || user.firstName.isEmpty || user.lastName.isEmpty {
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
            if showMessage {
                Label("Transaction completed correctly!", systemImage: "info.bubble.fill")
                    .padding(2)
                    .foregroundColor(Color.accentColor)
                    //.foregroundColor(.white)
                    //.cornerRadius(2)
                    .labelStyle(.titleAndIcon)
                    //.labelStyle(.iconOnly)

                    //.imageScale(.large)

                    .opacity(showMessage ? 1 : 0)
                    //.rotationEffect(.degrees(showMessage ? 90 : 0))

                    .scaleEffect(showMessage ? 1 : 0)
                    .font(.callout)

                    //.frame(height: effect ? .infinity : 0)
                    .padding()
            }
            Form {
                Section(header: Text("Basic Info")) {
                    Text("\(user.firstName) \(user.lastName)")
                    Text("\(user.role)")
                    Text("\(user.email)")
                }

                HStack {
                    Text(user.isBlocked ? "Unblock" : "Block")
                    Spacer()
                    Image(systemName: user.isBlocked ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 20, weight: .light))
                }
                .foregroundColor(user.isBlocked ? .green : .red)
                .onTapGesture {
                    blockConfirm.toggle()
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        .padding()

        .onAppear {
            // resetForm()
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

        .alert(isPresented: $blockConfirm) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Are you sure you want?"),
                primaryButton: .destructive(Text(user.isBlocked ? "Unblock" : "Block")) {
                    
                    Task {
                        do {
                            let result = try await userManager.blockUser(body: user)
                            if result {
                                do {
                                    let user = try await userManager.getUser(id: user._id)
                                    self.user = user
                                    withAnimation {
                                        startMessage()
                                    }
                                } catch {
                                    print("error")
                                }
                            }
                            print(result)
                        } catch {
                            print("error")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func startMessage() {
        showMessage = true
        effect = true
        // Oculta el mensaje después de 2 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showMessage = false
            effect = false
        }
    }

    private func resetForm() {
        user = User()
        user.role = "SELLER"
        confirmPassword = ""
    }
}
