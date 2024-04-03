//
//  GoogleApis.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/4/24.
//

import Foundation
import GoogleMaps

enum GoogleAPIError: Error {
    case noResult
    case networkError
    case authenticationError
    case userDataError
    case urlError
    case requestError
}

class GoogleApis {
    static let apiKey = "AIzaSyA4Jqk-dU9axKNYJ6qjWcBcvQku0wTvBC4"
    // CLLocationCoordinate2D

    static func getPlaceDetailsByCoordinates(location: CLLocationCoordinate2D) async throws -> PlaceDetails? {
       
        print("getPlaceDetailsByCoordinates", location.latitude, location.longitude)
        var params: [String: String] = [:]

        params["latlng"] = "\(location.latitude),\(location.longitude)"
        params["key"] = apiKey

        let info = ApiConfig(method: "GET", host: "maps.googleapis.com", path: "/maps/api/geocode/json", token: "", params: params)

        do {
            let response: GeocodeResult = try await fetching(config: info)

           
            if let firstResult = response.results.first {
                return firstResult
            }
            return nil

        } catch {
            print("response ", error.localizedDescription)
            throw error
        }
    }

    static func search(request: RouteRequest, leads: [LeadModel]) async throws -> RouteResponse? {
        var params: [String: String] = [:]

        params["origin"] = request.origin
        params["destination"] = request.destination

        var ways = request.waypoints.joined(separator: "|")

        if ways != "" {
            if request.optimize {
                ways = "optimize:true|" + ways
            }
            params["waypoints"] = ways
        }

        params["mode"] = "driving"
        params["key"] = apiKey

        let info = ApiConfig(method: "GET", host: "maps.googleapis.com", path: "/maps/api/directions/json", token: "", params: params)

        do {
            var response: RouteResponse = try await fetching(config: info)

            print("result.status:", response.status)

            // var response = response1
            for i in response.routes.indices {
                // i.leads = []
                for j in response.routes[i].waypointOrder {
                    var lead = leads[j]

                    lead.routeOrder = j + 1
                    response.routes[i].leads.append(lead)
                }

                print("i.waypointOrder", response.routes[i].waypointOrder)
            }
            // prettyPrint(response)
            /*
             let response1 = response
             DispatchQueue.main.async {
             // let response1 = response
             self.route = response1
             }
             */
            return response
        } catch {
            throw error
        }
    }
}
