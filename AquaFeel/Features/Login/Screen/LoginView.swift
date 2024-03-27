//
//  LoginScreen2.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

import SwiftUI
import Contacts
import UIKit

func getAvatarImage() -> UIImage? {
    let contactStore = CNContactStore()
    let keysToFetch = [CNContactImageDataKey]
    
    let userName = NSUserName()
    let fullUserName = NSFullUserName()
    print("user name: ", userName, fullUserName)
    
    let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
    request.predicate = CNContact.predicateForContacts(matchingName: "Yo")
    
    do {
        var contacts = [CNContact]()
        try contactStore.enumerateContacts(with: request, usingBlock: { (contact, stop) in
            contacts.append(contact)
        })
        
        if let avatarData = contacts.first?.imageData {
            return UIImage(data: avatarData)
        }
    } catch {
        print(error)
    }
    
    return nil
}

func getAvatarImage2() -> UIImage? {
    let fileManager = FileManager.default
    let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let avatarURL = url.appendingPathComponent("avatar.jpg")
    
    if fileManager.fileExists(atPath: avatarURL.path) {
        return UIImage(contentsOfFile: avatarURL.path)
    }
    
    return nil
}

struct AvatarPickerView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            } else {
                Text("Selecciona un avatar")
                    .padding()
            }
            
            Button("Seleccionar Avatar") {
                self.isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: self.$selectedImage)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            
            picker.dismiss(animated: true)
        }
    }
}

struct LoginView<T: LoginProtocol>: View {
    @ObservedObject var loginManager: T

    // @Environment(\.scenePhase) private var scenePhase
    // @EnvironmentObject var loginManager: T
    // @EnvironmentObject var store: MainStore<UserData>

    @State private var alert = false
    @State private var completed = false
    @State var avatarImage: UIImage?

    var body: some View {
        VStack {
            Form {
                
                TextField(
                    "Email",
                    text: $loginManager.user
                )
                .font(.title2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                SecureField(
                    "Password",
                    text: $loginManager.pass
                )
                .font(.title2)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                HStack {
                    if loginManager.isLoading {
                        ProgressView("Logging in...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        Button(
                            action: {
                                print("isLoading a:", loginManager.isLoading)
                                
                                Task {
                                    loginManager.login(completion: { _, _ in
                                        
                                    })
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
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }

        Text("Forgot Password?")
            .font(.subheadline)
            .fontWeight(.semibold)

            .foregroundStyle(Color.orange)
            .onTapGesture {
            }

        Button("Register") {
            alert = true
            completed = false
        }
        .padding()
        .sheet(isPresented: $alert){
            NavigationStack {
                RegistrationView(completed: $completed)
                    /*.navigationBarItems(
                        trailing: Button("Close") {
                            alert.toggle()
                        }
                    )*/
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cancel") {
                                alert.toggle()
                            }
                        }
                    }
            }
        }
        /*
        .alert("Error", isPresented: $alert) {
            Button("Ok", role: .cancel) {
                // print(store.userData.auth)
            }
        }
         */
        .onAppear {
            //loginManager.user = "yannyesteban@gmail.com"
            //loginManager.pass = "Acceso1024"
            
            
        }
        .onChange(of: completed){ newValue in
            print("...", newValue)
            alert = !completed
            
        }
    }
}

#Preview {
    LoginViewPreview()
}

struct LoginViewPreview: View {
    @StateObject var manager = ProfileManager()

    var body: some View {
        LoginView(loginManager: manager)
    }
}
