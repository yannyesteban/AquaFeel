//
//  HomeMap.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/3/24.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct HomeMap: View {
    var profile: ProfileManager
    @Binding var updated: Bool
    @EnvironmentObject var store: MainStore<UserData>

    @State var showSettings = true

    @ObservedObject var leadManager: LeadManager
    @StateObject var homeManager = HomeMapManager()
    @StateObject var routeManager = RouteManager()

    @State var showInfo = false
    @State var showRoutes = false
    @State var showFilter = false
    @State var showLeads = false

    @State var isRuteSelected = false

    @State var location: CLLocationCoordinate2D

    @StateObject var tool = ToolManager()

    @State var lassoEnded = false
    @State var markEnded = false
    @State var time = 0
    @State var lead = LeadModel()
    @State var routeId: String?

    @StateObject var lassoTool: LassoTool = .init()
    @StateObject var markTool: MarkTool = .init()
    @StateObject var clusterTool: ClusterTool = .init()
    @StateObject var locationTool: LocationTool = .init()
    @StateObject var routeTool: RouteTool = .init()

    var body: some View {
        GeometryReader { _ in

            HomeMapsRepresentable(location: $location) { map in
                lassoTool.setMap(map: map)
                markTool.setMap(map: map)
                clusterTool.setMap(map: map)
                locationTool.setMap(map: map)
                routeTool.setMap(map: map)

                tool.initTool(mode: .lasso, tool: lassoTool)
                tool.initTool(mode: .marker, tool: markTool)
                tool.initTool(mode: .cluster, tool: clusterTool)
                tool.initTool(mode: .location, tool: locationTool)
                tool.initTool(mode: .route, tool: routeTool)

                clusterTool.onDraw = { marker in
                    DispatchQueue.main.async {
                        showInfo = true

                        if let userData = marker.userData as? LeadModel {
                            lead = userData
                        }
                    }
                }

                markTool.onDraw = { marker in

                    DispatchQueue.main.async {
                        markEnded = true
                        Task {
                            self.lead = try! await leadManager.newFromLocation(location: marker.position)
                        }
                    }
                }

                var longitude = -74.0060
                var latitude = 40.7128

                longitude = location.longitude
                latitude = location.latitude

                // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
                map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 16.0)
                map.settings.compassButton = true
                map.settings.zoomGestures = true
                map.settings.myLocationButton = true
                map.isMyLocationEnabled = true

                // tool.playTool(.location)
            }
            .edgesIgnoringSafeArea(.all)

            .overlay(alignment: .topLeading) {
                VStack {
                    
                    Button {
                        showLeads.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding(10)
                    
                    Button {
                        tool.toggle(.marker, .cluster)
                    } label: {
                        Image(systemName: tool.mode == .marker ? "eraser.fill" : "pin.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }

                    Button(action: {
                        tool.toggle(.lasso, .cluster)
                    }) {
                        Image(systemName: tool.mode == .lasso ? "eraser.fill" : "hand.draw.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }.padding(10)

                    Button(action: {
                        showRoutes = true
                    }) {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        } else {
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }

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
        .navigationDestination(isPresented: $isRuteSelected) {
            RouteMapScreen(profile: profile, routeId: routeId ?? "", updated: .constant(false), leadManager: LeadManager())
        }
        .sheet(isPresented: $showLeads) {
            NavigationStack {
                LeadsMapsView(profile: profile, manager: leadManager, clusterTool: clusterTool, updated: $updated)
            }
          
        }
        .sheet(isPresented: $showFilter) {
            FilterOption(profile: profile, filter: $leadManager.filter, filters: $leadManager.leadFilter, statusList: leadManager.statusList, usersList: leadManager.users) {
                // lead.reset()
                leadManager.resetFilter()
                leadManager.runLoad()
            }
        }

        .sheet(isPresented: $lassoTool.ready) {
            PathOptionView(profile: profile, leads: $leadManager.leads, path: $lassoTool.path, leadManager: leadManager, updated: $updated)
                .presentationDetents([.fraction(0.35), .medium, .large])
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $markEnded) {
            CreateLead(profile: profile, lead: $lead, mode: 1, manager: leadManager, updated: .constant(false)) { result in
                if result {
                    // manager.leads.append(lead)
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            NavigationStack {
                CreateLead(profile: profile, lead: $lead, mode: 0, manager: leadManager, updated: $updated) { _ in
                }
            }

            .presentationDetents([.fraction(0.2), .medium, .large])
            .presentationContentInteraction(.scrolls)
        }

        .sheet(isPresented: $showRoutes) {
            NavigationStack {
                RoutesView(profile: profile, routeManager: routeManager, selected: $isRuteSelected, routeId: $routeId)

                    .presentationContentInteraction(.scrolls)

                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showRoutes.toggle()
                            }) {
                                Image(systemName: "arrow.left")
                            }
                        }
                    }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                leadManager.initFilter { _, _ in

                    print("completation loadStatus")
                }
            }
        }

        .onReceive(leadManager.$leads) { _ in

            DispatchQueue.main.async {
                let markers = leadManager.getMarkers()

                clusterTool.loadMarkers(markers: markers)
            }
        }
        .onReceive(leadManager.$leadFilter) { filter in

            DispatchQueue.main.async {
                profile.info.leadFilters = filter
            }
        }
        .onReceive(routeManager.$mapRoute) { mapRoute in
            if let mapRoute {
                routeTool.drawRoute(routes: mapRoute.routes)
            }
        }
    }
}
/*
#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}
*/


#Preview("Main") {
    MainAppScreenPreview()
}
/*
 #Preview {
     HomeMap(profile: ProfileManager(), updated: .constant(false), manager: LeadManager(), location: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060) )
 }
 */
