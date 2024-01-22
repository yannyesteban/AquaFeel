//
//  AppData.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation


struct UserData: Identifiable, Codable {
    
    let id: UUID
    
    var email: String
    var password: String
    var token: String
    var role : String
    
    var isBlocked: Bool
    var isVerified: Bool
    var auth: Bool
    
    
    
    
}
