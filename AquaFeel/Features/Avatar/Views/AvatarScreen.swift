//
//  AvatarScreen.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 28/5/24.
//

import SwiftUI
import UIKit

struct AvatarScreen: View {
    var profile: ProfileManager

    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text("Select an image")
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            HStack {
                Button("Choose from Library") {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
                .padding()

                Button("Take Photo") {
                    sourceType = .camera
                    showingImagePicker = true
                }
                .padding()
            }

            if let image = selectedImage {
                Button("Upload Image") {
                    uploadImage(image: image)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            AvatarPicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
    }

    func uploadImage(image: UIImage) {
        guard let url = URL(string: "http://10.0.0.30:4000/profile/upload-avatar") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(profile.token)", forHTTPHeaderField: "Authorization")

        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.8)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: data) { responseData, _, error in
            if let error = error {
                print("Error uploading image: \(error)")
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
}

/*
 #Preview {
     AvatarScreen(profile: .constant(Profile()))
 }
 */
