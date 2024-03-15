//
//  OptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct AvatarView: View {
    let imageURL: URL

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
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            // .foregroundColor(.gray)
            @unknown default:
                fatalError("Unhandled case")
            }
        }
        .frame(width: 60, height: 60)
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
                            /* AvatarView(imageURL: URL(string: avatar) ?? URL(string: "defaultAvatarURL")!)
                             .padding() */
                        } label: {
                            HStack {
                                AvatarView(imageURL: URL(string: avatar) ?? URL(string: "defaultAvatarURL")!)
                                // .padding()
                                // .frame(width: 20, height: 20)
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
                    /* HStack{
                         Spacer()
                         VStack {

                             Image(systemName: "person.fill")
                                 .font(.system(size: 20, weight: .light))

                             Text("\(store.firstName) \(store.lastName)")

                                 .font(.title)
                             Text(user)
                                 .font(.subheadline)
                                 .foregroundColor(.gray)
                             Spacer()
                             Button(action: {
                                 print("Edit Profile tapped")
                             }) {
                                 Text("Edit Profile")
                                     .frame(minWidth: 0, maxWidth: .infinity)
                                     .font(.system(size: 18))
                                     .padding()
                                     .foregroundColor(.white)
                                     .overlay(
                                         RoundedRectangle(cornerRadius: 25)
                                             .stroke(Color.white, lineWidth: 2)
                                     )
                             }
                             .background(Color.blue)
                             .cornerRadius(25)
                         }
                         Spacer()
                     } */
                }

                Section(header: Text("CONTENT"), content: {
                    HStack {
                        Image(systemName: "star")

                        Text("Favorites")
                    }

                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .light))
                        Text("Profile")
                    }

                    HStack {
                        Image(systemName: "map")
                            .font(.system(size: 20, weight: .light))
                        Picker("Map Api", selection: $mapApi) {
                            ForEach(apis, id: \.self) { item in
                                Text(item)
                            }
                        }
                    }

                })

                Section(header: Text("PREFRENCES"), content: {
                    HStack {
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .light))

                        Picker("Languaje", selection: $language) {
                            ForEach(languages, id: \.self) { item in
                                Text(item)
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $isDarkModeEnabled) {
                            Text("Dark mode")
                        }
                    }
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $downloadViaWifiEnabled) {
                            Text("Offline")
                        }
                    }
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 20, weight: .light))
                        Text("Play in background")
                    }

                })
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 20, weight: .light))
                    Text("Log out")
                }
                .onTapGesture {
                    isShowingDialog = true
                }
                .confirmationDialog(
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
            }
            .navigationBarTitle("Settings")
            .onAppear {
                user = "\(loginManager.info.email)"
                name = "\(loginManager.info.firstName) \(loginManager.info.lastName)"
                avatar = loginManager.info.avatar ?? ""
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
