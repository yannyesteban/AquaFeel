//
//  AppDelegate.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation
import GoogleMaps


class AppDelegateq: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(APIKeys.googleApiKey)
        
        //GMSPlacesClient.provideAPIKey(APIKeys.googleApiKey)
        return true
    }

    private func setupMyApp() {
        // TODO: Add any intialization steps here.
       // GMSServices.provideAPIKey(APIKeys.googleApiKey)
        //GMSServices.setMetalRendererEnabled(true)
        print("Application started up!")
    }
}

