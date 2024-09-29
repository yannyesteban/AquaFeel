//
//  UsersListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/4/24.
//

import CoreLocation
import SwiftUI

struct UserRowView: View {
    let user: User

    @State var withDetail: Bool = false
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.headline)
                HStack {
                    Text("Role:")
                        .font(.subheadline)
                    Text("\(user.role)")
                        .font(.subheadline)
                        .foregroundStyle(user.role == "SELLER" ? .secondary : user.role == "MANAGER" ? Color.orange : .accentColor)
                }
                if withDetail {
                    HStack {
                        if let lastPosition = user.mLastConnected, lastPosition >= 0 && lastPosition <= 2 {
                            Image(systemName: "wifi")
                                .foregroundColor(.green)

                            // Text("Connected").foregroundColor(.green)
                        } else {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.gray)
                            // Text("Disconnected").foregroundColor(.red)
                        }
                        //Text("Connected \(user.mLastConnected ?? -4)").foregroundColor(.green)
                        Spacer()

                        if let lastPosition = user.mLastPosition, lastPosition >= 0 && lastPosition <= 1440 {
                            Text("Pos: \(lastPosition) minutes ago")

                        } else {
                            Text("Pos: -")
                        }
                    }
                }
            }
            Spacer()
            if user.isVerified {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.blue)

            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            }
            if user.isBlocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.red)
            } else {
                Image(systemName: "lock.open.fill")
                    .foregroundColor(.green)
            }
        }
    }
}

struct UsersListView: View {
    let users: [User]
    @Binding var selected: User?
    @State private var searchText = ""

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        // NavigationView {
        List {
            ForEach(filteredUsers, id: \.self._id) { user in
                NavigationLink(destination: UserDetailView(user: user)) {
                    UserRowView(user: user, withDetail: true)
                        .foregroundColor(isValidCoordinate(position: user.position) ? .primary : .secondary)
                }
                .onTapGesture {
                    if isValidCoordinate(position: user.position) {
                        DispatchQueue.main.async {
                            self.selected = user
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)

        .navigationTitle("Users")
        // .navigationBarItems(trailing: Image(systemName: "person.3.fill"))
        // }
    }

    private func isValidCoordinate(position: CLLocationCoordinate2D) -> Bool {
        return (-90 ... 90).contains(position.latitude) && (-180 ... 180).contains(position.longitude)
    }
}

#Preview("Main") {
    MainAppScreenPreview()
}
