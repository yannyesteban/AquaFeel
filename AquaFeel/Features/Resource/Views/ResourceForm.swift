//
//  AddResourceForm.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/5/24.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

import MobileCoreServices

struct FileImporterView: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Binding var fileData: Data?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item, .commaSeparatedText])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileImporterView

        init(_ parent: FileImporterView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            // Security scoped access
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                parent.fileURL = url
                if let data = try? Data(contentsOf: url) {
                    parent.fileData = data
                }
            } else {
                print("Could not access file: \(url)")
            }

            // parent.fileURL = urls.first
            // parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ResourceForm: View {
    var profile: ProfileManager
    @ObservedObject var resourceManager = ResourceManager()
    @Environment(\.presentationMode) var presentationMode
    @Binding var resources: [ResourceModel]

    @Binding var resource: ResourceModel

    // @State private var description = ""
    // @State private var type: ResourceType = .pdf
    // @State private var active = false
    // @State private var createdBy = ""
    @State private var selectedFileURL: URL?
    @State var fileData: Data?
    @State private var showingFileImporter = false

    @State private var fileURL: URL?
    @State private var isWaiting = false

    @State var showAlert = false
    @State private var alert: Alert!

    @State var mode: RecordMode = .new

    var onSave: (ResourceModel, RecordMode) -> Void
    var body: some View {
        NavigationView {
            Form {
                TextField("Description", text: $resource.description)
                Picker("Resource Type", selection: $resource.type) {
                    ForEach(ResourceType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                Toggle("Active", isOn: $resource.active)
                // TextField("Created By", text: $createdBy)
                Button(action: {
                    showingFileImporter = true
                }) {
                    Text("Select File")
                }
                if let url = selectedFileURL {
                    // Text("Selected File: \(resource.fileName)")
                    Text("Selected File: \(url.lastPathComponent)")
                }
                Section {
                    Button(action: {
                        doDelete()

                    }) {
                        HStack {
                            Text("Delete")
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isWaiting {
                        ProgressView("")

                    } else {
                        Button {
                            if let _ = selectedFileURL {
                                doSave()
                            } else {
                                doEdit()
                            }

                        } label: {
                            Label("Save", systemImage: "externaldrive.fill")
                                .font(.title3)
                        }
                    }
                }
            }

            .navigationTitle("Add Resource")

            .sheet(isPresented: $showingFileImporter) {
                FileImporterView(fileURL: $selectedFileURL, fileData: $fileData)
            }
            .onChange(of: selectedFileURL) { value in
                DispatchQueue.main.async {
                    if let value {
                        resource.fileName = value.lastPathComponent
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                alert
            }
        }
    }

    private func setAlert(title: String, message: String) {
        alert = Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        showAlert = true
    }

    private func doSave() {
        let alertMessage = resource.validForm()

        if alertMessage != "" {
            setAlert(title: "Message", message: alertMessage)
            return
        }

        guard let fileData = fileData else {
            return
        }
        guard let fileURL = selectedFileURL else {
            setAlert(title: "Message", message: String(localized: "invalid file"))
            return
        }
        isWaiting = true
        resourceManager.token = profile.token

        resourceManager.uploadResource(resource: resource, fileURL: fileURL, fileData: fileData, mode: mode) { result in

            switch result {
            case let .success(item):
                if mode == .new {
                    DispatchQueue.main.async {
                        resource.recordMode = .edit
                        resource.id = item.id
                        resource.fileName = item.fileName
                        mode = .edit

                        addResource(resource: item)
                    }
                }

                setAlert(title: "Message", message: "Resource was saved correctly!")
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }

            case let .failure(error):

                print(error.localizedDescription)
                setAlert(title: "Error", message: "Failure, the operation was not completed.")

                DispatchQueue.main.async {
                    // presentationMode.wrappedValue.dismiss()
                }
            }

            isWaiting = false
            Task {
                try? await resourceManager.list()
            }
        }
    }

    private func doEdit() {
        let alertMessage = resource.validForm()

        if alertMessage != "" {
            setAlert(title: "Message", message: alertMessage)
            return
        }

        isWaiting = true
        resourceManager.token = profile.token
        Task {
            await resourceManager.edit(body: resource) { result in
                switch result {
                case let .success(item):
                    if mode == .new {
                        DispatchQueue.main.async {
                            resource.recordMode = .edit
                            resource.id = item.id
                            resource.fileName = item.fileName
                            mode = .edit
                        }
                        print(item.active)
                    }

                    setAlert(title: "Message", message: "Resource was saved correctly!")
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                case let .failure(error):
                    print(error.localizedDescription)
                    setAlert(title: "Error", message: "Failure, the operation was not completed.")
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                isWaiting = false
            }
        }
    }

    private func doDelete() {
        resourceManager.token = profile.token
        alert = Alert(
            title: Text("Confirmation"),
            message: Text("Are you sure you want to delete the resource?"),
            primaryButton: .destructive(Text("Delete")) {
                Task {
                    await resourceManager.delete(body: resource) { result in
                        switch result {
                        case .success:

                            DispatchQueue.main.async {
                                presentationMode.wrappedValue.dismiss()
                            }
                        case let .failure(error):
                            print("Error: \(error.localizedDescription)")
                            setAlert(title: "Error", message: "Failure, the operation was not completed.")
                        }
                    }
                }
            },
            secondaryButton: .cancel()
        )

        showAlert = true
    }

    private func selectFile() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])

        let delegate = MyPDFPickerDelegate()
        picker.delegate = delegate
        picker.present(picker, animated: true)
        // UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }

    private func addResource(resource: ResourceModel) {
        DispatchQueue.main.async {
            resources.append(resource)
        }
        prettyPrint(resource)
    }
    /*
     func uploadPDF(fileURL: URL) {
         guard let url = URL(string: "http://10.0.0.30:4000/profile/upload-avatar") else { return }
         var request = URLRequest(url: url)
         request.httpMethod = "POST"

         let boundary = UUID().uuidString
         request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         request.setValue("Bearer \(profile.token)", forHTTPHeaderField: "Authorization")

         var data = Data()
         data.append("--\(boundary)\r\n".data(using: .utf8)!)
         data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
         data.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)

         do {
             let fileData = try Data(contentsOf: fileURL)
             data.append(fileData)
         } catch {
             print("Error reading file data: \(error)")
             return
         }

         data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

         URLSession.shared.uploadTask(with: request, from: data) { responseData, _, error in
             if let error = error {
                 print("Error uploading PDF: \(error)")
                 return
             }

             guard let responseData = responseData else {
                 print("No data received in response")
                 return
             }

             if let jsonResponse = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                 print("Response JSON: \(jsonResponse)")
             }
         }.resume()
     }
      */
}

class MyPDFPickerDelegate: NSObject, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        // Inform your SwiftUI view about the selection (e.g., using @StateObject or Combine)
    }
}
