//
//  LeadResourceForm.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 1/10/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct LeadResourceForm: View {
    var profile: ProfileManager
    var leadId: String
    @ObservedObject var resourceManager = LeadResourceManager()
    @Environment(\.presentationMode) var presentationMode
    @Binding var resources: [LeadResourceModel]

    @Binding var resource: LeadResourceModel

    // @State private var description = ""
    // @State private var type: ResourceType = .pdf
    // @State private var active = false
    // @State private var createdBy = ""
    @State private var selectedFileURL: URL?
    @State var fileData: Data?
    @State private var showingFileImporter = false
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    @State private var fileURL: URL?
    @State private var isWaiting = false

    @State var showAlert = false
    @State private var alert: Alert!

    @State var mode: RecordMode = .new
    

    let compressionQuality = 0.5
    private var url: String {
        var components = URLComponents()
        components.scheme = APIValues.scheme
        components.host = APIValues.host
        components.port = APIValues.port
        components.path = "/uploads/\(resource.fileName)"

        return components.url?.absoluteString ?? ""
        
        /*
        if APIValues.port == "" {
            return APIValues.scheme + "://" + APIValues.host + "/uploads/\(resource.fileName)"
        }
        return APIValues.scheme + "://" + APIValues.host + ":\(APIValues.port)" + "/uploads/\(resource.fileName)"
         */
    }

    var onSave: (ResourceModel, RecordMode) -> Void
    var body: some View {
        NavigationView {
            Form {
                TextField("Description", text: $resource.description)
                /*
                 Picker("Resource Type", selection: $resource.type) {
                     ForEach(ResourceType.allCases) { t in
                         Text(t.rawValue).tag(t)
                     }
                 }
                 */
                // Toggle("Active", isOn: $resource.active)

                if mode == .new {
                    
                    Section {
                        
                        Button(action: {
                            showingFileImporter = true
                        }) {
                            Label("Select File", systemImage: "doc")
                        }
                        .sheet(isPresented: $showingFileImporter) {
                            FileImporterView(fileURL: $selectedFileURL, fileData: $fileData)
                        }
                        
                        Button(action: {
                            showingCamera = true
                        }) {
                            Label("Take Photo with Camera", systemImage: "camera")
                        }
                        .sheet(isPresented: $showingCamera) {
                            CameraView(image: $selectedImage){ image in
                                
                                if let imageData = image.jpegData(compressionQuality: compressionQuality) {
                                    self.fileData = imageData
                                    self.selectedFileURL = URL(filePath: "image.jpg") // No hay URL para la imagen capturada
                                }
                            }
                        }
                        
                        
                        Button(action: {
                            showingImagePicker.toggle()
                        }) {
                            Label("Choose from Library", systemImage: "photo")
                        }
                        .sheet(isPresented: $showingImagePicker) {
                            AvatarPicker(selectedImage: $selectedImage, sourceType: .photoLibrary) { image in
                                
                                if let imageData = image.jpegData(compressionQuality: compressionQuality) {
                                    self.fileData = imageData
                                    self.selectedFileURL = URL(filePath: "image.jpg") // No hay URL para la imagen capturada
                                }
                            }
                        }
                    }
                }

                if let url = selectedFileURL {
                    // Text("Selected File: \(resource.fileName)")
                    Text("Selected File: \(url.lastPathComponent)")
                }

                // Mostrar imagen seleccionada
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else if let url = selectedFileURL, url.pathExtension.lowercased() != "pdf", let fileData = fileData, let image = UIImage(data: fileData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else if mode == .edit {
                    
                    let imageURL = URL(string: url)
                    if let imageURL = imageURL, imageURL.pathExtension.lowercased() == "pdf" {
                        NavigationLink(destination: ResourcePDFView(url: imageURL)) {
                            Image(systemName: "richtext.page.fill")
                        }
                    }

                    if let imageURL = imageURL, imageURL.pathExtension.lowercased() != "pdf" {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Muestra un indicador de carga mientras se descarga la imagen
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            case .failure:
                                Image(systemName: "photo") // Muestra un ícono por defecto si la imagen no se puede cargar
                            @unknown default:
                                EmptyView()
                            }
                        }
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

            

            
            .onChange(of: selectedFileURL) { value in
                DispatchQueue.main.async {
                    if let value {
                        resource.fileName = value.lastPathComponent
                        selectedImage = nil
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                alert
            }
            
            .navigationTitle(mode == .new ? "Add Resource" : "Edit Resource")
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
               
        if fileURL.pathExtension.lowercased() == "pdf" {
            resource.type = .pdf
        } else {
            resource.type = .image
        }
        
        isWaiting = true
        resourceManager.token = profile.token
        resource.leadId = leadId
        resourceManager.uploadResource(resource: resource, fileURL: fileURL, fileData: fileData, mode: mode) { result in

            switch result {
            case let .success(item):
                if mode == .new {
                    DispatchQueue.main.async {
                        resource.recordMode = .edit
                        resource.id = item.id
                        resource.leadId = item.leadId
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
                try? await resourceManager.list(leadId: leadId)
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

    private func addResource(resource: LeadResourceModel) {
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
