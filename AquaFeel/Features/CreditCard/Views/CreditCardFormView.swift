//
//  CreditCardFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/8/24.
//

import SwiftUI

struct CreditCardFormView: View {
    @ObservedObject var creditManager: CreditCardManager
    
    @Binding var credit: CreditCardModel
    @State private var waiting = false
    
    @State var showAlert = false
    
    @State private var alert: Alert!
    @Environment(\.presentationMode) var presentationMode
    @State var mode = 2
    private var url: String {
        var components = URLComponents()
            components.scheme = APIValues.scheme
            components.host = APIValues.host
            components.port = APIValues.port
            components.path = "/creditcard/pdf"
            components.queryItems = [
                URLQueryItem(name: "id", value: credit._id),
                URLQueryItem(name: "userTimeZone", value: TimeZone.current.identifier)
            ]
            return components.url?.absoluteString ?? ""
        
        
        /*
         let userTimeZone = TimeZone.current.identifier
        
        
        if APIValues.port == "" {
            return APIValues.scheme + "://" + APIValues.host + "/creditcard/pdf?id=\(credit._id)&userTimeZone=\(userTimeZone)"
        }
        return APIValues.scheme + "://" + APIValues.host + ":\(APIValues.port)" + "/creditcard/pdf?id=\(credit._id)&userTimeZone=\(userTimeZone)"
         */
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
       
        Form {
           
            
            
            Section(header: Text("Applicant Information")) {
                //TextField("_id", text: $order._id)
                
                TextField("Last Name", text: $credit.lastName)
                TextField("First Name", text: $credit.firstName)
                TextField("License", text: $credit.license)
                TextField("Phone", text: $credit.phone)
                TextField("Country", text: $credit.country)
                TextField("Address", text: $credit.address)
                TextField("City", text: $credit.city)
                TextField("State", text: $credit.state)
                TextField("ZIP", text: $credit.zip)
                
            }
            
            Section(header: Text("Card Information")) {
                TextField("Products", text: $credit.products)
                DatePicker("Date", selection: $credit.date, displayedComponents: .date)
                
                
                HStack {
                    Text("Amount:")
                    Spacer()
                    
                    TextField("Amount", value: $credit.amount, formatter: NumberFormatter.IntegerFormatter)
                     .multilineTextAlignment(.trailing)
                     .keyboardType(.decimalPad)
                     .frame(maxWidth: 150)
                    
                }
                
                HStack {
                    //Image(systemName: "calendar").font(.system(size: 20, weight: .light))
                    Picker("Status", selection: $credit.typeCard) {
                        Text("VISA").tag("VISA")
                        Text("MASTERCARD").tag("MASTERCARD")
                        Text("AMERICAN EXPRESS").tag("AMERICAN EXPRESS")
                        
                    }
                    
                    
                }
                TextField("Credit Card", text: $credit.numberCard)
                DatePicker("EXP Date", selection: $credit.expCard, displayedComponents: .date)
                TextField("Name as appears on the Card", text: $credit.nameCard)
                TextField("CVC", text: $credit.cvcCard)
                
                
                
            }
            
            Section {
                Text("Applicant Sign \(credit.firstName) \(credit.lastName)")
                SignView(sign: $credit.signature)
                DatePicker("Date", selection: $credit.date, displayedComponents: .date)
            } header: {
                Text("Applicant")
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
                            creditManager.creditCard = credit
                            if credit._id == "" {
                                do {
                                    try await creditManager.save(mode: .new)
                                    credit = creditManager.creditCard
                                    setAlert(title: "Message", message: "record updated correctly!")
                                } catch {
                                    setAlert(title: "", message: "")
                                }
                                
                                
                            } else {
                                //try? await orderManager.save(mode: .edit)
                                do {
                                    try await creditManager.save(mode: .edit)
                                    credit = creditManager.creditCard
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
                credit = CreditCardModel()
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
       
        // resourceManager.token = profile.token
        alert = Alert(
            title: Text("Confirmation"),
            message: Text("Are you sure you want to delete the contract?"),
            primaryButton: .destructive(Text("Delete")) {
                Task {
                    do {
                        creditManager.creditCard = credit
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
    
    
    func cardType(for number: String) -> String? {
        let visaRegex = "^4[0-9]{12}(?:[0-9]{3})?$"
        let masterCardRegex = "^(?:5[1-5][0-9]{14}|2(?:22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7(?:[01][0-9]|20))[0-9]{12})$"
        let amexRegex = "^3[47][0-9]{13}$"
        
        if number.range(of: visaRegex, options: .regularExpression) != nil {
            return "Visa"
        } else if number.range(of: masterCardRegex, options: .regularExpression) != nil {
            return "Mastercard"
        } else if number.range(of: amexRegex, options: .regularExpression) != nil {
            return "American Express"
        }
        
        return nil
    }
    
}

