//
//  OptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct AvatarView: View {
    let imageURL: URL

    var size: CGFloat = 60
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.4)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            // .foregroundColor(.gray)
            @unknown default:
                fatalError("Unhandled case")
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct SettingView: View {
    @ObservedObject var loginManager: ProfileManager

    @State var isDarkModeEnabled: Bool = true
    @State var downloadViaWifiEnabled: Bool = false
    @State var language = "English"
    @State private var isShowingDialog = false

    @EnvironmentObject var store: MainStore<UserData>
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var profile: ProfileManager

    var languages: [String] = ["English", "Spanish", "German"]

    @State var mapApi = "Google Maps"
    var apis: [String] = ["Google Maps", "Open Street", "Apple Map"]

    @State var name = ""
    @State var user = ""
    @State var avatar = ""

    var body: some View {
        NavigationStack {
            Form {
                Group {
                    NavigationStack {
                        NavigationLink {
                            ProfileView(loginManager: loginManager)
                            
                        } label: {
                            HStack {
                                AvatarView(imageURL: URL(string: avatar) ?? URL(string: "defaultAvatarURL")!)
                                
                                VStack(alignment: .leading) {
                                    Text("\(loginManager.info.firstName) \(loginManager.info.lastName)")
                                    // .font(.caption)
                                    Text(user)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    Text("\(loginManager.info.role)")
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    
                }

                Section {
                    HStack {
                        Image(systemName: "map")
                            .font(.system(size: 20, weight: .light))
                        Picker("Map Api", selection: $loginManager.mapApi) {
                            Text("Google Maps").tag(AppMapApi.googleMaps)
                            Text("Apple Maps").tag(AppMapApi.appleMaps)
                            Text("Open Streets").tag(AppMapApi.openStreet)
                        }
                    }

                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .light))

                        Picker("Languaje", selection: $loginManager.language) {
                            Text("System").tag(AppLanguage.user)
                            Text("English").tag(AppLanguage.english)
                            Text("Spanish").tag(AppLanguage.spanish)
                            /*ForEach(languages, id: \.self) { item in
                                Text(item)
                            }*/
                        }
                    }

                    HStack {
                        
                        Image(systemName: "moon.stars")
                            .font(.system(size: 20, weight: .light))
                        Picker("Theme", selection: $loginManager.schemeMode) {
                            Text("System").tag(SchemeMode.user)
                            Text("Light").tag(SchemeMode.light)
                            Text("Dark").tag(SchemeMode.dark)
                            /*ForEach(languages, id: \.self) { item in
                             Text(item)
                             }*/
                        }
                        
                        
                       
                    }
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $loginManager.offline) {
                            Text("Offline")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $loginManager.playBackground) {
                            Text("Play in background")
                        }
                    }
                    
                   
                }
               
                HStack {
                    Text("Log out")
                    Spacer()
                    Image(systemName: "power")
                        .font(.system(size: 20, weight: .light))
                    
                }
                .foregroundColor(.red)
                .onTapGesture {
                    isShowingDialog = true
                }
                /*.confirmationDialog(
                    "are you sure to leave?",
                    isPresented: $isShowingDialog
                ) {
                    Button("Quit", role: .destructive) {
                        loginManager.info.isVerified = false
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingDialog = false
                    }
                }
                 */
            }
            
            .alert(isPresented: $isShowingDialog) {
                Alert(
                    title: Text("Confirmation"),
                    message: Text("are you sure to leave?"),
                    primaryButton: .destructive(Text("Quit")) {
                        loginManager.info.isVerified = false
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            
            .preferredColorScheme(profile.schemeMode == .user ? colorScheme : profile.schemeMode == .dark ? .dark : .light)
            .navigationBarTitle("Settings")
            .onAppear {
                user = "\(loginManager.info.email)"
                name = "\(loginManager.info.firstName) \(loginManager.info.lastName)"
                avatar = loginManager.info.avatar ?? ""
            }

            .onChange(of: isDarkModeEnabled) { value in
                DispatchQueue.main.async {
                    if value {
                        profile.colorScheme = .dark
                    } else {
                        profile.colorScheme = .light
                    }
                }
            }
        }
    }
}

/*
 #Preview {
     SettingView()
 }
 */

#Preview {
    MainAppScreenPreview()
}
