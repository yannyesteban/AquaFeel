//
//  NotificationsView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 21/5/24.
//

import SwiftUI

struct NotificationsView: View {
    var profile: ProfileManager

    @StateObject var notificationManager = NotificationManager()
    // @State private var notifications: [Notification] = []
    @State private var showingForm = false
    @State private var editingNotification: NotificationModel = NotificationModel()

    @State var showAlert = false
    @State private var alert: Alert!
    @State var isWaiting = false

    var body: some View {
        NavigationStack {
            List {
                ForEach($notificationManager.notifications) { $notification in
                    NotificationRow(notification: $notification)
                        .onTapGesture {
                            editingNotification = notification
                            showingForm = true
                        }
                }
                .onDelete(perform: deleteNotification)
            }

            /*
             List($notificationManager.notifications) { $notification in
                 NotificationRow(notification: $notification)
                     .onTapGesture {
                         editingNotification = notification
                         showingForm = true
                     }
             }
              */
            // .padding(.vertical, 8)

            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingNotification = NotificationModel()
                        editingNotification.createdBy = profile.userId
                        showingForm = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                NotificationFormView(profile: profile, notification: $editingNotification, onSave: saveNotification)
            }

            .navigationTitle("Alarms")
            .task {
                try? await notificationManager.load(userId: profile.userId)
            }
        }
        .alert(isPresented: $showAlert) {
            alert
        }
    }

    func saveNotification(notification: NotificationModel, mode: RecordMode) {
        DispatchQueue.main.async {
            if let index = notificationManager.notifications.firstIndex(where: { $0.id == notification.id }) {
                if mode == .delete {
                    notificationManager.notifications.remove(at: index)
                    return
                }

                notificationManager.notifications[index] = notification
            } else {
                notificationManager.notifications.append(notification)
            }
        }
    }

    func deleteNotification(at offsets: IndexSet) {
        let notificationsToDelete = offsets.map { notificationManager.notifications[$0] }

        Task {
            for notification in notificationsToDelete {
                await notificationManager.save(body: notification, mode: .delete) { result in
                    switch result {
                    case let .success(notification):
                       
                        // notificationManager.notifications.remove(atOffsets: offsets)
                        DispatchQueue.main.async {
                            if let index = notificationManager.notifications.firstIndex(where: { $0.id == notification.id }) {
                                notificationManager.notifications.remove(at: index)
                            }
                        }

                    case let .failure(error):
                    
                        setAlert(title: "Error", message: "Failure, the operation was not completed.")
                        return
                    }
                }
            }

            // Eliminar notificaciones de la lista después de que se haya completado la operación
        }
    }

    private func setAlert(title: String, message: String) {
        alert = Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        showAlert = true
    }
}

#Preview {
    NotificationsView(profile: ProfileManager())
}
