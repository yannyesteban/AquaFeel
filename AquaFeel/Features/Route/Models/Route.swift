//
//  Route.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 11/3/24.
//

import Foundation

struct MessageResponse: Codable, NeedStatusCode{
    let message: String
    var statusCode: Int?
}

struct RouteResponse2: Codable {
    let routes: [RouteModel]
}

struct RouteDetailResponse: Codable {
    let route: RouteModel
}

struct RouteLead: Codable {
    let _id: String
    let street_address: String
    let apt: String
    let city: String
    let state: String
    let zip: String
    let country: String
    let longitude: String
    let latitude: String
}

struct RouteModel2: Codable {
    var leads: [String]
    var _id: String
    var name: String
    var startingAddress: String
    var endingAddress: String
    var startingAddressLong: String
    var startingAddressLat: String
    var endingAddressLong: String
    var endingAddressLat: String
    var createdBy: String
    var createdOn: String
    var updatedOn: String
    var userId: String?
    var id: String?
    var __v: Int
    
    // Enumeración CodingKeys para personalizar los nombres de las propiedades
    private enum CodingKeys: String, CodingKey {
        case leads, _id, name, __v, id
        case startingAddress = "starting_address"
        case endingAddress = "ending_address"
        
        case startingAddressLong = "starting_address_long"
        case startingAddressLat = "starting_address_lat"
        
        case endingAddressLong = "ending_address_long"
        case endingAddressLat = "ending_address_lat"
        case createdBy = "created_by"
        case createdOn = "created_on"
        case updatedOn = "updated_on"
        case userId = "user_id"
    }
    
    init(_id: String = "",
         name: String = "",
         startingAddress: String = "",
         endingAddress: String = "",
         startingAddressLong: String = "",
         startingAddressLat: String = "",
         endingAddressLong: String = "",
         endingAddressLat: String = "",
         createdBy: String = "",
         createdOn: String = "",
         updatedOn: String = "",
         userId: String? = nil,
         __v: Int = 0,
         leads: [String] = []) {
        self._id = _id
        self.id = _id
        self.name = name
        self.startingAddress = startingAddress
        self.endingAddress = endingAddress
        self.startingAddressLong = startingAddressLong
        self.startingAddressLat = startingAddressLat
        self.endingAddressLong = endingAddressLong
        self.endingAddressLat = endingAddressLat
        self.createdBy = createdBy
        self.createdOn = createdOn
        self.updatedOn = updatedOn
        self.userId = userId
        self.__v = __v
        self.leads = leads
    }
    
   
    
    
}

struct RouteModel: Codable {
    var leads: [LeadModel]
    var _id: String
    var name: String
    var startingAddress: String
    var endingAddress: String
    var startingAddressLong: String
    var startingAddressLat: String
    var endingAddressLong: String
    var endingAddressLat: String
    var createdBy: String
    var createdOn: String
    var updatedOn: String
    var userId: String?
    var id: String?
    var __v: Int
    
    // Enumeración CodingKeys para personalizar los nombres de las propiedades
    private enum CodingKeys: String, CodingKey {
        case leads, _id, name, __v, id
        case startingAddress = "starting_address"
        case endingAddress = "ending_address"
        
        case startingAddressLong = "starting_address_long"
        case startingAddressLat = "starting_address_lat"
        
        case endingAddressLong = "ending_address_long"
        case endingAddressLat = "ending_address_lat"
        case createdBy = "created_by"
        case createdOn = "created_on"
        case updatedOn = "updated_on"
        case userId = "user_id"
    }
    
    init(_id: String = "",
         name: String = "",
         startingAddress: String = "",
         endingAddress: String = "",
         startingAddressLong: String = "",
         startingAddressLat: String = "",
         endingAddressLong: String = "",
         endingAddressLat: String = "",
         createdBy: String = "",
         createdOn: String = "",
         updatedOn: String = "",
         userId: String? = nil,
         __v: Int = 0,
         leads: [LeadModel] = []) {
        self._id = _id
        self.id = _id
        self.name = name
        self.startingAddress = startingAddress
        self.endingAddress = endingAddress
        self.startingAddressLong = startingAddressLong
        self.startingAddressLat = startingAddressLat
        self.endingAddressLong = endingAddressLong
        self.endingAddressLat = endingAddressLat
        self.createdBy = createdBy
        self.createdOn = createdOn
        self.updatedOn = updatedOn
        self.userId = userId
        self.__v = __v
        self.leads = leads
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        //try container.encode(leads, forKey: .leads)
        
        let leadsIds = leads.map { $0.id }
        try container.encode(leadsIds, forKey: .leads)
        
        try container.encode(_id, forKey: .id)
        //try container.encode(_id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(startingAddress, forKey: .startingAddress)
        try container.encode(endingAddress, forKey: .endingAddress)
        try container.encode(startingAddressLong, forKey: .startingAddressLong)
        try container.encode(startingAddressLat, forKey: .startingAddressLat)
        try container.encode(endingAddressLong, forKey: .endingAddressLong)
        try container.encode(endingAddressLat, forKey: .endingAddressLat)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(createdOn, forKey: .createdOn)
        try container.encode(updatedOn, forKey: .updatedOn)
        try container.encode(userId, forKey: .userId)
        try container.encode(__v, forKey: .__v)
    }
    
    
}
