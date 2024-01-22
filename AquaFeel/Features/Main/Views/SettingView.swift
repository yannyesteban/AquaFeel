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
    
    var body: some View {
        NavigationStack {
            Form {
                Group {
                    HStack{
                        Spacer()
                        VStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 20, weight: .light))
                            Text("Wolf Knight")
                                .font(.title)
                            Text("WolfKnight@kingdom.tv")
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
                    
                })
                
                Section(header: Text("PREFRENCES"), content: {
                    HStack{
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .light))
                        Text("Language")
                        Spacer()
                        Text("English")
                            .fontWeight(.bold)
                    }
                    HStack{
                        Image(systemName: "moon.stars")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $isDarkModeEnabled) {
                            Text("Dark Mode")
                        }
                    }
                    HStack{
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.system(size: 20, weight: .light))
                        Toggle(isOn: $downloadViaWifiEnabled) {
                            Text("offline")
                        }
                    }
                    HStack{
                        Image(systemName: "link")
                            .font(.system(size: 20, weight: .light))
                        Text("Play in Background")
                    }
                    
                })
                HStack{
                    Image(systemName: "power")
                        .font(.system(size: 20, weight: .light))
                    Text("Log out")
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

#Preview {
    SettingView()
}
