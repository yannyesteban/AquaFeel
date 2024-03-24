//
//  DirectionModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/3/24.
//

import Foundation


struct GeocodedWaypoint: Codable {
    let geocoderStatus: String
    let placeID: String
    let types: [String]
    
    enum CodingKeys: String, CodingKey {
        case geocoderStatus = "geocoder_status"
        case placeID = "place_id"
        case types
    }
}

struct Route: Codable {
    let bounds: Bounds
    let copyrights: String
    let legs: [Leg]
    let overviewPolyline: OverviewPolyline
    let summary: String
    let warnings: [String]
    let waypointOrder: [Int]
    
    enum CodingKeys: String, CodingKey {
        case bounds
        case copyrights
        case legs
        case overviewPolyline = "overview_polyline"
        case summary
        case warnings
        case waypointOrder = "waypoint_order"
    }
}

struct Bounds: Codable {
    let northeast: Location
    let southwest: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct Leg: Codable {
    let distance: Distance
    let duration: Duration
    let endAddress: String
    let endLocation: Location
    let startAddress: String
    let startLocation: Location
    let steps: [Step]
    
    enum CodingKeys: String, CodingKey {
        case distance
        case duration
        case endAddress = "end_address"
        case endLocation = "end_location"
        case startAddress = "start_address"
        case startLocation = "start_location"
        case steps
    }
}

struct Distance: Codable {
    let text: String
    let value: Int
}

struct Duration: Codable {
    let text: String
    let value: Int
}

struct Step: Codable {
    let distance: Distance
    let duration: Duration
    let endLocation: Location
    let htmlInstructions: String
    let polyline: Polyline
    let startLocation: Location
    let travelMode: String
    
    enum CodingKeys: String, CodingKey {
        case distance
        case duration
        case endLocation = "end_location"
        case htmlInstructions = "html_instructions"
        case polyline
        case startLocation = "start_location"
        case travelMode = "travel_mode"
    }
}

struct Polyline: Codable {
    let points: String
}

struct OverviewPolyline: Codable {
    let points: String
}

struct RouteResponse: Codable {
    let geocodedWaypoints: [GeocodedWaypoint]
    let routes: [Route]
    let status: String
    
    
    enum CodingKeys: String, CodingKey {
        case routes
        case status
        case geocodedWaypoints = "geocoded_waypoints"
        
    }
}

