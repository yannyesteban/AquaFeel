//
//  MainScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/1/24.
//

import SwiftUI

struct MainScreen: View {
   
    @State private var showOption = false
    @EnvironmentObject var store: MainStore<UserData>
    var body: some View {
        NavigationStack{
            
            Text("xx")
            
            Button("quit"){
                //store.userData.auth = false
                showOption = true
            }
       
        }
        
        
    }
}

#Preview {
    
    MainScreen().environmentObject(MainStore<UserData>())
}
