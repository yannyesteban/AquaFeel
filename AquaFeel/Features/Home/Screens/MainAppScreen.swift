//
//  MainAppScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/2/24.
//

import GoogleMaps
import SwiftUI

struct MainAppScreen: View {
    // @StateObject private var store = MainStore<UserData>() //AppStore()
    @EnvironmentObject var store: MainStore<UserData>
    @Environment(\.scenePhase) private var scenePhase

    @State var isLoading: Bool = true
    @State var alert: Bool = false

    @State var showSettings = true

    @StateObject var profile = ProfileManager()
    // @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")

    @StateObject var user = UserModel()

    // @State var mode = false
    // @State var showSettings = true
    // @State var path = GMSMutablePath()
    func loadDataFromAPI() {
        // Simular una carga remota desde una API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 30)) {
                
                isLoading = false
                store.test = "always"

              
            }
        }
    }

    var body: some View {
        VStack {
            if profile.info.isVerified{
                HomeScreen(profile: profile)
                    // .environmentObject(lead)
                    .environmentObject(store)
                    .environmentObject(profile)
                    .onChange(of: scenePhase) { phase in

                     
                    }
            } else {
                //Text("Role: \(profile.role)")
                //Text("User: \(profile.userId)")
                NavigationStack {
                    
                    LoginScreen(loginManager: profile, isLoading: $isLoading)
                        .alert("Error", isPresented: $alert) {
                            Button("Ok", role: .cancel) {
                                print(store.userData.auth)
                            }
                        } message: {
                            Text("System access was denied")
                        }

                    /* Task{
                     do {
                     print("stop one")
                     //store.userData.email = "xxx"
                     try await store.save(userData: store.userData)
                     }catch{
                     print("error one")
                     fatalError(error.localizedDescription)
                     }
                     } */
                }
                .environmentObject(profile)
                .environmentObject(store)
                // .environmentObject(lead)
                
                .onChange(of: scenePhase) { phase in
                    
                    if phase == .inactive && false{
                        // store.userData.auth = false

                        Task {
                            do {
                                print("stop one")
                                store.userData.test = "feliz dia 2005"
                                try await saveFile(userData: store.userData, name: "AquaFeel.data")

                                // try await store.save(userData: store.userData)
                            } catch {
                                print("error one")
                                fatalError(error.localizedDescription)
                            }
                        }
                        print("Out")
                        // print(store.userData)
                    }
                }
            }
        }
        .task {
            do {
               
                //await loginManager.load()
                //let x:UserData = try await load(name: "AquaFeel.data")
                //print(x)
                //print("1.0")
               // try await store.load()
                //print("1.0.1")
                //store.userData = try await loadFile(name: "AquaFeel.data")
                //print("1.1", store.userData)
                //print(store.userData.test)
                //print("1.2")
                loadDataFromAPI()
                print("1.3", profile.userId)
                // print(store.userData)
                
                profile.saveAction = { _ in
                    print("1.4")
                    /*
                     DispatchQueue.main.async{
                     print("isValid", isValid)
                     print(loginModelView)
                     store.userData.auth = isValid
                     alert = !isValid
                     
                     if isValid {
                     let query = LeadQuery()
                     .add(.id,loginModelView.id)
                     
                     user.get(query: query)
                     }
                     
                     }
                     */
                }
                print("1.5")
                // loginModelView.user = "yanny"
            } catch {
                print("Error 2.0", error)
            }
        }

        .onReceive(profile.$isLoading) { x in

            //print("$isLoading: ", x)
            //print("$isLoading: 1.0 ", loginManager.auth)
            //print("$isLoading: e.0 ", loginManager.isLoading)
        }
        .onReceive(profile.$auth) { auth in

            if auth {
                /*
                DispatchQueue.main.async {
                    store.role = loginManager.role
                    store.id = loginManager.id
                    store.user = loginManager.info.email
                    store.firstName = loginManager.info.firstName
                    store.lastName = loginManager.info.lastName

                    store.avatar = "https://api.aquafeelvirginia.com/uploads/1675384908187-4C2AC28B-C68B-4876-9542-15E2782B6F07.jpg"

                    store.avatar = "https://api.aquafeelvirginia.com/uploads/\(loginManager.info.avatar ?? "")"

                    //print("yes: 1.0 ", loginManager.auth)
                    //print("yes: e.0 ", loginManager.isLoading)
                   
                    
                    
                    
                }
                 
                 */
            }
        }

        .onReceive(profile.$begin) { begin in

            /*
            if begin {
                let isValid = loginManager.auth
                store.role = loginManager.role
                print("isValid", isValid, loginManager, loginManager.role)
                print(loginManager)
                store.token = loginManager.token
                store.userData.auth = isValid
                alert = !isValid
                user.token = loginManager.token
                if isValid {
                    let query = LeadQuery()
                        .add(.id, loginManager.id)

                    user.get(query: query)
                }
            }
             */
        }
        .onReceive(user.$user) { u in
            
            /*
            print("Alpha")
            print(u)
            DispatchQueue.main.async {
                print("Betha \(u.email) \(u._id): \(u.role)")
                print(u._id)
                print(u.firstName)
                store.id = u._id
                store.user = u.email
                store.firstName = u.firstName
                store.lastName = u.lastName
                // store.role = u.role
                store.avatar = "https://api.aquafeelvirginia.com/uploads/1675384908187-4C2AC28B-C68B-4876-9542-15E2782B6F07.jpg"

                store.avatar = "https://api.aquafeelvirginia.com/uploads/\(u.avatar ?? "")"
            }
             */
        }

        .onChange(of: scenePhase) { phase in

            print("Saving User Info...", phase)
            if phase == .inactive {
                Task {
                    
                    try? await profile.saveProfile()
                    await profile.save()
                    print("Save successful ...")
                    
                }
            }
        }
    }
}

#Preview {
    MainAppScreenPreview()
}

struct MainAppScreenPreview: View {
    @StateObject private var store = MainStore<UserData>() // AppStore()
    var body: some View {
        MainAppScreen()
            .environmentObject(store)
    }
}
