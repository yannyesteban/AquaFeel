//
//  AppDelegate.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation
import GoogleMaps
import EventKit


class AppDelegateq: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(APIKeys.googleApiKey)
        
        //GMSPlacesClient.provideAPIKey(APIKeys.googleApiKey)
        
        //application.applicationIconBadgeNumber = 0
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error al solicitar permiso: \(error.localizedDescription)")
            }
            if granted {
                print("Permiso concedido...")
            } else {
                print("Permiso denegado")
            }
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
       
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                print("Permiso concedido ***")
            } else {
                print("Permiso denegado ---")
            }
        }
        
        
        return true
    }

    private func setupMyApp() {
        // TODO: Add any intialization steps here.
       // GMSServices.provideAPIKey(APIKeys.googleApiKey)
        //GMSServices.setMetalRendererEnabled(true)
        print("Application started up!")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("my notificactions!")
        completionHandler([/*.alert,*/	 .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Manejar la respuesta a la notificación
        let userInfo = response.notification.request.content.userInfo
        print("Notificación recibida: \(userInfo)")
        completionHandler()
    }
    
}

