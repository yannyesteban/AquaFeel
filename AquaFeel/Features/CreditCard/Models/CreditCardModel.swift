//
//  CreditCardModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/8/24.
//

import Foundation


struct CreditCardModel: Codable {
    var _id: String
    var date: Date
    var amount: Double
    var country: String
    var firstName: String
    var lastName: String
    var license: String
    var products: String
    var phone: String
    var address: String
    var city: String
    var state: String
    var zip: String
    var nameCard: String
    var numberCard: String
    var cvcCard: String
    var typeCard: String
    var expCard: Date
    var signature: String
    var lead: String
    var createdBy: String
    //var createdOn: Date
    //var updatedOn: Date
    
    init(_id: String = "", date: Date = Date(), amount: Double = 0.0, country: String = "", firstName: String = "", lastName: String = "", license: String = "", products: String = "", phone: String = "", address: String = "", city: String = "", state: String = "", zip: String = "", nameCard: String = "", numberCard: String = "", cvcCard: String = "", typeCard: String = "VISA", expCard: Date = Date(), signature: String = "", lead: String = "", createdBy: String = ""/*, createdOn: Date = Date(), updatedOn: Date = Date()*/) {
        self._id = _id
        self.date = date
        self.amount = amount
        self.country = country
        self.firstName = firstName
        self.lastName = lastName
        self.license = license
        self.products = products
        self.phone = phone
        self.address = address
        self.city = city
        self.state = state
        self.zip = zip
        self.nameCard = nameCard
        self.numberCard = numberCard
        self.cvcCard = cvcCard
        self.typeCard = typeCard
        self.expCard = expCard
        self.lead = lead
        self.signature = signature
        self.createdBy = createdBy
        //self.createdOn = createdOn
        //self.updatedOn = updatedOn
    }
    
    enum CodingKeys: String, CodingKey {
        case _id, date, amount, country, firstName, lastName, license, products, phone, address, city, state, zip, nameCard, numberCard, cvcCard, typeCard, expCard, lead, signature, createdBy, createdOn, updatedOn
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        if let text = try container.decodeIfPresent(String.self, forKey: .date) {
            date = realDate(text: text)
        } else {
            date = Date()
        }
        
        amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0.0
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        license = try container.decodeIfPresent(String.self, forKey: .license) ?? ""
        products = try container.decodeIfPresent(String.self, forKey: .products) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        zip = try container.decodeIfPresent(String.self, forKey: .zip) ?? ""
        nameCard = try container.decodeIfPresent(String.self, forKey: .nameCard) ?? ""
        numberCard = try container.decodeIfPresent(String.self, forKey: .numberCard) ?? ""
        cvcCard = try container.decodeIfPresent(String.self, forKey: .cvcCard) ?? ""
        typeCard = try container.decodeIfPresent(String.self, forKey: .typeCard) ?? ""
        expCard = Date()
        if let text = try container.decodeIfPresent(String.self, forKey: .expCard) {
            expCard = realDate(text: text)
        } else {
            expCard = Date()
        }
        
        signature = try container.decodeIfPresent(String.self, forKey: .signature) ?? ""
        lead = try container.decodeIfPresent(String.self, forKey: .lead) ?? ""
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy) ?? ""
        //createdOn = try container.decodeIfPresent(Date.self, forKey: .createdOn) ?? Date()
        //updatedOn = try container.decodeIfPresent(Date.self, forKey: .updatedOn) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_id, forKey: ._id)
        let dateString = formatDateToString2(date)
        try container.encode(dateString, forKey: .date)
        
        try container.encode(amount, forKey: .amount)
        try container.encode(country, forKey: .country)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(license, forKey: .license)
        try container.encode(products, forKey: .products)
        try container.encode(phone, forKey: .phone)
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zip, forKey: .zip)
        try container.encode(nameCard, forKey: .nameCard)
        try container.encode(numberCard, forKey: .numberCard)
        try container.encode(cvcCard, forKey: .cvcCard)
        try container.encode(typeCard, forKey: .typeCard)
        
        let expCardString = formatDateToString2(expCard)
        try container.encode(expCardString, forKey: .expCard)
        
        try container.encode(signature, forKey: .signature)
        try container.encode(lead, forKey: .lead)
        try container.encode(createdBy, forKey: .createdBy)
        //try container.encode(createdOn, forKey: .createdOn)
        //try container.encode(updatedOn, forKey: .updatedOn)
    }
    
    
}
