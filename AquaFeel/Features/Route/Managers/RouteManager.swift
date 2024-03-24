//
//  RouteManager.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/3/24.
//

import Foundation



class RouteManager: ObservableObject {

    @Published var userId: String = ""
    @Published var routes: [RouteModel] = []
    @Published var route:  RouteModel = RouteModel()
    @Published var waiting = false
    var token = ""
  
    init(){
       
        
    }
 
    func setNew(leads: [LeadModel]){
        route = RouteModel(userId: userId, leads: leads)
        
    }
    
    func list() async throws {
        let q = LeadQuery()
            .add(.userId, userId)
        //
        
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/routes/list", token: "", params: q.get())
        ////////////let info = ApiConfig(scheme: "http", method: "GET", host: "127.0.0.1", path: "/routes/list", token: "", params: q.get(), port : "4000")
        
        do {
            let response:RouteResponse2 = try await fetching(config: info)
            DispatchQueue.main.async {
                self.routes = response.routes
            }
            //routes = response.routes
            //prettyPrint(response.routes)
            
        } catch {
            throw error
        }
      
            
            
    }
    
    func detail(routeId: String) async throws{
        let q = LeadQuery()
            .add(.id, routeId)
        
        
        let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/routes/details", token: "", params: q.get())
        //let info = ApiConfig(scheme: "http", method: "GET", host: "127.0.0.1", path: "/routes/details", token: "", params: q.get(), port : "4000")
        do {
            let response:RouteDetailResponse = try await fetching(config: info)
            DispatchQueue.main.async {
                self.route = response.route
                self.route.userId = self.userId
            }
            
            //prettyPrint(response.route.leads)
            
        } catch {
            throw error
        }
    }
    
    func save(mode: RecordMode) async throws{
        
        var path = ""
        var method = "POST"
        switch mode {
        case .new:
            path = "/routes/add"
        case .edit:
            path = "/routes/edit"
        case .delete:
            path = "/routes/delete"
            method = "DELETE"
        default:
            
            return
        }
        
        //prettyPrint(route)
        
        //var record = body
        //waiting = true
        let info = ApiConfig(method: method, host: "api.aquafeelvirginia.com", path: path, token: token, params: nil)
        
        //let info = ApiConfig(scheme: "http", method: method, host: "127.0.0.1", path: path, token: token, params: nil, port : "4000")
        DispatchQueue.main.async { 
            self.waiting = true
        }
        
        do {
            let response:RouteModel2 = try await fetching(body: route, config: info)
            DispatchQueue.main.async {
                //routes = response.routes
                self.waiting = false
                self.route.id = response._id
                self.route._id = response._id
            }
           
            
            
        } catch {
            waiting = false
            throw error
        }
    }
    
    
    func add(){
        
    }
    
    func edit(){
        
    }
    
    func delete(routeId: String) async throws -> MessageResponse{
        let q = LeadQuery()
            .add(.id, routeId)
        
        
        let info = ApiConfig(method: "DELETE", host: "api.aquafeelvirginia.com", path: "/routes/delete", token: "", params: q.get())
        //let info = ApiConfig(scheme: "http", method: "DELETE", host: "127.0.0.1", path: "/routes/delete", token: "", params: q.get(), port : "4000")
        do {
            let response:MessageResponse = try await fetching(config: info)
            
            return response
             
            
            
        } catch {
            throw error
        }
        
        
    }
    
    
}
