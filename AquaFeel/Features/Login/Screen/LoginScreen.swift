//
//  LoginScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/1/24.
//

import SwiftUI

struct LoginScreen: View {
    @ObservedObject var loginManager: ProfileManager
    @Binding var isLoading: Bool
    @State private var appName = "app"
    @State private var appVersion = "1.0"

    var body: some View {
        ZStack {
            // Color(.white).ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Text(appName).font(.title2).foregroundStyle(Color.accentColor)
                        //Text(appVersion).font(.title2)
                    }.padding().bold()

                    Image("Logo1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .foregroundColor(Color.blue)
                        .backgroundStyle(.yellow)
                }

                Text("Welcome back!")
                    .font(.title3)
                    .padding()

                if isLoading {
                    ProgressView("Loading...")

                } else {
                    Spacer()
                    LoginView(loginManager: loginManager)
                        .padding(isLoading ? 20 : 0)

                        .animation(.easeOut, value: isLoading)
                }
            }
        }
        // .rotationEffect(.degrees(isLoading ? 45 : 30))
        .transition(.slide)
        .animation(.easeInOut, value: isLoading)
        .onAppear {
            if let infoDict = Bundle.main.infoDictionary,
               let appName = infoDict["CFBundleName"] as? String,
               let appVersion = infoDict["CFBundleShortVersionString"] as? String {
                self.appName = appName
                self.appVersion = appVersion
                print("Nombre de la aplicación: \(appName)")
                print("Versión de la aplicación: \(appVersion)")
            } else {
                print("No se pudo obtener la información de la aplicación desde Info.plist")
            }
        }
        
    }
}
/*
#Preview {
    LoginScreen(loginManager: .constant(LoginManager()), isLoading: .constant(false))
        .environmentObject(LoginManager())
}
*/
