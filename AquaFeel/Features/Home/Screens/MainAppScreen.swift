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
    @Environment(\.colorScheme) var colorScheme

    @State var isLoading: Bool = true
    @State var alert: Bool = false

    @State var showSettings = true

    @StateObject var profile = ProfileManager()

    @StateObject var user = UserModel()

    //@StateObject var offlineManager = OfflineManager()
    let appLocale = Locale.current.identifier

    @State var languaje: String?

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
                // RouteMapsScreen()

                HomeScreen(profile: profile)
                    .environment(\.locale, .init(identifier: languaje ?? appLocale))

                    .environmentObject(store)
                    .environmentObject(profile)
                    .onChange(of: scenePhase) { _ in
                    }
            } else {
                NavigationStack {
                    LoginScreen(loginManager: profile, isLoading: $isLoading)
                        .alert("Error", isPresented: $profile.error) {
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
        
        .preferredColorScheme(profile.schemeMode == .user ? colorScheme : profile.schemeMode == .dark ? .dark : .light)
        .task {
            loadDataFromAPI()
            await OfflineStore.load()
            await OfflineStore.start()

            /*
             Locale.availableIdentifiers.forEach { identifier in
                 print(identifier)
             }
              */
        }

        .onReceive(profile.$language) { value in

            switch value {
            case .english:
                languaje = "en-US"
            case .spanish:
                languaje = "es-US"
            case .user:
                languaje = appLocale
            }
        }

        .onChange(of: scenePhase) { phase in

            if phase == .inactive {
                Task {
                    try? await profile.saveProfile()
                    await profile.save()
                    await OfflineStore.save()
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
