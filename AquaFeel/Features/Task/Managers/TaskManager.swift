//
//  TaskManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/9/24.
//

import Foundation

class TaskManager: ObservableObject {
    @Published var route: RouteModel?
    
    init() {
        
        
    }
    
    func load() async {
        do {
            let data: RouteModel = try await loadFile(name: "Task.data")
            
           
            
            DispatchQueue.main.async {
                self.route = data
                //print(self.route)
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func save(route: RouteModel) async {
        do {
            //let data = RouteModel()
            //prettyPrint(route)
            try await saveFile(userData: route, name: "Task.data")
            DispatchQueue.main.async {
                self.route = route
                //print(self.route)
            }
        } catch {
            print(error)
        }
        
        print("route saved correctl!")
    }
}
