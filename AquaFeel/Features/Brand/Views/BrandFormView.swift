//
//  BrandFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/7/24.
//

import SwiftUI

struct BrandFormView: View {
    @ObservedObject var brandManager: BrandManager

    @Binding var brand: BrandModel /* = OrderModel(
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
    @State var mode = 2

    var body: some View {
        Form {
            Section(header: Text("info")) {
                // TextField("_id", text: $order._id)
                TextField("Brand Name", text: $brand.name)
            }

            if brand._id != "" {
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
                    Button {
                        Task {
                            brandManager.brand = brand
                            if brand._id == "" {
                                try? await brandManager.save(mode: .new)
                                brand = brandManager.brand

                            } else {
                                try? await brandManager.save(mode: .edit)
                                brand = brandManager.brand
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
                brand = BrandModel()
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
                        brandManager.brand = brand
                        try await brandManager.save(mode: .delete)
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
