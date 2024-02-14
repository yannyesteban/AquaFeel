//
//  HomeScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

import SwiftUI

struct HomeScreen: View {
    
    @State public var option: String
    @State public var showOption: Bool = false
    @EnvironmentObject var store: MainStore<UserData>
    
    
    var body: some View {
        NavigationStack {        
            TabView {
                Route()
                    .badge(2)
                    .tabItem {
                        Label("Received", systemImage: "house")
                    }
                    .navigationTitle("Configuración")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button{
                                showOption = true
                            } label: {
                                Image(systemName: "gear")
                            }
                            
                        }
                    }.sheet(isPresented: $showOption) {
                        SettingView()
                            .environmentObject(store)
                    }
                //MapView()
                //MapScreen()
                LeadMap()
                    .edgesIgnoringSafeArea(.all)
                    .tabItem {
                        Label("Statics", systemImage: "chart.bar")
                    }
                testLeadList()
                    .badge("!")
                    .tabItem {
                        Label("Lead", systemImage: "person.badge.plus")
                    }
                    .navigationBarTitle("Leads List")
                 
            }
        }
        
        
        
    }
}

struct OptionA: View {
    var body: some View {
        Text("Hello, OptionA!")
    }
}


struct OptionB: View {
    var body: some View {
        Text("Hello, OptionB!")
    }
}

#Preview {
    HomeScreen(option:"b")
}
