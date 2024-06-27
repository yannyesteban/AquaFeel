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

    var body: some View {
        if let qrCodeImage = generateQRCode(from: url) {
            Image(uiImage: qrCodeImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
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
}

struct OrderFormView: View {
    @ObservedObject var orderManager: OrderManager

    @Binding var order: OrderModel /* = OrderModel(
         id: UUID().uuidString,
         buyer1: BuyerModel(),
         buyer2: BuyerModel(),
         address: "",
         city: "",
         state: "",
         zip: "",
         system1: SystemModel(),
         system2: SystemModel(),
         installation: InstallModel(),
         people: 0,
         creditCard: false,
         check: false,
         price: PriceModel()
     )
     */
    @State private var waiting = false

    @State var showAlert = false
    @State private var alert: Alert!
    @Environment(\.presentationMode) var presentationMode

    private var url: String {
        if APIValues.port == "" {
            return APIValues.scheme + "://" + APIValues.host + "/orders/pdf?id=\(order._id)"
        }
        return APIValues.scheme + "://" + APIValues.host + ":\(APIValues.port)" + "/orders/pdf?id=\(order._id)"
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
                TextField("_id", text: $order._id)
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

            Section(header: Text("System Information 1")) {
                TextField("System 1 Name", text: $order.system1.name)
                TextField("System 1 Brand", text: $order.system1.brand)
                TextField("System 1 Model", text: $order.system1.model)
            }

            Section(header: Text("System Information 2")) {
                TextField("System 2 Name", text: $order.system2.name)
                TextField("System 2 Brand", text: $order.system2.brand)
                TextField("System 2 Model", text: $order.system2.model)

                TextField("Promotion", text: $order.promotion)
            }

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
                Toggle("Ice Maker", isOn: $order.installation.iceMaker)
                // Stepper("Time (hours): \(order.installation.time)", value: $order.installation.time, in: 0 ... 24)
            }

            Section(header: Text("People Involved")) {
                Stepper("People: \(order.people)", value: $order.people, in: 1 ... 20)
                Text(order.floorType)
                HStack {
                    /* Image(systemName: "map")
                     .font(.system(size: 20, weight: .light)) */
                    Picker("The floor is", selection: $order.floorType) {
                        Text("Raised").tag("raised")
                        Text("Concret Slab").tag("concret")
                    }
                }
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
                    Text("Terms Amount:")
                    Spacer()
                    TextField("Terms Amount", value: $order.price.terms.amount, formatter: NumberFormatter.decimalFormatter)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 150)
                }

                HStack {
                    Text("APR:")
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
                TextField("Approval / Purchaser", text: $order.approval1.purchaser)
                DatePicker("Date", selection: $order.approval1.date, displayedComponents: .date)
            } header: {
                Text("Approval / Purchaser 1")
            }

            Section {
                TextField("Approval / Purchaser", text: $order.approval2.purchaser)
                DatePicker("Date", selection: $order.approval2.date, displayedComponents: .date)
            } header: {
                Text("Approval / Purchaser 2")
            }

            Section {
                TextField("Rep. of Aquafeel", text: $order.employee)
                TextField("App central off", text: $order.approvedBy)
            } header: {
                Text("Approved for")
            }

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
                            Label("print", systemImage: "printer.fill")
                                .font(.callout)
                                .foregroundColor(.green)
                        }
                    }

                    Button {
                        Task {
                            orderManager.order = order
                            if order._id == "" {
                                try? await orderManager.save(mode: .new)
                                order = orderManager.order

                            } else {
                                try? await orderManager.save(mode: .edit)
                                order = orderManager.order
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

/*
 struct OrderFormView_Previews: PreviewProvider {
     static var previews: some View {
         let buyer1 = BuyerModel(id: "1", name: "John Doe", phone: "123-456-7890", cel: "098-765-4321")
         let buyer2 = BuyerModel(id: "2", name: "Jane Smith", phone: "123-456-7890", cel: "098-765-4321")
         let system1 = SystemModel(id: "1", name: "Water Purifier", brand: "AquaBrand", model: "Model X")
         let system2 = SystemModel(id: "2", name: "Water Softener", brand: "AquaBrand", model: "Model Y")
         let installation = InstallModel(id: "1", day: "Monday", date: Date(), iceMaker: true, time: 2)
         let terms = TermsModel(unit: "months", amount: 12)
         let price = PriceModel(cashPrice: 1000, installation: 100, taxes: 80, totalCash: 1180, downPayment: 180, toFinance: 1000, terms: terms, APR: 5, finaceCharge: 50)
         let order = OrderModel(id: "1", buyer1: buyer1, buyer2: buyer2, address: "123 Main St", city: "Metropolis", state: "NY", zip: "12345", system1: system1, system2: system2, installation: installation, people: 3, creditCard: true, check: false, price: price)

         OrderFormView(orderManager: OrderManager())
     }
 }
 */
