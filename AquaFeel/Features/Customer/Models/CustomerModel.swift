//
//  CustomerModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 23/10/24.
//


import Foundation

struct CommentModel: Codable {
    var _id: String?
    var text: String
    var date: Date
    var user: String
}

struct CustomerModel: Codable {
    //var _id: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var address: String = ""
    var phone: Int = 456
    var dos: Date = Date()
    var price: Double = 0.00
    var bank: String = ""
    var paymentPlan: String = ""
    var score: String = ""
    var approval: Int = 0
    var doi: Date = Date()
    var installer: String = ""
    var status: String = ""
    var office: String = ""
    var comments: [CommentModel] = []
    var coapFirstName: String = ""
    var coapLastName: String = ""
    var coapPhone: Int = 0
    var coapEmail: String = ""
    var coapCreditScore: String = ""
    var user: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Extra: para un formato de fechas adecuado
    enum CodingKeys: String, CodingKey {
       // case _id
        case firstName, lastName, email, address, phone, dos, price, bank, paymentPlan, score, approval, doi, installer, status, office, comments, coapFirstName, coapLastName, coapPhone, coapEmail, coapCreditScore, user, createdAt, updatedAt
    }
}
