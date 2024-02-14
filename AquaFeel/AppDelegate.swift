//
//  AppDelegate.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation
import GoogleMaps
import GooglePlaces

class AppDelegateq: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4")
        
        GMSPlacesClient.provideAPIKey("AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4")
        return true
    }

    private func setupMyApp() {
        // TODO: Add any intialization steps here.
       // GMSServices.provideAPIKey("AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4")
        //GMSServices.setMetalRendererEnabled(true)
        print("Application started up!")
    }
}

