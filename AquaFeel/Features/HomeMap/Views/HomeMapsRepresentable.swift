//
//  HomeMapsRepresentable.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/3/24.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct HomeMapsRepresentable: UIViewControllerRepresentable {
    @Binding var location: CLLocationCoordinate2D
    @ObservedObject var leadManager: LeadManager
    @ObservedObject var homeManager = HomeMapManager()
    @ObservedObject var routeManager = RouteManager()

    @ObservedObject var tool: ToolManager
    // private var tools = ["lasso", "drawLead"]
    // @StateObject var directionManager = DirectionManager()
    @State var zoom: Int = 10

    @State private var changedState: MapState = .none
    @State var lassoTool: LassoTool = .init()
    var markTool: MarkTool = .init()
    var clusterTool: ClusterTool = .init()
    @Binding var time: Int

    var mapsCluster = MapsCluster()
    func makeUIViewController(context: Context) -> HomeMapsViewController {
        let uiViewController = HomeMapsViewController(location: location)
        
        lassoTool.setMap(map: uiViewController.map)
        markTool.setMap(map: uiViewController.map)
        clusterTool.setMap(map: uiViewController.map)

        lassoTool.onPath = { path in
            DispatchQueue.main.async {
                tool.ready = true
                tool.lasso = path
            }
        }
        
        // uiViewController.map.delegate = lassoTool

        tool.initTool(mode: .lasso, tool: lassoTool)
        tool.initTool(mode: .marker, tool: markTool)
        tool.initTool(mode: .cluster, tool: clusterTool)
       

        markTool.onDraw = { marker in
            DispatchQueue.main.async {
                
                tool.ready = true
                tool.marker = marker
            }
        }
        
        clusterTool.onDraw = { marker in
            DispatchQueue.main.async {
                
                tool.ready = true
                tool.marker = marker
            }
        }

        
        tool.setTool(.cluster)

        //mapsCluster.setMap(map: uiViewController.map)

        // uiViewController.map.delegate = context.coordinator
        //uiViewController.setCluster(name: "default", cluster: mapsCluster)

        return uiViewController
    }

    func updateUIViewController(_ uiViewController: HomeMapsViewController, context: Context) {
        print("homeManager.state ", homeManager.state)

        

        if tool.mode == .lasso {
            print("Play Lasso")
            tool.play()
            // uiViewController.map.delegate = lassoTool
        }

        if homeManager.state == .lasso {
            /*
              uiViewController.map.delegate = lassoTool

             lassoTool.map = uiViewController.map

              lassoTool.play()*/
            return
        }

        loadLeads(uiViewController: uiViewController)

        // uiViewController.setLeads(leads: leadManager.leads)

        print("leadManager.leads.count", leadManager.leads.count)
    }

    func loadLeads(uiViewController: HomeMapsViewController) {
        DispatchQueue.main.async {
            time += 1
            print("time:", time, " -> Tool Mode", tool.mode)
            clusterTool.resetCluster()
            
            print("leadManager.leads", leadManager.leads.count)
            for lead in leadManager.leads {
                
                clusterTool.add(marker: createMark(lead: lead))
            }
        }
        
        /*if let cluster = uiViewController.getCluster(name: "default") {
            cluster.resetCluster()

            DispatchQueue.main.async {
                time += 1
                print("time:", time, " -> Tool Mode", tool.mode)
                cluster.resetCluster()

                print("leadManager.leads", leadManager.leads.count)
                for lead in leadManager.leads {
                    // cluster.add(marker: createMark(lead: lead))
                    cluster.add(marker: createMark(lead: lead))
                }
            }
        }*/
    }

    func createMark(lead: LeadModel) -> GMSMarker {
        let marker = GMSMarker()
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

        return marker
    }

    func makeCoordinator() -> MapViewCoordinator1 {
        return MapViewCoordinator1(self, leadManager: leadManager)
    }

    final class MapViewCoordinator1: NSObject, GMSMapViewDelegate {
        @ObservedObject var leadManager: LeadManager
        var mapViewControllerBridge: HomeMapsRepresentable
        // @ObservedObject var mapManager = MapManager()
        init(_ mapViewControllerBridge: HomeMapsRepresentable, leadManager: LeadManager) {
            self.leadManager = leadManager
            self.mapViewControllerBridge = mapViewControllerBridge
            // self.mapManager = mapManager
        }

        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            print("willMove")
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            print("didTapAt")
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            mapView.animate(toLocation: marker.position)

            print("didTap")
            if let index = marker.userData as? Int {
                // mapManager.find(index)
            }

            return false
        }
    }
}

struct Home1: PreviewProvider {
    static var previews: some View {
        MainAppScreenHomeScreenPreview()
    }
}

/*
 #Preview("Home") {
     MainAppScreenHomeScreenPreview()
 }
 */
