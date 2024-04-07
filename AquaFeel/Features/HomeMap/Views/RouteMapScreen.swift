//
//  HomeMap2.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/4/24.
//

import GoogleMaps
import SwiftUI

struct RouteMapScreen: View {
    var profile: ProfileManager
    @State var routeId: String = "6610a1335cc75bdb59dd72b0" // 6608693c5cc75bdb59dcef06" // "660392ab5cc75bdb59dca01b"
    // @StateObject var mapManager = MapManager()

    @Binding var updated: Bool
    @EnvironmentObject var store: MainStore<UserData>

    @State var showSettings = true

    @ObservedObject var leadManager: LeadManager
    @StateObject var routeManager = RouteManager()
    @StateObject var homeManager = HomeMapManager()

    @State var showFilter = false

    @State var location: CLLocationCoordinate2D = CLLocationCoordinate2D()

    @StateObject var tool = ToolManager()

    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false

    @State var yDragTranslation: CGFloat = 0

    @State var popupVisible = false
    @State var scrollViewHeight: CGFloat = -50
    @State var showInfo = false

    @StateObject var lassoTool: LassoTool = .init()
    @StateObject var markTool: MarkTool = .init()
    @StateObject var clusterTool: ClusterTool = .init()
    @StateObject var locationTool: LocationTool = .init()
    @StateObject var routeTool: RouteTool = .init()
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                HomeMapsRepresentable(location: $location) { map in
                    lassoTool.setMap(map: map)
                    markTool.setMap(map: map)
                    // clusterTool.setMap(map: map)
                    locationTool.setMap(map: map)
                    routeTool.setMap(map: map)

                    tool.initTool(mode: .lasso, tool: lassoTool)
                    tool.initTool(mode: .marker, tool: markTool)
                    // tool.initTool(mode: .cluster, tool: clusterTool)
                    tool.initTool(mode: .location, tool: locationTool)
                    tool.initTool(mode: .route, tool: routeTool)

                    var longitude = -74.0060
                    var latitude = 40.7128

                    longitude = location.longitude
                    latitude = location.latitude

                    // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
                    map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 16.0)
                    map.settings.compassButton = true
                    map.settings.zoomGestures = true
                    // map.settings.myLocationButton = true
                    // map.isMyLocationEnabled = true

                    tool.playTool(.location)
                }                
                .edgesIgnoringSafeArea(.all)
                .overlay(alignment: .topTrailing) {
                    VStack {
                        Button {
                            routeTool.lead?.makePhoneCall()

                        } label: {
                            Image(systemName: "phone")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .disabled(routeTool.lead?.phone.isEmpty ?? true || routeTool.lead == nil)
                        .padding(10)
                        Button {
                            routeTool.lead?.sendSMS()
                        } label: {
                            Image(systemName: "message")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .disabled(routeTool.lead?.phone.isEmpty ?? true || routeTool.lead == nil)
                        .padding(10)

                        Button {
                            routeTool.lead!.openGoogleMaps()
                        } label: {
                            Image(systemName: "globe")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .disabled(routeTool.lead == nil)
                        .padding(10)
                    }
                }
                .overlay(alignment: .topLeading) {
                    VStack {
                        Button {
                            routeTool.setBounds()
                        } label: {
                            Image(systemName: "viewfinder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }

                        Button(action: {
                            loadApi()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }.padding(10)

                        Button(action: {
                            locationTool.myLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }.padding(10)
                    }
                }

                HStack {
                    VStack(alignment: .leading) {
                        Spacer()

                        HStack {
                            Button(action: {
                                routeTool.prevMark()
                            }) {
                                Image(systemName: "arrow.left.circle")

                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.blue)
                                    .padding()

                                // .shadow(radius: 10)
                            }

                            if routeTool.lead != nil {
                                HStack {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .center) {
                                            SuperIcon2(status: Binding(
                                                get: { getStatusType(from: routeTool.lead?.status_id.name ?? "") },
                                                set: { _ in
                                                }
                                            ))
                                            .frame(width: 34, height: 34)

                                            Text("# \(routeTool.lead?.routeOrder ?? 0)")

                                                .font(.headline)
                                                .foregroundColor(Color.accentColor)
                                        }
                                        .padding(3)

                                        VStack(alignment: .leading) {
                                            Text("\(routeTool.lead?.first_name ?? "") \(routeTool.lead?.last_name ?? "")")
                                                .font(.headline)
                                                .foregroundColor(Color.black)

                                            Text("\(routeTool.lead?.street_address ?? "")")
                                                .font(.subheadline)
                                        }

                                        Spacer()
                                    }
                                    .foregroundColor(Color.black.opacity(0.8))

                                    .background(Color.white.opacity(0.7))

                                    .cornerRadius(10)
                                    .padding(0)
                                }
                                .onTapGesture {
                                    showInfo.toggle()
                                }

                            } else {
                                Spacer()
                            }

                            Button(action: {
                                routeTool.nextMark()
                            }) {
                                Image(systemName: "arrow.right.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }

                CitiesList {
                    self.zoomInCenter = false
                    self.expandList = false
                } handleAction: {
                    self.expandList.toggle()
                }.background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(
                        x: 0,
                        y: geometry.size.height - (expandList ? scrollViewHeight + 150 : scrollViewHeight)
                    )
                    .offset(x: 0, y: self.yDragTranslation)
                    .animation(.spring(), value: self.yDragTranslation)
                    .gesture(
                        DragGesture().onChanged { value in
                            self.yDragTranslation = value.translation.height
                        }.onEnded { value in
                            self.expandList = (value.translation.height < -120)
                            self.yDragTranslation = 0
                        }
                    )
                    .shadow(radius: 10)
            }
        }
        .sheet(isPresented: $showInfo) {
            NavigationStack {
                CreateLead(profile: profile, lead: Binding<LeadModel>(
                    get: { routeTool.lead ?? LeadModel() },
                    set: { routeTool.lead = $0 }
                ), mode: 2, manager: leadManager, updated: .constant(false)) { result in
                    if result {
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showInfo.toggle()
                        }) {
                            Image(systemName: "arrow.left")
                        }
                    }
                }
            }
        }

        .onChange(of: popupVisible) { value in
            withAnimation {
                if value {
                    self.scrollViewHeight = 100
                } else {
                    scrollViewHeight = -50
                }
            }
        }
        .onAppear {
            
            loadApi()
            
        }
    }

    func loadApi() {
        Task {
            if routeId != "" {
                let response = try? await routeManager.getRoute(routeId: routeId)
                if let tool1 = tool.mapTools[.route] as? RouteTool { // routeTool{}
                    tool1.route = response
                   
                    tool1.drawRoute(routes: response?.routes ?? [])
                   
                }
            }
        }
    }
}

#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}