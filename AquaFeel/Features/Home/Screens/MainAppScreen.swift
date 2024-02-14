//
//  MainAppScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/2/24.
//

import SwiftUI
import GoogleMaps

struct MainAppScreen: View {
    
    //@StateObject private var store = MainStore<UserData>() //AppStore()
    @EnvironmentObject var store: MainStore<UserData>
    @Environment(\.scenePhase) private var scenePhase
    
    @State var isLoading: Bool = true
    @State var alert: Bool = false
    
    @State var showSettings = true
    
    @StateObject var loginModelView = LoginModelViewVM()
    @StateObject var lead = LeadViewModel(first_name: "Juan", last_name: "")
    
    @StateObject var user = UserModel()
    
    @State var mode = false
    //@State var showSettings = true
    @State var path = GMSMutablePath()
    func loadDataFromAPI() {
        // Simular una carga remota desde una API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 30)) {
                isLoading = false
                store.test = "always"
                
                print(".........\(store.test)")
            }
            
        }
    }
    
    var body: some View {
        
        VStack{
            if store.userData.auth{
                HomeScreen(option: "a")
                    .environmentObject(lead)
                    .environmentObject(store)
            }else{
                NavigationStack{
                    
                    
                    LoginScreen(isLoading: $isLoading)
                        .alert("Error", isPresented: $alert){
                            
                            Button("Ok", role: .cancel){
                                print(store.userData.auth)
                            }
                        }
                message: {
                    Text("System access was denied")
                }
                    
                    
                    /*Task{
                     do {
                     print("stop one")
                     //store.userData.email = "xxx"
                     try await store.save(userData: store.userData)
                     }catch{
                     print("error one")
                     fatalError(error.localizedDescription)
                     }
                     }*/
                }
                .environmentObject(loginModelView)
                .environmentObject(store)
                .environmentObject(lead)
                .task{
                    do {
                        try await store.load()
                        
                        
                        print(store.userData.test)
                        
                        loadDataFromAPI()
                        //print(store.userData)
                        
                        
                        
                        loginModelView.saveAction = { isValid in
                            
                            
                            DispatchQueue.main.async{
                                print("isValid", isValid)
                                print(loginModelView)
                                store.userData.auth = isValid
                                alert = !isValid
                                
                                if isValid {
                                    let query = LeadQuery()
                                        .add(.id,loginModelView.id)
                                    
                                    user.get(query: query)
                                }
                                
                            }
                            
                            
                            
                        }
                        //loginModelView.user = "yanny"
                    } catch {
                        print ("Error 2.0")
                    }
                }
                
                .onChange(of: scenePhase) { phase in
                    print("Out ??")
                    if phase == .inactive {
                        //store.userData.auth = false
                        store.userData.test = "feliz dia"
                        Task{
                            do {
                                print("stop one")
                                
                                try await store.save(userData: store.userData)
                            }catch{
                                print("error one")
                                fatalError(error.localizedDescription)
                            }
                        }
                        print("Out")
                        //print(store.userData)
                    }
                }
            }
        }
        .onReceive(user.$user) { u in
            
            print("Alpha")
            print(u)
            DispatchQueue.main.async{
                print("Betha \(u.email)")
                print(u.firstName)
                store.user = u.email
                store.firstName = u.firstName
                store.lastName = u.lastName
                store.test = "never"
            }
            
            
            
            
        }
        
    }
}



#Preview {
    MainAppScreenPreview()
}


struct MainAppScreenPreview:View {
    @StateObject private var store = MainStore<UserData>() //AppStore()
    var body: some View {
        MainAppScreen()
           // .environmentObject(store)
    }
}



