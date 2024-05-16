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
    @Published var route: RouteModel = RouteModel()
    @Published var waiting = false
    
    @Published var mapRoute: RouteResponse?
    var token = ""

    init() {
    }

    func setNew(leads: [LeadModel]) {
        route = RouteModel(userId: userId, leads: leads)
    }

    func list() async throws {
        let q = LeadQuery()
            .add(.userId, userId)
        //
        
        
        let path = "/routes/list"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/routes/list", token: "", params: q.get())
        //let info = ApiConfig(scheme: "http", method: "GET", host: "127.0.0.1", path: "/routes/list", token: "", params: q.get(), port : "4000")

        do {
            let response: RouteResponse2 = try await fetching(config: info)
            DispatchQueue.main.async {
                self.routes = response.routes
            }

        } catch {
            throw error
        }
    }

    func routeData(routeId: String) async throws -> RouteModel? {
        let q = LeadQuery()
            .add(.id, routeId)

        
        let path = "/routes/details"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/routes/details", token: "", params: q.get())

        do {
            let response: RouteDetailResponse = try await fetching(config: info)

            return response.route

        } catch {
            throw error
        }
    }

    func getDirection(mode: String, avoid: [String]) async throws -> RouteResponse? {
        
        let leads = route.leads.filter { $0.isSelected }
        let request = RouteRequest(origin: route.startingAddress, destination: route.endingAddress, waypoints: leads.map({
            $0.latitude + "," + $0.longitude

        }), mode: mode, avoid: avoid)
        let directionManager = DirectionManager()

        let routeResponse = try? await directionManager.search(request: request, leads: leads)

        return routeResponse
    }

    func getRoute(routeId: String) async throws -> RouteResponse? {
        let q = LeadQuery()
            .add(.id, routeId)

        let path = "/routes/details"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/routes/details", token: "", params: q.get())
        // let info = ApiConfig(scheme: "http", method: "GET", host: "127.0.0.1", path: "/routes/details", token: "", params: q.get(), port : "4000")
        do {
            let response: RouteDetailResponse = try await fetching(config: info)

            let request = RouteRequest(origin: response.route.startingAddress, destination: response.route.endingAddress, waypoints: response.route.leads.map({
                $0.latitude + "," + $0.longitude
                // $0.street_address
            }))

            let directionManager = DirectionManager()

            let routeResponse = try? await directionManager.search(request: request, leads: response.route.leads)

            return routeResponse

        } catch {
            throw error
        }
    }

    func detail(routeId: String) async throws {
        let q = LeadQuery()
            .add(.id, routeId)

        let path = "/routes/details"
        let params: [String : String?]? = q.get()
        let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        
        //let info = ApiConfig(method: "GET", host: "api.aquafeelvirginia.com", path: "/routes/details", token: "", params: q.get())
        // let info = ApiConfig(scheme: "http", method: "GET", host: "127.0.0.1", path: "/routes/details", token: "", params: q.get(), port : "4000")
        do {
            let response: RouteDetailResponse = try await fetching(config: info)
            DispatchQueue.main.async {
                self.route = response.route
                self.route.userId = self.userId
            }

        } catch {
            throw error
        }
    }

    func save(mode: RecordMode) async throws {
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

       
        let params: [String : String?]? = nil
        //let method = "GET"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: method, host: "api.aquafeelvirginia.com", path: path, token: token, params: nil)

        // let info = ApiConfig(scheme: "http", method: method, host: "127.0.0.1", path: path, token: token, params: nil, port : "4000")
        DispatchQueue.main.async {
            self.waiting = true
        }

        do {
            let response: RouteModel2 = try await fetching(body: route, config: info)
            DispatchQueue.main.async {
                // routes = response.routes
                self.waiting = false
                self.route.id = response._id
                self.route._id = response._id
            }

        } catch {
            waiting = false
            throw error
        }
    }

    func add() {
    }

    func edit() {
    }

    func delete(routeId: String) async throws -> MessageResponse {
        let q = LeadQuery()
            .add(.id, routeId)

        
        let path = "/routes/delete"
        let params: [String : String?]? = q.get()
        let method = "DELETE"
        let scheme = APIValues.scheme
        let info = ApiConfig(scheme: scheme, method: method, host: APIValues.host, path: path, token: token, params: params, port: APIValues.port)
        
        //let info = ApiConfig(method: "DELETE", host: "api.aquafeelvirginia.com", path: "/routes/delete", token: "", params: q.get())
        // let info = ApiConfig(scheme: "http", method: "DELETE", host: "127.0.0.1", path: "/routes/delete", token: "", params: q.get(), port : "4000")
        do {
            let response: MessageResponse = try await fetching(config: info)

            return response

        } catch {
            throw error
        }
    }
    
    
}
