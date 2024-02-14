//
//  OptionView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct SettingView: View {
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
    
    var body: some View {
        NavigationStack {
            Form {
                Group {
                    HStack{
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
                    }
                }
                
                Section(header: Text("CONTENT"), content: {
                    HStack{
                        Image(systemName: "star")
                        
                        Text("Favorites")
                    }
                    
                    HStack{
                        Image(systemName: "person.fill")
                            .font(.system(size: 20, weight: .light))
                        Text("Profile")
                    }
                    
                    HStack{
                        Image(systemName: "map")
                            .font(.system(size: 20, weight: .light))
                        Picker("Map Api", selection: $mapApi){
                            ForEach(apis, id: \.self){ item in
                                Text(item)
                            }
                        }
                    }
                    
                })
                
                Section(header: Text("PREFRENCES"), content: {
                    HStack{
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .light))
                        
                        Picker("Languaje", selection: $language){
                            ForEach(languages, id: \.self){ item in
                                Text(item)
                            }
                        }
                        
                        
                        
                    }
                    
                    HStack{
                        Image(systemName: "moon.stars")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $isDarkModeEnabled) {
                            Text("Dark mode")
                        }
                    }
                    HStack{
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $downloadViaWifiEnabled) {
                            Text("Offline")
                        }
                    }
                    HStack{
                        Image(systemName: "link")
                            .font(.system(size: 20, weight: .light))
                        Text("Play in background")
                    }
                    
                })
                HStack{
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
                        store.userData.auth = false
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingDialog = false
                    }
                }
                
            }
            .navigationBarTitle("Settings")
            .onAppear{
                print(".......-----")
                user = "\(store.user)"
                name = "\(store.firstName) \(store.lastName)"
                print(store.firstName)
                print("TEST \(store.test)")
            }
        }
    }
}
/*
#Preview {
    SettingView()
}
*/
