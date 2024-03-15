//
//  AquaFeelApp.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import GoogleMaps
import SwiftUI

@main
struct AquaFeelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegateq.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @State private var store = MainStore<UserData>() // AppStore()

    var body: some Scene {
        WindowGroup {
            // LeadListHomeScreenPreview()
            // TestCreateLead()
            // testLeadList()
            // HomeScreen(option:"b")
            // ContentView()
            // LeadMap()                .edgesIgnoringSafeArea(.all)
            MainAppScreen().environmentObject(store)
        }
    }
}
