//
//  OrderModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/6/24.
//

import Foundation
func formatDateToString2(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    return dateFormatter.string(from: date)
}

struct ApprovalModel: Codable {
    var name: String
    var signature: String
    var date: Date

    enum CodingKeys: String, CodingKey {
        case name, signature, date
    }

    init(
        purchaser: String = "",
        signature: String = "",
        date: Date = Date()) {
        name = purchaser
        self.signature = signature
        self.date = date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        signature = try container.decodeIfPresent(String.self, forKey: .signature) ?? ""

        if let text = try container.decodeIfPresent(String.self, forKey: .date) {
            date = realDate(text: text)
        } else {
            date = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(signature, forKey: .signature)

        let dateString = formatDateToString2(date)
        try container.encode(dateString, forKey: .date)
    }
}

struct BuyerModel: Identifiable, Codable {
    var _id: String
    var id: String
    var name: String
    var phone: String
    var cel: String

    var signature: String
    var date: Date

    enum CodingKeys: String, CodingKey {
        case _id, id, name, phone, cel, signature, date
    }

    init(
        _id: String = "",
        id: String = "",
        name: String = "",
        phone: String = "",
        cel: String = "",
        signature: String = "",
        date: Date = Date()) {
        self._id = id
        self.id = id
        self.name = name
        self.phone = phone
        self.cel = cel
        self.signature = signature
        self.date = date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        cel = try container.decodeIfPresent(String.self, forKey: .cel) ?? ""

        signature = try container.decodeIfPresent(String.self, forKey: .signature) ?? ""

        if let text = try container.decodeIfPresent(String.self, forKey: .date) {
            date = realDate(text: text)
        } else {
            date = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(_id, forKey: ._id)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(phone, forKey: .phone)
        try container.encode(cel, forKey: .cel)

        try container.encode(signature, forKey: .signature)

        let dateString = formatDateToString2(date)
        try container.encode(dateString, forKey: .date)
    }
}

struct SystemModel: Identifiable, Codable {
    var _id: String
    var id: String
    var name: String
    var brand: String
    var model: String

    init(_id: String = "",
         id: String = "",
         name: String = "",
         brand: String = "",
         model: String = "") {
        self._id = id
        self.id = id
        self.name = name
        self.brand = brand
        self.model = model
    }

    enum CodingKeys: String, CodingKey {
        case _id, id, name, brand, model
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        brand = try container.decodeIfPresent(String.self, forKey: .brand) ?? ""
        model = try container.decodeIfPresent(String.self, forKey: .model) ?? ""
    }
}

struct InstallModel: Identifiable, Codable {
    var _id: String = ""
    var id: String
    var day: String
    var date: Date
    var waterSouce: String
    var iceMaker: Bool
    var time: Int

    var s0: Bool
    var s1: Bool
    var s2: Bool
    var s3: Bool
    
    
    init(id: String = "",
         day: String = "",
         date: Date = Date(),
         waterSource: String = "city",
         iceMaker: Bool = false,
         time: Int = 0, s0: Bool = false, s1: Bool = false, s2: Bool = false, s3: Bool = false) {
        self.id = id
        self.day = day
        self.date = date
        self.waterSouce = waterSource
        self.iceMaker = iceMaker
        self.time = time
        
        self.s0 = s0
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
    }

    enum CodingKeys: String, CodingKey {
        case _id, id, day, date, waterSouce, iceMaker, time, s0, s1, s2, s3
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        day = try container.decodeIfPresent(String.self, forKey: .day) ?? ""

        if let text = try container.decodeIfPresent(String.self, forKey: .date) {
            date = realDate(text: text)

        } else {
            date = Date()
        }
        waterSouce = try container.decodeIfPresent(String.self, forKey: .waterSouce) ?? ""
        // date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        iceMaker = try container.decodeIfPresent(Bool.self, forKey: .iceMaker) ?? false
        time = try container.decodeIfPresent(Int.self, forKey: .time) ?? 0
        
        
        s0 = try container.decodeIfPresent(Bool.self, forKey: .s0) ?? false
        s1 = try container.decodeIfPresent(Bool.self, forKey: .s1) ?? false
        s2 = try container.decodeIfPresent(Bool.self, forKey: .s2) ?? false
        s3 = try container.decodeIfPresent(Bool.self, forKey: .s3) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(_id, forKey: ._id)
        try container.encode(id, forKey: .id)
        try container.encode(day, forKey: .day)

        // Convert date to string
        let dateString = formatDateToString2(date)
        try container.encode(dateString, forKey: .date)

        try container.encode(waterSouce, forKey: .waterSouce)
        try container.encode(iceMaker, forKey: .iceMaker)
        try container.encode(time, forKey: .time)
        
        
        try container.encode(s0, forKey: .s0)
        try container.encode(s1, forKey: .s1)
        try container.encode(s2, forKey: .s2)
        try container.encode(s3, forKey: .s3)
    }
}

struct TermsModel: Codable {
    var _id: String = ""
    var unit: String = ""// month, days, weeks
    var amount: Int

    init(unit: String = "MONTH",
         amount: Int = 0) {
        self.unit = unit
        self.amount = amount
    }

    enum CodingKeys: String, CodingKey {
        case _id, unit, amount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        unit = try container.decodeIfPresent(String.self, forKey: .unit) ?? "MONTH"
        amount = try container.decodeIfPresent(Int.self, forKey: .amount) ?? 0
    }
}

struct PriceModel: Codable {
    var _id: String = ""
    var cashPrice: Float
    var installation: Float
    var taxes: Float
    var totalCash: Float
    var downPayment: Float
    var totalCashPrice: Float
    var toFinance: Float
    var terms: TermsModel
    var APR: Float
    var finaceCharge: Float
    var totalPayments: Float
    init(cashPrice: Float = 0,
         installation: Float = 0,
         taxes: Float = 0,
         totalCash: Float = 0,
         downPayment: Float = 0,
         totalCashPrice: Float = 0,
         toFinance: Float = 0,
         terms: TermsModel = TermsModel(),
         APR: Float = 0,
         finaceCharge: Float = 0,
         totalPayments: Float = 0) {
        self.cashPrice = cashPrice
        self.installation = installation
        self.taxes = taxes
        self.totalCash = totalCash
        self.downPayment = downPayment
        self.totalCashPrice = totalCashPrice
        self.toFinance = toFinance
        self.terms = terms
        self.APR = APR
        self.finaceCharge = finaceCharge
        self.totalPayments = totalPayments
    }

    enum CodingKeys: String, CodingKey {
        case _id, cashPrice, installation, taxes, totalCash, downPayment, totalCashPrice, toFinance, terms, APR, finaceCharge, totalPayments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        cashPrice = try container.decodeIfPresent(Float.self, forKey: .cashPrice) ?? 0
        installation = try container.decodeIfPresent(Float.self, forKey: .installation) ?? 0
        taxes = try container.decodeIfPresent(Float.self, forKey: .taxes) ?? 0
        totalCash = try container.decodeIfPresent(Float.self, forKey: .totalCash) ?? 0
        downPayment = try container.decodeIfPresent(Float.self, forKey: .downPayment) ?? 0
        totalCashPrice = try container.decodeIfPresent(Float.self, forKey: .totalCashPrice) ?? 0
        toFinance = try container.decodeIfPresent(Float.self, forKey: .toFinance) ?? 0
        terms = try container.decodeIfPresent(TermsModel.self, forKey: .terms) ?? TermsModel()
        APR = try container.decodeIfPresent(Float.self, forKey: .APR) ?? 0
        finaceCharge = try container.decodeIfPresent(Float.self, forKey: .finaceCharge) ?? 0
        totalPayments = try container.decodeIfPresent(Float.self, forKey: .totalPayments) ?? 0
    }
}

struct OrderModel: Identifiable, Codable {
    var _id: String
    var id: String
    var buyer1: BuyerModel
    var buyer2: BuyerModel
    var address: String
    var city: String
    var state: String
    var zip: String
    var system1: SystemModel
    var system2: SystemModel
    var promotion: String
    var installation: InstallModel
    var people: Int
    var floorType: String
    var creditCard: Bool
    var check: Bool
    var price: PriceModel
    var employee: ApprovalModel
    var approvedBy: ApprovalModel
    var createdBy: String
    var lead: String

    init(
        _id: String = "",
        id: String = "",
        buyer1: BuyerModel = BuyerModel(),
        buyer2: BuyerModel = BuyerModel(),
        address: String = "",
        city: String = "",
        state: String = "",
        zip: String = "",
        system1: SystemModel = SystemModel(),
        system2: SystemModel = SystemModel(),
        promotion: String = "",

        installation: InstallModel = InstallModel(),
        people: Int = 0,
        floorType: String = "raised",
        creditCard: Bool = false,
        check: Bool = false,
        price: PriceModel = PriceModel(),
        employee: ApprovalModel = ApprovalModel(),
        approvedBy: ApprovalModel = ApprovalModel(),
        createdBy: String = "",
        lead: String = ""

    ) {
        self._id = _id
        self.id = id
        self.buyer1 = buyer1
        self.buyer2 = buyer2
        self.address = address
        self.city = city
        self.state = state
        self.zip = zip
        self.system1 = system1
        self.system2 = system2
        self.installation = installation
        self.promotion = promotion
        self.people = people
        self.floorType = floorType
        self.creditCard = creditCard
        self.check = check
        self.price = price

        self.employee = employee
        self.approvedBy = approvedBy
        self.createdBy = createdBy
        self.lead = lead
    }

    enum CodingKeys: String, CodingKey {
        case _id, id, buyer1, buyer2, address, city, state, zip, system1, system2, promotion, installation, people, floorType, creditCard, check, price, employee, approvedBy, createdBy, lead
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        buyer1 = try container.decodeIfPresent(BuyerModel.self, forKey: .buyer1) ?? BuyerModel()
        buyer2 = try container.decodeIfPresent(BuyerModel.self, forKey: .buyer2) ?? BuyerModel()
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        zip = try container.decodeIfPresent(String.self, forKey: .zip) ?? ""
        system1 = try container.decodeIfPresent(SystemModel.self, forKey: .system1) ?? SystemModel()
        system2 = try container.decodeIfPresent(SystemModel.self, forKey: .system2) ?? SystemModel()
        promotion = try container.decodeIfPresent(String.self, forKey: .promotion) ?? ""
        installation = try container.decodeIfPresent(InstallModel.self, forKey: .installation) ?? InstallModel()
        floorType = try container.decodeIfPresent(String.self, forKey: .floorType) ?? ""
        people = try container.decodeIfPresent(Int.self, forKey: .people) ?? 0
        creditCard = try container.decodeIfPresent(Bool.self, forKey: .creditCard) ?? false
        check = try container.decodeIfPresent(Bool.self, forKey: .check) ?? false
        price = try container.decodeIfPresent(PriceModel.self, forKey: .price) ?? PriceModel()

        employee = try container.decodeIfPresent(ApprovalModel.self, forKey: .employee) ?? ApprovalModel()
        approvedBy = try container.decodeIfPresent(ApprovalModel.self, forKey: .approvedBy) ?? ApprovalModel()
        lead = try container.decodeIfPresent(String.self, forKey: .lead) ?? ""
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(_id, forKey: ._id)
        try container.encode(id, forKey: .id)
        try container.encode(buyer1, forKey: .buyer1)
        try container.encode(buyer2, forKey: .buyer2)
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zip, forKey: .zip)
        try container.encode(system1, forKey: .system1)
        try container.encode(system2, forKey: .system2)
        try container.encode(promotion, forKey: .promotion)
        try container.encode(installation, forKey: .installation)
        try container.encode(people, forKey: .people)
        try container.encode(floorType, forKey: .floorType)
        try container.encode(creditCard, forKey: .creditCard)
        try container.encode(check, forKey: .check)
        try container.encode(price, forKey: .price)

        try container.encode(employee, forKey: .employee)
        try container.encode(approvedBy, forKey: .approvedBy)
        try container.encode(lead, forKey: .lead)
        try container.encode(createdBy, forKey: .createdBy)
    }
}




struct OrderModel2: Identifiable, Codable {
    var _id: String
    var id: String
    var buyer1: BuyerModel2
    var buyer2: BuyerModel2
    /*var address: String
    var city: String
    var state: String
    var zip: String
    var system1: SystemModel
    var system2: SystemModel
    var promotion: String
    var installation: InstallModel
    var people: Int
    var floorType: String
    var creditCard: Bool
    var check: Bool
    var price: PriceModel
    var employee: ApprovalModel
    var approvedBy: ApprovalModel
    var createdBy: String
    var lead: String
    */
    init(
        _id: String = "",
        id: String = "",
        buyer1: BuyerModel2 = BuyerModel2(),
        buyer2: BuyerModel2 = BuyerModel2()
        /*address: String = "",
        city: String = "",
        state: String = "",
        zip: String = "",
        system1: SystemModel = SystemModel(),
        system2: SystemModel = SystemModel(),
        promotion: String = "",
        
        installation: InstallModel = InstallModel(),
        people: Int = 0,
        floorType: String = "raised",
        creditCard: Bool = false,
        check: Bool = false,
        price: PriceModel = PriceModel(),
        employee: ApprovalModel = ApprovalModel(),
        approvedBy: ApprovalModel = ApprovalModel(),
        createdBy: String = "",
        lead: String = ""
         */
        
    ) {
        self._id = _id
        self.id = id
        self.buyer1 = buyer1
        self.buyer2 = buyer2
        /*self.address = address
        self.city = city
        self.state = state
        self.zip = zip
        self.system1 = system1
        self.system2 = system2
        self.installation = installation
        self.promotion = promotion
        self.people = people
        self.floorType = floorType
        self.creditCard = creditCard
        self.check = check
        self.price = price
        
        self.employee = employee
        self.approvedBy = approvedBy
        self.createdBy = createdBy
        self.lead = lead*/
    }
    
    enum CodingKeys: String, CodingKey {
        case _id, id, buyer1, buyer2
        //, address, city, state, zip, system1, system2, promotion, installation, people, floorType, creditCard, check, price, employee, approvedBy, createdBy, lead
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        buyer1 = try container.decodeIfPresent(BuyerModel2.self, forKey: .buyer1) ?? BuyerModel2()
        buyer2 = try container.decodeIfPresent(BuyerModel2.self, forKey: .buyer2) ?? BuyerModel2()
        /*address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        zip = try container.decodeIfPresent(String.self, forKey: .zip) ?? ""
        system1 = try container.decodeIfPresent(SystemModel.self, forKey: .system1) ?? SystemModel()
        system2 = try container.decodeIfPresent(SystemModel.self, forKey: .system2) ?? SystemModel()
        promotion = try container.decodeIfPresent(String.self, forKey: .promotion) ?? ""
        installation = try container.decodeIfPresent(InstallModel.self, forKey: .installation) ?? InstallModel()
        floorType = try container.decodeIfPresent(String.self, forKey: .floorType) ?? ""
        people = try container.decodeIfPresent(Int.self, forKey: .people) ?? 0
        creditCard = try container.decodeIfPresent(Bool.self, forKey: .creditCard) ?? false
        check = try container.decodeIfPresent(Bool.self, forKey: .check) ?? false
        price = try container.decodeIfPresent(PriceModel.self, forKey: .price) ?? PriceModel()
        
        employee = try container.decodeIfPresent(ApprovalModel.self, forKey: .employee) ?? ApprovalModel()
        approvedBy = try container.decodeIfPresent(ApprovalModel.self, forKey: .approvedBy) ?? ApprovalModel()
        lead = try container.decodeIfPresent(String.self, forKey: .lead) ?? ""
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy) ?? ""
         */
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_id, forKey: ._id)
        try container.encode(id, forKey: .id)
        try container.encode(buyer1, forKey: .buyer1)
        try container.encode(buyer2, forKey: .buyer2)
        /*try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zip, forKey: .zip)
        try container.encode(system1, forKey: .system1)
        try container.encode(system2, forKey: .system2)
        try container.encode(promotion, forKey: .promotion)
        try container.encode(installation, forKey: .installation)
        try container.encode(people, forKey: .people)
        try container.encode(floorType, forKey: .floorType)
        try container.encode(creditCard, forKey: .creditCard)
        try container.encode(check, forKey: .check)
        try container.encode(price, forKey: .price)
        
        try container.encode(employee, forKey: .employee)
        try container.encode(approvedBy, forKey: .approvedBy)
        try container.encode(lead, forKey: .lead)
        try container.encode(createdBy, forKey: .createdBy)
         */
    }
}


struct BuyerModel2: Identifiable, Codable {
    var id: String
    
    var date: Date
    
    enum CodingKeys: String, CodingKey {
        case  id,  date
    }
    
    init(
        
        id: String = "",
        
        date: Date = Date()) {
         
            self.id = id
     
            self.date = date
        }
    
    
}
