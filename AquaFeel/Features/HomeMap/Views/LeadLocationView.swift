//
//  LeadLocationView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/4/24.
//

import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct LeadLocationView: View {
    var profile: ProfileManager
    @State var lead = LeadModel()
    @State var location: CLLocationCoordinate2D

    @StateObject var leadManager: LeadManager = .init()

    @State var showInfo = false

    @State var map: GMSMapView?
    @State var updated = false
    @State var marker = GMSMarker()
    /*
     @StateObject var tool = ToolManager()
     @StateObject var lassoTool: LassoTool = .init()
     @StateObject var markTool: MarkTool = .init()
     @StateObject var clusterTool: ClusterTool = .init()
     @StateObject var locationTool: LocationTool = .init()
     @StateObject var routeTool: RouteTool = .init()
     */
    var body: some View {
        GeometryReader { _ in

            HomeMapsRepresentable(location: $location) { map in

                let position = location
                /* lassoTool.setMap(map: map)
                 markTool.setMap(map: map)
                 clusterTool.setMap(map: map)
                 locationTool.setMap(map: map)
                 routeTool.setMap(map: map)

                 tool.initTool(mode: .lasso, tool: lassoTool)
                 tool.initTool(mode: .marker, tool: markTool)
                 tool.initTool(mode: .cluster, tool: clusterTool)
                 tool.initTool(mode: .location, tool: locationTool)
                 tool.initTool(mode: .route, tool: routeTool)
                 */

                print(lead.position)

                // let longitude = lead.position.longitude
                // let latitude = lead.position.latitude

                // map.camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: 18.0)
                map.camera = GMSCameraPosition(latitude: position.latitude, longitude: position.longitude, zoom: 16.0)
                map.settings.compassButton = true
                map.settings.zoomGestures = true
                map.settings.myLocationButton = true
                map.isMyLocationEnabled = true
                DispatchQueue.main.async {
                    self.map = map
                    self.setMark(lead: lead, map: self.map)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .overlay(alignment: .topLeading) {
                VStack {
                    Button {
                        showInfo.toggle()
                    } label: {
                        Image(systemName: "info")
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
                }
            }
        }
        
        .sheet(isPresented: $showInfo) {
            NavigationStack {
                CreateLead(profile: profile, lead: $lead, mode: 2, manager: leadManager, updated: $updated) { _ in
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

            
            .presentationContentInteraction(.scrolls)
        }

        .onChange(of: updated) { value in
            if value {
                DispatchQueue.main.async {
                    self.setMark(lead: lead, map: self.map)
                    updated = false
                }
            }
        }
        .onAppear {
            leadManager.token = profile.token

            leadManager.userId = profile.userId
            leadManager.role = profile.role
        }
    }

    func setMark(lead: LeadModel, map: GMSMapView?) {
        DispatchQueue.main.async {
            marker.position = lead.position
            marker.userData = lead
            marker.isTappable = true

            marker.userData = lead

            let circleIconView = getUIImage(name: lead.status_id.name)
            circleIconView.frame = CGRect(x: 120, y: 120, width: 30, height: 30)

            let circleLayer = CALayer()
            circleLayer.bounds = circleIconView.bounds
            circleLayer.position = CGPoint(x: circleIconView.bounds.midX, y: circleIconView.bounds.midY)
            circleLayer.cornerRadius = circleIconView.bounds.width / 2
            circleLayer.borderWidth = 0.0
            circleLayer.borderColor = UIColor.black.cgColor

            circleIconView.layer.addSublayer(circleLayer)

            marker.iconView = circleIconView

            marker.map = map
        }
    }
}

#Preview("Home") {
    MainAppScreenHomeScreenPreview()
}

/*
 #Preview {
     LeadLocationView()
 }
 */
