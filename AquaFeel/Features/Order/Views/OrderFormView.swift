//
//  OrderFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 18/6/24.
//

import SwiftUI

import CoreImage.CIFilterBuiltins

extension NumberFormatter {
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.generatesDecimalNumbers = true
        return formatter
    }
}

extension NumberFormatter {
    static var IntegerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        formatter.generatesDecimalNumbers = true
        return formatter
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct QRCodeView: View {
    let url: String
    @State private var textToCopy: String = ""
    @State private var isCopied = false
    var body: some View {
        if let qrCodeImage = generateQRCode(from: url) {
            Image(uiImage: qrCodeImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            //TextField("Enter text to copy", text: $textToCopy)
            if !isCopied {
                Button {
                    copyTextToClipboard()
                } label: {
                    Label("Copy", systemImage: "rectangle.on.rectangle")
                    
                }
            } else {
                Label("Copied", systemImage: "checkmark")
                    .foregroundColor(.green)
            }
            
           
        } else {
            Text("The QR code could not be generated")
        }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    private func copyTextToClipboard() {
       
        UIPasteboard.general.string = url
        isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isCopied = false
        }
    }
}


struct OrderFormView: View {
    @ObservedObject var orderManager: OrderManager

    @Binding var order: OrderModel
    @State private var waiting = false

    @State var showAlert = false
    
    @State private var alert: Alert!
    @Environment(\.presentationMode) var presentationMode
    @State var mode = 2
    private var url: String {
        
        let userTimeZone = TimeZone.current.identifier
       
        if APIValues.port == "" {
            return APIValues.scheme + "://" + APIValues.host + "/orders/pdf?id=\(order._id)&userTimeZone=\(userTimeZone)"
        }
        return APIValues.scheme + "://" + APIValues.host + ":\(APIValues.port)" + "/orders/pdf?id=\(order._id)&userTimeZone=\(userTimeZone)"
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
            
            
            Section(header: Text("Buyer1 Information")) {
                //TextField("_id", text: $order._id)
                TextField("Buyer 1 Name", text: $order.buyer1.name)
                TextField("Buyer 1 Phone", text: $order.buyer1.phone)
                TextField("Buyer 1 Cell", text: $order.buyer1.cel)
            }

            Section(header: Text("Buyer2 Information")) {
                TextField("Buyer 2 Name", text: $order.buyer2.name)
                TextField("Buyer 2 Phone", text: $order.buyer2.phone)
                TextField("Buyer 2 Cell", text: $order.buyer2.cel)
            }

            Section(header: Text("Address Information")) {
                TextField("Address", text: $order.address)
                TextField("City", text: $order.city)
                TextField("State", text: $order.state)
                TextField("ZIP", text: $order.zip)
            }

            Section(header: Text("System Information")) {
                Toggle("Whole House Aquafeel System", isOn: $order.installation.s0)
                Toggle("Reverse Osmosis", isOn: $order.installation.s1)
                Toggle("Reverse Osmosis + Alkaline", isOn: $order.installation.s2)
                Toggle("Natural Soap Package", isOn: $order.installation.s3)
               
                
            }
            
            
            Section(header: Text("Promotion")) {
                
                TextField("Promotion", text: $order.promotion)
            }
            
            /*
            Section(header: Text("System Information 1")) {
                TextField("System 1 Name", text: $order.system1.name)
                Picker("Brand", selection: $order.system1.brand) {
                    Text("select a brand...").tag("")
                    ForEach(brandManager.brands, id: \._id) { brand in
                        Text(brand.name).tag(brand.name)
                    }
                    
                }
                Picker("Model", selection: $order.system1.model) {
                    Text("select a model...").tag("")
                    ForEach(modelManager.models, id: \._id) { model in
                        Text(model.name).tag(model.name)
                    }
                    
                }
                //TextField("System 1 Brand", text: $order.system1.brand)
                //TextField("System 1 Model", text: $order.system1.model)
            }

             
            Section(header: Text("System Information 2")) {
                TextField("System 2 Name", text: $order.system2.name)
                
                Picker("Brand", selection: $order.system2.brand) {
                    Text("select a brand...").tag("")
                    ForEach(brandManager.brands, id: \._id) { brand in
                        Text(brand.name).tag(brand.name)
                    }
                    
                }
                Picker("Model", selection: $order.system2.model) {
                    Text("select a model...").tag("")
                    ForEach(modelManager.models, id: \._id) { model in
                        Text(model.name).tag(model.name)
                    }
                    
                }
                //TextField("System 2 Brand", text: $order.system2.brand)
                //TextField("System 2 Model", text: $order.system2.model)

                TextField("Promotion", text: $order.promotion)
            }

             */
            Section(header: Text("Installation Information")) {
                TextField("Installation Day", text: $order.installation.day)
                DatePicker("Installation Date", selection: $order.installation.date, displayedComponents: [.date, .hourAndMinute])
                HStack {
                    /* Image(systemName: "map")
                     .font(.system(size: 20, weight: .light)) */

                    Picker("Water source", selection: $order.installation.waterSouce) {
                        Text("City").tag("city")
                        Text("Well").tag("well")
                    }
                }
                //Toggle("Ice Maker", isOn: $order.installation.iceMaker)
                // Stepper("Time (hours): \(order.installation.time)", value: $order.installation.time, in: 0 ... 24)
            }

            Section(header: Text("People Involved")) {
                Stepper("People: \(order.people)", value: $order.people, in: 1 ... 20)
                /*
                HStack {
                    
                    Picker("The floor is", selection: $order.floorType) {
                        Text("Raised").tag("raised")
                        Text("Concret Slab").tag("concret")
                    }
                }
                 */
            }

            Section(header: Text("Terms or Payment Methods")) {
                Toggle("Credit Card", isOn: $order.creditCard)
                Toggle("Check", isOn: $order.check)
            }

            Section(header: Text("Price Information")) {
                HStack {
                    Text("Cash Price:")
                    Spacer()
                    TextField("Cash Price", value: $order.price.cashPrice, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Installation:")
                    Spacer()
                    TextField("Installation", value: $order.price.installation, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Taxes:")
                    Spacer()
                    TextField("Taxes", value: $order.price.taxes, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Total Cash:")
                    Spacer()
                    TextField("Total Cash", value: $order.price.totalCash, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Down Payment:")
                    Spacer()
                    TextField("Down Payment", value: $order.price.downPayment, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Total Cash Price:")
                    Spacer()
                    TextField("Total Cash Price", value: $order.price.totalCashPrice, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Amount to Finance:")
                    Spacer()
                    TextField("Amount to Finance", value: $order.price.toFinance, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                
                
               

                HStack {
                    Text("APR ( % ):")
                    Spacer()
                    TextField("APR", value: $order.price.APR, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("Finance Charge:")
                    Spacer()
                    TextField("Finance Charge", value: $order.price.finaceCharge, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                
                HStack {
                    Text("Total of Payments:")
                    Spacer()
                    TextField("Total of Payments", value: $order.price.totalPayments, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
            }

            Section {
                HStack {
                    Text("Terms Amount:")
                    Spacer()
                    TextField("Number of Payment", value: $order.price.terms.amount, format: .number)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }
                Picker("Interval to Finance", selection: $order.price.terms.unit) {
                    Text("MONTH").tag("MONTH")
                    
                    
                }
            } header: {
                Text("Terms Amount:")
            }
            
            Section {
                Text("Approval / Purchaser \(order.buyer1.name)")
                SignView(sign: $order.buyer1.signature)
                DatePicker("Date", selection: $order.buyer1.date, displayedComponents: .date)
            } header: {
                Text("Approval / Purchaser 1")
            }

            Section {
                Text("Approval / Purchaser: \(order.buyer2.name)")
                SignView(sign: $order.buyer2.signature)
                DatePicker("Date", selection: $order.buyer2.date, displayedComponents: .date)
            } header: {
                Text("Approval / Purchaser 2")
            }
            
            
            Section {
                Text("\(profile.info.firstName) \(profile.info.lastName)")
                //TextField("Rep. of Aquafeel", text: $order.employee.name)
                SignView(sign: $order.employee.signature)
                
            } header: {
                Text("Rep. of Aquafeel")
            }
            /*
            Section {
                
                TextField("App central off", text: $order.approvedBy.name)
                SignView(sign: $order.approvedBy.signature)
            } header: {
                Text("App central off")
            }
            
            */
            

            if order._id != "" {
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
            
            /*
             Button(action: {
                 let data = workOrderPDF(order: order, url: "https://google.com")
                 // let data = createPDFWithContent();
                 generatePDF(data: data, name: "workOrder.pdf") { url in

                     self.pdfURL = url
                     self.showPDFPreview = true
                 }
             }) {
                 Text("Show PDF")
             }

              Button {
                  orderManager.createOrder(order: order)
              } label: {
                  Text("Create Order")
              }
               */
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if waiting {
                    ProgressView("")
                } else {
                    if order._id != "" {
                        Button {
                            self.showQR = true
                        } label: {
                            Label("show QR", systemImage: "qrcode")
                                .font(.callout)
                                .foregroundColor(.green)
                        }
                    }
                    if order._id != "" {
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
                            order.createdBy = profile.userId
                            orderManager.order = order
                            if order._id == "" {
                                do {
                                    try await orderManager.save(mode: .new)
                                    order = orderManager.order
                                    setAlert(title: "Message", message: "record updated correctly!")
                                } catch {
                                    setAlert(title: "", message: "")
                                }
                                

                            } else {
                                //try? await orderManager.save(mode: .edit)
                                do {
                                    try await orderManager.save(mode: .edit)
                                    order = orderManager.order
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
            print(profile.userId, ",,,,,")
            if mode == 1 {
                order = OrderModel()
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
                        orderManager.order = order
                        try await orderManager.save(mode: .delete)
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


 struct OrderFormView_Previews: PreviewProvider {
    
     static var previews: some View {
         @State var leadId: String = ""
         @State var order:OrderModel = OrderModel()
         
         @StateObject var orderManager: OrderManager = .init()
         
         @StateObject var profile = ProfileManager()

         OrderFormView(orderManager: OrderManager(), order: $order).environmentObject(profile)
     }
 }
 
