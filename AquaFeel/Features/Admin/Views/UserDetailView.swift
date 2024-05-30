//
//  UserDetailView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/4/24.
//

import SwiftUI

struct UserText: View {
    var title: String
    var value: String
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }
}

struct UserDetailView: View {
    var user: User

    @StateObject var placeManager = PlaceViewModel()
    
    private var avatarUrl: String {
        var components = URLComponents()
        components.scheme = APIValues.scheme
        components.host = APIValues.host
        components.path = "/uploads/" + (user.avatar ?? "")
        components.port = Int(APIValues.port)
        
        return components.url?.absoluteString ?? ""
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Form {
                Text(avatarUrl)
                if let avatar = user.avatar {
                    HStack(alignment: .center) {
                        Spacer()
                        //AvatarView(imageURL: URL(string: avatarUrl) ?? URL(string: "defaultAvatarURL")!, size: 200)
                        Spacer()
                    }
                }

                UserText(title: "Name:", value: "\(user.firstName) \(user.lastName)".capitalized)
                UserText(title: "Role:", value: user.role)

                if let createdAt = formatDate(user.createdAt) {
                    UserText(title: "Created at:", value: createdAt)
                }

                if let updatedAt = formatDate(user.updatedAt) {
                    UserText(title: "Updated at:", value: updatedAt)
                }

                Section("Address") {
                    if placeManager.selectedPlace != nil {
                        Text(placeManager.selectedPlace?.formatted_address ?? "...")
                    } else {
                        Button {
                            placeManager.getPlaceDetailsByCoordinates(latitude: user.latitude ?? 0.0, longitude: user.longitude ?? 0.0)
                        } label: {
                            Text("Show Address")
                        }
                    }
                }
            }
            .font(.footnote)
        }
        .onAppear {
            // placeManager.getPlaceDetailsByCoordinates(latitude: user.latitude ?? 0.0, longitude: user.longitude ?? 0.0)
        }
    }

    private func formatDate(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
