//
//  AquaFeelApp.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import SwiftUI
import GoogleMaps

@main
struct AquaFeelApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegateq.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var store = MainStore<UserData>() //AppStore()
    
    
    var body: some Scene {
        WindowGroup {
            
            //testLeadList()
            
            //ContentView()
            
           MainAppScreen()
                .environmentObject(store)
                
            
            
            
        }
    }
}
