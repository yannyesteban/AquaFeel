//
//  CreditFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/7/24.
//

import SwiftUI


struct CreditFormView: View {
    @ObservedObject var creditManager: CreditManager
    
    @Binding var credit: CreditModel
    @State private var waiting = false
    
    @State var showAlert = false
    
    @State private var alert: Alert!
    @Environment(\.presentationMode) var presentationMode
    @State var mode = 2
    private var url: String {
        
        let userTimeZone = TimeZone.current.identifier
       
        if APIValues.port == "" {
            return APIValues.scheme + "://" + APIValues.host + "/credit/pdf?id=\(credit._id)&userTimeZone=\(userTimeZone)"
        }
        return APIValues.scheme + "://" + APIValues.host + ":\(APIValues.port)" + "/credit/pdf?id=\(credit._id)&userTimeZone=\(userTimeZone)"
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    @State private var showQR = false
    @State private var showPDFPreview = false
    @State private var pdfURL: URL?
    @State private var showActivityView = false
    
    @StateObject var brandManager = BrandManager()
    @StateObject var modelManager = ModelManager()
    
    @EnvironmentObject var profile: ProfileManager
    
    var body: some View {
        /*
         PDFOrderView()
         .background(Color.white)
         .onAppear {
         let hostingController = UIHostingController(rootView: PDFOrderView())
         hostingController.view.frame = UIScreen.main.bounds
         if let pdfURL = PDFCreator.createPDF(view: hostingController.view, fileName: "Contrato") {
         print("PDF creado en: \(pdfURL)")
         } else {
         print("Error al crear el PDF")
         }
         }
         
         */
        Form {
            /*
             if order._id != "" {
             VStack {
             /* Text(url)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding()
              */
             QRCodeView(url: url)
             .padding()
             }
             .padding()
             }
             */
            
            
            Section(header: Text("Applicant Information")) {
                //TextField("_id", text: $order._id)
                TextField("Last Name", text: $credit.applicant.lastName)
                TextField("First Name", text: $credit.applicant.firstName)
                
                TextField("SS", text: $credit.applicant.ss)
                
                DatePicker("Date of Birth", selection: $credit.applicant.dateOfBirth, displayedComponents: .date)
                TextField("DL or ID", text: $credit.applicant.id)
                DatePicker("EXP ID", selection: $credit.applicant.idExp, displayedComponents: .date)
                
                TextField("Cell Phone", text: $credit.applicant.cel)
                TextField("Home Phone", text: $credit.applicant.phone)
                
                TextField("Address", text: $credit.applicant.address)
                TextField("City", text: $credit.applicant.city)
                TextField("State", text: $credit.applicant.state)
                TextField("ZIP", text: $credit.applicant.zip)
                
                TextField("Email", text: $credit.applicant.email)
                TextField("Relationship", text: $credit.applicant.relationship)
                
                
            }
            Section(header: Text("Applicant Income Information")) {
                
                TextField("Employer", text: $credit.applicant.income.employer)
                //TextField("Years", value: $credit.applicant.income.years, formatter: NumberFormatter.IntegerFormatter)
                
                HStack {
                    Text("Years:")
                    Spacer()
                    TextField("Years", value: $credit.applicant.income.years, formatter: NumberFormatter.IntegerFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                
                HStack {
                    Text("Salary:")
                    Spacer()
                    TextField("Salary", text: $credit.applicant.income.salary)
                    /*TextField("Salary", value: $credit.applicant.income.salary, formatter: NumberFormatter.IntegerFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                     */
                }
                
                //TextField("Salary", value: $credit.applicant.income.salary, formatter: NumberFormatter.decimalFormatter)
                TextField("Position", text: $credit.applicant.income.position)
                TextField("Business Phone", text: $credit.applicant.income.phone)
                TextField("Previous Employer", text: $credit.applicant.income.preEmployer)
                
                
                TextField("Source of Other Income", text: $credit.applicant.income.otherIncome)
                
                
            }
            
            
            Section(header: Text("Co Applicant Information")) {
                //TextField("_id", text: $order._id)
                TextField("Last Name", text: $credit.applicant2.lastName)
                TextField("First Name", text: $credit.applicant2.firstName)
                
                TextField("SS", text: $credit.applicant2.ss)
                
                DatePicker("Date of Birth", selection: $credit.applicant2.dateOfBirth, displayedComponents: .date)
                
                TextField("DL or ID", text: $credit.applicant2.id)
                DatePicker("EXP ID", selection: $credit.applicant2.idExp, displayedComponents: .date)
                
                TextField("Cell Phone", text: $credit.applicant2.cel)
                TextField("Home Phone", text: $credit.applicant2.phone)
                
                //TextField("Address", text: $credit.applicant2.address)
                //TextField("City", text: $credit.applicant2.city)
                //TextField("State", text: $credit.applicant2.state)
                //TextField("ZIP", text: $credit.applicant2.zip)
                
                TextField("Email", text: $credit.applicant2.email)
                //TextField("Relationship", text: $credit.applicant2.relationship)
                
            }
            Section(header: Text("Co Applicant Income Information")) {
                TextField("Employer", text: $credit.applicant2.income.employer)
                //TextField("Years", value: $credit.applicant.income.years, formatter: NumberFormatter.IntegerFormatter)
                
                HStack {
                    Text("Years:")
                    Spacer()
                    TextField("Years", value: $credit.applicant2.income.years, formatter: NumberFormatter.IntegerFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                
                HStack {
                    Text("Salary:")
                    Spacer()
                    TextField("Salary", text: $credit.applicant2.income.salary)
                        .multilineTextAlignment(.trailing)
                    /*TextField("Salary", value: $credit.applicant2.income.salary, formatter: NumberFormatter.IntegerFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)*/
                }
                
                //TextField("Salary", value: $credit.applicant.income.salary, formatter: NumberFormatter.decimalFormatter)
                TextField("Position", text: $credit.applicant2.income.position)
                TextField("Business Phone", text: $credit.applicant2.income.phone)
                TextField("Previous Employer", text: $credit.applicant2.income.preEmployer)
                
                TextField("Source of Other Income", text: $credit.applicant2.income.otherIncome)
                
                
            }
            
            Section(header: Text("Mortgage Information")) {
                HStack {
                    //Image(systemName: "calendar").font(.system(size: 20, weight: .light))
                    Picker("Status", selection: $credit.mortgage.status) {
                        Text("Paid").tag("Paid")
                        Text("Rent").tag("Rent")
                        Text("Mortgaged").tag("Mortgaged")
                        
                    }
                    
                   
                }
                
                TextField("Mortgage Company", text: $credit.mortgage.mortgageCompany)
                //TextField("Monthly Payment", value: $credit.mortage.monthlyPayment, formatter: NumberFormatter.decimalFormatter)
                //TextField("How Long Here", value: $credit.mortage.howlong, formatter: NumberFormatter.IntegerFormatter)
                
                HStack {
                    Text("Monthly Payment:")
                    Spacer()
                    TextField("Monthly Payment", value: $credit.mortgage.monthlyPayment, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                
                HStack {
                    Text("How Long Here:")
                    Spacer()
                    TextField("How Long Here", text: $credit.mortgage.howlong)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                
                /*
                TextField("Total Cash", value: $order.price.totalCash, formatter: NumberFormatter.decimalFormatter)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 150)
                */
            }
         
            
            Section(header: Text("Personal Reference")) {
                TextField("Name", text: $credit.reference.name)
                TextField("Relationship", text: $credit.reference.relationship)
                TextField("Phone", text: $credit.reference.phone)
                
            }
            
            
            Section(header: Text("Personal Reference")) {
                TextField("Name", text: $credit.reference2.name)
                TextField("Relationship", text: $credit.reference2.relationship)
                TextField("Phone", text: $credit.reference2.phone)
                
            }
            
            Section(header: Text("Personal Reference")) {
                TextField("Bank Name", text: $credit.bank.name)
                TextField("Account Number", text: $credit.bank.accountNumber)
                TextField("Routing Number", text: $credit.bank.routingNumber)
               
                Toggle(isOn: $credit.bank.checking) {
                    Text("Checking")
                }
                
                Toggle(isOn: $credit.bank.savings) {
                    Text("Saving")
                }
            }
            
            Section {
                Text("Applicant Sign \(credit.applicant.firstName) \(credit.applicant.lastName)")
                SignView(sign: $credit.applicant.signature)
                DatePicker("Date", selection: $credit.applicant.date, displayedComponents: .date)
            } header: {
                Text("Applicant")
            }
            
            
            Section {
                Text("Co Applicant Sign \(credit.applicant2.firstName) \(credit.applicant2.lastName)")
                SignView(sign: $credit.applicant2.signature)
                DatePicker("Date", selection: $credit.applicant2.date, displayedComponents: .date)
            } header: {
                Text("Co Applicant")
            }
          
            Section {
                Text("\(profile.info.firstName) \(profile.info.lastName)")
                //TextField("Rep. of Aquafeel", text: $order.employee.name)
                SignView(sign: $credit.employee.signature)
                
            } header: {
                Text("Rep. of Aquafeel")
            }
            
            
            /*
            
            Section {
                Text("Approval / Purchaser \(credit.buyer1.name)")
                SignView(sign: $credit.buyer1.signature)
                DatePicker("Date", selection: $credit.buyer1.date, displayedComponents: .date)
            } header: {
                Text("Approval / Purchaser 1")
            }
            
            Section {
                Text("Approval / Purchaser: \(credit.buyer2.name)")
                SignView(sign: $credit.buyer2.signature)
                DatePicker("Date", selection: $credit.buyer2.date, displayedComponents: .date)
            } header: {
                Text("Approval / Purchaser 2")
            }
            
            
            Section {
                Text("\(profile.info.firstName) \(profile.info.lastName)")
                //TextField("Rep. of Aquafeel", text: $order.employee.name)
                SignView(sign: $credit.employee.signature)
                
            } header: {
                Text("Rep. of Aquafeel")
            }
            
            */
            
            if credit._id != "" {
                Section {
                    Button {
                        doDelete()
                    } label: {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }.foregroundColor(.red)
                }
            }
            
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if waiting {
                    ProgressView("")
                } else {
                    if credit._id != "" {
                        Button {
                            self.showQR = true
                        } label: {
                            Label("show QR", systemImage: "qrcode")
                                .font(.callout)
                                .foregroundColor(.green)
                        }
                    }
                    if credit._id != "" {
                        Button {
                            self.showPDFPreview = true
                        } label: {
                            Label("print", systemImage: "square.and.arrow.up")
                                .font(.callout)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button {
                        Task {
                            credit.createdBy = profile.userId
                            creditManager.credit = credit
                            if credit._id == "" {
                                do {
                                    try await creditManager.save(mode: .new)
                                    credit = creditManager.credit
                                    setAlert(title: "Message", message: "record updated correctly!")
                                } catch {
                                    setAlert(title: "", message: "")
                                }
                                
                                
                            } else {
                                //try? await orderManager.save(mode: .edit)
                                do {
                                    try await creditManager.save(mode: .edit)
                                    credit = creditManager.credit
                                    setAlert(title: "Message", message: "record updated correctly!")
                                } catch {
                                    setAlert(title: "", message: "")
                                }
                                //order = orderManager.order
                            }
                            
                            // Acciones adicionales si son necesarias
                        }
                    } label: {
                        Label("Save", systemImage: "externaldrive.fill")
                            .font(.title3)
                    }
                }
            }
        }
        
        
        
        .sheet(isPresented: $showQR) {
            QRCodeView(url: url)
                .padding()
        }
        .sheet(isPresented: $showPDFPreview) {
            NavigationStack {
                let pdfURL = URL(string: url)
                
                if let url = pdfURL {
                    PDFViewer(url: url)
                        .edgesIgnoringSafeArea(.all)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    self.showActivityView = true
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                        .sheet(isPresented: $showActivityView) {
                            if let pdfData = try? Data(contentsOf: url) {
                                ActivityViewController(activityItems: [pdfData])
                            }
                        }
                } else {
                    Text(pdfURL?.absoluteString ?? "nada...")
                }
            }
            
            /*
             if let url = pdfURL {
             // PDFPreview(url: url)
             PDFViewer(url: url)
             .edgesIgnoringSafeArea(.all)
             } else {
             Text( pdfURL?.absoluteURL.absoluteString ?? "nada...")
             }
             */
        }
        .alert(isPresented: $showAlert) {
            alert
        }
        
        .onAppear{
            
            if mode == 1 {
                credit = CreditModel()
            }
            
            Task {
                await modelManager.list(userId:"");
                await brandManager.list(userId:"");
            }
        }
    }
    
    private func setAlert(title: String, message: String) {
        alert = Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        showAlert = true
    }
    
    private func doDelete() {
        print("delete...")
        // resourceManager.token = profile.token
        alert = Alert(
            title: Text("Confirmation"),
            message: Text("Are you sure you want to delete the contract?"),
            primaryButton: .destructive(Text("Delete")) {
                Task {
                    do {
                        creditManager.credit = credit
                        try await creditManager.save(mode: .delete)
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        setAlert(title: "Error", message: "Failure, the operation was not completed.")
                    }
                }
            },
            secondaryButton: .cancel()
        )
        
        showAlert = true
    }
    
    
}
