//
//  LoginResponse.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 14/1/24.
//

import Foundation

struct LoginResponse: Codable {
    let token: String?
    let user: LoginResponseData?
    let message: String?
    //let _id: String?
}

struct LoginResponseData: Codable {
    let isBlocked: Bool
    let isVerified: Bool
    let _id: String
    let email: String;
    let password: String
    let role: String
    
    
}
