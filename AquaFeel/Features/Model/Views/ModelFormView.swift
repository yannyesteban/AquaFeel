//
//  ModelFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import SwiftUI

struct ModelFormView: View {
    @ObservedObject var modelManager: ModelManager

    @Binding var model: ModelModel /* = OrderModel(
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
    @State var brands: [BrandModel] = []
    @State private var alert: Alert!
    @Environment(\.presentationMode) var presentationMode
    @State var mode = 2

    @StateObject var brandManager = BrandManager()

    var body: some View {
        Form {
            HStack {
                Image(systemName: "folder.fill.badge.plus")
                    .font(.system(size: 20, weight: .light))

                if !brandManager.brands.isEmpty {
                    Picker("Brand", selection: $model.brand._id) {
                        Text("select Brand...").tag("")
                        ForEach(brandManager.brands, id: \._id) { brand in
                            Text(brand.name).tag(brand._id)
                        }
                    }
                }
            }

            TextField("Model Name", text: $model.name)

            if model._id != "" {
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
                    Button {
                        Task {
                            modelManager.model = model
                            if model._id == "" {
                                try? await modelManager.save(mode: .new)
                                model = modelManager.model

                            } else {
                                try? await modelManager.save(mode: .edit)
                                model = modelManager.model
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

        .alert(isPresented: $showAlert) {
            alert
        }

        .onAppear {
            if mode == 1 {
                model = ModelModel()
            }
            Task {
                await brandManager.list(userId: "")
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
                        modelManager.model = model
                        try await modelManager.save(mode: .delete)
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
