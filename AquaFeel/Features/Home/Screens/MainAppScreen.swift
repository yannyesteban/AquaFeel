//
//  MainAppScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/2/24.
//

import GoogleMaps
import SwiftUI

struct MainAppScreen: View {
    @EnvironmentObject var store: MainStore<UserData>
    @Environment(\.scenePhase) private var scenePhase

    @State var isLoading: Bool = true
    @State var alert: Bool = false

    @State var showSettings = true

    @StateObject var profile = ProfileManager()

    @StateObject var user = UserModel()

    func loadDataFromAPI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 30)) {
                isLoading = false
                store.test = "always"
            }
        }
    }

    var body: some View {
        VStack {
            if profile.info.isVerified {
                //RouteMapsScreen()
                
                HomeScreen(profile: profile)
                    
                    .environmentObject(store)
                    .environmentObject(profile)
                    .onChange(of: scenePhase) { _ in
                    }
            } else {
                NavigationStack {
                    LoginScreen(loginManager: profile, isLoading: $isLoading)
                        .alert("Error", isPresented: $alert) {
                            Button("Ok", role: .cancel) {
                                print(store.userData.auth)
                            }
                        } message: {
                            Text("System access was denied")
                        }
                }
                .environmentObject(profile)
                .environmentObject(store)

                .onChange(of: scenePhase) { phase in

                    if phase == .inactive && false {
                        Task {
                            do {
                                try await saveFile(userData: store.userData, name: "AquaFeel.data")

                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
        .task {
            loadDataFromAPI()
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
