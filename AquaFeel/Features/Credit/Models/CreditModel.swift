//
//  CreditModel.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/7/24.
//

import Foundation

// MARK: - Mortage Model

struct MortgageModel: Codable {
    var status: String
    var mortgageCompany: String
    var monthlyPayment: Float
    var howlong: String

    init(status: String = "Paid", mortgageCompany: String = "", monthlyPayment: Float = 0.0, howlong: String = "") {
        self.status = status
        self.mortgageCompany = mortgageCompany
        self.monthlyPayment = monthlyPayment
        self.howlong = howlong
    }

    enum CodingKeys: String, CodingKey {
        case status, mortgageCompany, monthlyPayment, howlong
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "Paid"
        mortgageCompany = try container.decodeIfPresent(String.self, forKey: .mortgageCompany) ?? ""
        monthlyPayment = try container.decodeIfPresent(Float.self, forKey: .monthlyPayment) ?? 0.0
        howlong = try container.decodeIfPresent(String.self, forKey: .howlong) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        try container.encode(mortgageCompany, forKey: .mortgageCompany)
        try container.encode(monthlyPayment, forKey: .monthlyPayment)
        try container.encode(howlong, forKey: .howlong)
    }
}

// MARK: - Reference Model

struct ReferenceModel: Codable {
    var name: String
    var relationship: String
    var phone: String

    init(name: String = "", relationship: String = "", phone: String = "") {
        self.name = name
        self.relationship = relationship
        self.phone = phone
    }

    enum CodingKeys: String, CodingKey {
        case name, relationship, phone
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        relationship = try container.decodeIfPresent(String.self, forKey: .relationship) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(relationship, forKey: .relationship)
        try container.encode(phone, forKey: .phone)
    }
}

// MARK: - Bank Model

struct BankModel: Codable {
    var name: String
    var accountNumber: String
    var routingNumber: String
    var checking: Bool
    var savings: Bool

    init(name: String = "", accountNumber: String = "", routingNumber: String = "", checking: Bool = false, savings: Bool = false) {
        self.name = name
        self.accountNumber = accountNumber
        self.routingNumber = routingNumber
        self.checking = checking
        self.savings = savings
    }

    enum CodingKeys: String, CodingKey {
        case name, accountNumber, routingNumber, checking, savings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber) ?? ""
        routingNumber = try container.decodeIfPresent(String.self, forKey: .routingNumber) ?? ""
        checking = try container.decodeIfPresent(Bool.self, forKey: .checking) ?? false
        savings = try container.decodeIfPresent(Bool.self, forKey: .savings) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encode(routingNumber, forKey: .routingNumber)
        try container.encode(checking, forKey: .checking)
        try container.encode(savings, forKey: .savings)
    }
}

// MARK: - Income Model

struct IncomeModel: Codable {
    var employer: String
    var years: Int
    var salary: String
    var position: String
    var phone: String
    var preEmployer: String
    var otherIncome: String

    init(employer: String = "", years: Int = 0, salary:String = "", position: String = "", phone: String = "", preEmployer: String = "", otherIncome: String = "") {
        self.employer = employer
        self.years = years
        self.salary = salary
        self.position = position
        self.phone = phone
        self.preEmployer = preEmployer
        self.otherIncome = otherIncome
    }

    enum CodingKeys: String, CodingKey {
        case employer, years, salary, position, phone, preEmployer, otherIncome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        employer = try container.decodeIfPresent(String.self, forKey: .employer) ?? ""
        years = try container.decodeIfPresent(Int.self, forKey: .years) ?? 0
        salary = try container.decodeIfPresent(String.self, forKey: .salary) ?? ""
        position = try container.decodeIfPresent(String.self, forKey: .position) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        preEmployer = try container.decodeIfPresent(String.self, forKey: .preEmployer) ?? ""
        otherIncome = try container.decodeIfPresent(String.self, forKey: .otherIncome) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(employer, forKey: .employer)
        try container.encode(years, forKey: .years)
        try container.encode(salary, forKey: .salary)
        try container.encode(position, forKey: .position)
        try container.encode(phone, forKey: .phone)
        try container.encode(preEmployer, forKey: .preEmployer)
        try container.encode(otherIncome, forKey: .otherIncome)
    }
}

// MARK: - Applicant Model

struct ApplicantModel: Codable {
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var email: String
    var relationship: String
    var ss: String
    var id: String
    var idExp: Date
    var phone: String
    var cel: String
    var address: String
    var city: String
    var state: String
    var zip: String
    var income: IncomeModel
    var signature: String
    var date: Date

    init(firstName: String = "", lastName: String = "", dateOfBirth: Date = Date(), email: String = "", relationship: String = "", ss: String = "", id: String = "", idExp: Date = Date(), phone: String = "", cel: String = "", address: String = "", city: String = "", state: String = "", zip: String = "", income: IncomeModel = IncomeModel(), signature: String = "", date: Date = Date()) {
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth

        self.email = email
        self.relationship = relationship

        self.ss = ss
        self.id = id
        self.idExp = idExp
        self.phone = phone
        self.cel = cel
        self.address = address
        self.city = city
        self.state = state
        self.zip = zip
        self.income = income
        self.signature = signature
        self.date = date
    }

    enum CodingKeys: String, CodingKey {
        case firstName, lastName, dateOfBirth, ss, id, idExp, phone, cel, address, city, state, zip, income, signature, date, email, relationship
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""

        if let text = try container.decodeIfPresent(String.self, forKey: .dateOfBirth) {
            dateOfBirth = realDate(text: text)
        } else {
            dateOfBirth = Date()
        }

        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        relationship = try container.decodeIfPresent(String.self, forKey: .relationship) ?? ""

        ss = try container.decodeIfPresent(String.self, forKey: .ss) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        if let text = try container.decodeIfPresent(String.self, forKey: .idExp) {
            idExp = realDate(text: text)
        } else {
            idExp = Date()
        }
        // idExp = try container.decodeIfPresent(Date.self, forKey: .idExp) ?? Date()
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        cel = try container.decodeIfPresent(String.self, forKey: .cel) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        zip = try container.decodeIfPresent(String.self, forKey: .zip) ?? ""
        income = try container.decodeIfPresent(IncomeModel.self, forKey: .income) ?? IncomeModel() // Asegúrate de tener un inicializador por defecto para IncomeModel
        signature = try container.decodeIfPresent(String.self, forKey: .signature) ?? ""

        if let text = try container.decodeIfPresent(String.self, forKey: .date) {
            date = realDate(text: text)
        } else {
            date = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        //try container.encode(dateOfBirth, forKey: .dateOfBirth)

        let dateString = formatDateToString2(dateOfBirth)
        try container.encode(dateString, forKey: .dateOfBirth)
        
        
        try container.encode(email, forKey: .email)
        try container.encode(relationship, forKey: .relationship)

        try container.encode(ss, forKey: .ss)
        try container.encode(id, forKey: .id)
        //try container.encode(idExp, forKey: .idExp)
        let dateString2 = formatDateToString2(idExp)
        try container.encode(dateString2, forKey: .idExp)
        
        try container.encode(phone, forKey: .phone)
        try container.encode(cel, forKey: .cel)
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zip, forKey: .zip)
        try container.encode(income, forKey: .income)
        try container.encode(signature, forKey: .signature)
        //try container.encode(date, forKey: .date)
        
        let dateString3 = formatDateToString2(date)
        try container.encode(dateString3, forKey: .date)
    }
}

// MARK: - Credit Model

struct CreditModel: Codable {
    var _id: String

    var applicant: ApplicantModel
    var applicant2: ApplicantModel
    var mortgage: MortgageModel
    var reference: ReferenceModel
    var reference2: ReferenceModel
    var bank: BankModel
    
    var employee: ApprovalModel
    var approvedBy: ApprovalModel
    var lead: String
    var createdBy: String
    // var createdOn: Date
    // var updatedOn: Date

    init(_id: String = "", applicant: ApplicantModel = ApplicantModel(), applicant2: ApplicantModel = ApplicantModel(), mortage: MortgageModel = MortgageModel(), reference: ReferenceModel = ReferenceModel(), reference2: ReferenceModel = ReferenceModel(), bank: BankModel = BankModel(), employee: ApprovalModel = ApprovalModel(),
         approvedBy: ApprovalModel = ApprovalModel(), lead: String = "", createdBy: String = "" // ,
         
         
        // createdOn: Date = Date(),
        // updatedOn: Date = Date()
    ) {
        self._id = _id
        self.applicant = applicant
        self.applicant2 = applicant2
        self.mortgage = mortage
        self.reference = reference
        self.reference2 = reference2
        self.bank = bank
        
        self.employee = employee
        self.approvedBy = approvedBy
        self.lead = lead
        self.createdBy = createdBy
        // self.createdOn = createdOn
        // self.updatedOn = updatedOn
    }

    enum CodingKeys: String, CodingKey {
        case _id, applicant, applicant2, mortgage, reference, reference2, bank, lead, createdBy, employee, approvedBy // , createdOn, updatedOn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        _id = try container.decodeIfPresent(String.self, forKey: ._id) ?? ""
        applicant = try container.decodeIfPresent(ApplicantModel.self, forKey: .applicant) ?? ApplicantModel()
        applicant2 = try container.decodeIfPresent(ApplicantModel.self, forKey: .applicant2) ?? ApplicantModel()
        mortgage = try container.decodeIfPresent(MortgageModel.self, forKey: .mortgage) ?? MortgageModel()
        reference = try container.decodeIfPresent(ReferenceModel.self, forKey: .reference) ?? ReferenceModel()
        reference2 = try container.decodeIfPresent(ReferenceModel.self, forKey: .reference2) ?? ReferenceModel()
        bank = try container.decodeIfPresent(BankModel.self, forKey: .bank) ?? BankModel()
        
        
        employee = try container.decodeIfPresent(ApprovalModel.self, forKey: .employee) ?? ApprovalModel()
        approvedBy = try container.decodeIfPresent(ApprovalModel.self, forKey: .approvedBy) ?? ApprovalModel()
        lead = try container.decodeIfPresent(String.self, forKey: .lead) ?? ""
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy) ?? ""
        // createdOn = try container.decodeIfPresent(Date.self, forKey: .createdOn) ?? Date()
        // updatedOn = try container.decodeIfPresent(Date.self, forKey: .updatedOn) ?? Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)

        try container.encode(applicant, forKey: .applicant)
        try container.encode(applicant2, forKey: .applicant2)
        try container.encode(mortgage, forKey: .mortgage)
        try container.encode(reference, forKey: .reference)
        try container.encode(reference2, forKey: .reference2)
        try container.encode(bank, forKey: .bank)
        
        try container.encode(employee, forKey: .employee)
        try container.encode(approvedBy, forKey: .approvedBy)
        try container.encode(lead, forKey: .lead)
        try container.encode(createdBy, forKey: .createdBy)
        // try container.encode(createdOn, forKey: .createdOn)
        // try container.encode(updatedOn, forKey: .updatedOn)
    }
}
