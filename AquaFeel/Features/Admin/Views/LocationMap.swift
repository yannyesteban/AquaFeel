//
//  LocationMap.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 15/4/24.
//

import SwiftUI


import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct LocationMap: View {
    var profile: ProfileManager
    @StateObject var adminManager = AdminManager()
    
    @Binding var updated: Bool
    
    
    @State var showSettings = true
    
    //@ObservedObject var leadManager: LeadManager
    //@StateObject var homeManager = HomeMapManager()
    //@StateObject var routeManager = RouteManager()
    
    @State var showUsers = false
    @State var showRoutes = false
    @State var showFilter = false
    
    @State var isRuteSelected = false
    
    @State var location: CLLocationCoordinate2D
    
    @StateObject var tool = ToolManager()
    
    @State var lassoEnded = false
    @State var markEnded = false
    @State var time = 0
    //@State var lead = LeadModel()
    @State var routeId: String?
    
   
    @State var user: User?
    @StateObject var locationTool: LocationTool = .init()
   
    @StateObject var usersTool: UsersTool = .init()
    
    var body: some View {
        GeometryReader { _ in
            
            HomeMapsRepresentable(location: $location) { map in
               
                locationTool.setMap(map: map)
                usersTool.setMap(map: map)
                
               
                tool.initTool(mode: .location, tool: locationTool)
                tool.initTool(mode: .route, tool: usersTool)
                
               
                usersTool.onDraw = { marker in
                   
                    DispatchQueue.main.async {
                        
                        markEnded = true
                        Task {
                            
                            if let userData = marker.userData as? User {
                               
                                self.user = userData
                                
                            } else {
                                
                                print("ERROR")
                            }
                            //self.lead = try! await leadManager.newFromLocation(location: marker.position)
                        }
                    }
                }
                
                var longitude = -98.5795//-122.02849058
                var latitude = 39.8283//37.33037224
                
                
                
                //longitude = location.longitude
                //latitude = location.latitude
                DispatchQueue.main.async {
                    // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
                    map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 3.0)
                    map.settings.compassButton = true
                    map.settings.zoomGestures = true
                    map.settings.myLocationButton = true
                    map.isMyLocationEnabled = true
                    usersTool.play()
                }
                
               
                
                
            }
            .edgesIgnoringSafeArea(.all)
            
            .overlay(alignment: .topLeading) {
                VStack {
                    Button {
                        showUsers.toggle()
                    } label: {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }.padding(10)
                    
                   
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showFilter = true
                } label: {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            }
        }
        //.navigationDestination(isPresented: $isRuteSelected) {}
        
        
        
        .sheet(isPresented: $markEnded) {
            
            if let user {
                NavigationStack {
                    UserDetailView(user: user)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    markEnded.toggle()
                                }) {
                                    Image(systemName: "chevron.backward")
                                }
                            }
                        }
                }
            }
            
           
        }
        .sheet(isPresented: $showUsers) {
            NavigationStack {
                
                UsersListView(users: adminManager.allSellers, selected: $adminManager.user)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showUsers.toggle()
                            }) {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    }
                //.presentationDetents([.fraction(0.2), .medium, .large])
            }
        }
        
        
        
        .onAppear{
            adminManager.userId = profile.userId
            adminManager.role = profile.role
            adminManager.token = profile.token
            
            Task{
                try? await adminManager.getUsers()
            }
            
            
        }
        
        .onReceive(adminManager.$allSellers){ users in
            
            DispatchQueue.main.async {
                //print(users.first?.firstName)
                usersTool.draw(users: users)
            }
            
        }
        
        .onReceive(adminManager.$user){ user in
            
            if let user, user.position.latitude != -180.0 {
                DispatchQueue.main.async {
                    showUsers.toggle()
                    print("latitude", user.position.latitude)
                    
                    self.usersTool.goto(position: user.position)
                }
            }
            
           
            
        }
       
       
    }
}



#Preview("Main") {
    MainAppScreenPreview()
}
