//
//  ProfileScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var loginManager: ProfileManager
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""

    @State var showErrorMessage = false
    @State var errorMessage = ""

    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var showingImagePicker2 = false

    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                Section("Avatar") {
                    HStack {
                        AvatarView(imageURL: $loginManager.avatar)
                            .padding()

                        /* Button("Choose from Library") {
                             showingImagePicker.toggle()
                         }
                         .padding(0) */
                    }
                    Button(action: {
                        showingCamera = true
                    }) {
                        Label("Take Photo with Camera", systemImage: "camera")
                    }
                    .sheet(isPresented: $showingCamera) {
                        CameraView(image: $selectedImage) { image in

                            loginManager.uploadAvatar(image: image)
                        }
                    }

                    Button(action: {
                        showingImagePicker2.toggle()
                    }) {
                        Label("Choose from Library", systemImage: "photo")
                    }
                    .sheet(isPresented: $showingImagePicker2) {
                        AvatarPicker(selectedImage: $selectedImage, sourceType: .photoLibrary) { image in

                            loginManager.uploadAvatar(image: image)
                        }
                    }
                }

                Text(loginManager.info.email).foregroundStyle(.teal)
                Text(loginManager.info.role).foregroundStyle(.teal)

                Section("Basic Info") {
                    TextField("First Name", text: $loginManager.info.firstName)
                    TextField("Last Name", text: $loginManager.info.lastName)

                    /* HStack{
                         TextField("City", text: $texto)
                         TextField("State", text: $texto)
                     }
                     HStack{

                         TextField("Zip Code", text: $texto)
                         TextField("Country", text: $texto)
                     } */
                }
                .font(.headline)
                // .navigationTitle("email")

                .autocapitalization(.none)
                .disableAutocorrection(true)
                // .padding(.top, 20)
                // .navigationTitle("Contact Info")
                // .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                // .foregroundColor(.red)

                Section {
                    NavigationLink {
                        // PassView()
                        PassEdit(loginManager: loginManager, completed: .constant(false))
                            .navigationTitle("Change Password")
                    } label: {
                        Text("Change Password")
                        // existing contents…
                    }
                }

                .font(.headline)
            }
            .background(.blue)
            .navigationTitle("Update Profile")
            .alert(isPresented: $showErrorMessage) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingImagePicker) {
                // AvatarPicker(selectedImage: $selectedImage, sourceType: .photoLibrary)

                AvatarPicker(selectedImage: $selectedImage, sourceType: .photoLibrary) { image in

                    loginManager.uploadAvatar(image: image)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if loginManager.waiting {
                        ProgressView("")

                    } else {
                        Button {
                            errorMessage = loginManager.validProfile()

                            if errorMessage != "" {
                                showErrorMessage = true

                                return
                            }

                            Task {
                                try? await loginManager.saveProfile()
                            }

                        } label: {
                            Label("Save", systemImage: "externaldrive.fill")
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView(loginManager: ProfileManager())
}
