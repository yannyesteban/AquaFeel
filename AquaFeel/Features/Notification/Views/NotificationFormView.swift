//
//  NotificationFormView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/5/24.
//

import SwiftUI

struct NotificationFormView: View {
    var profile: ProfileManager
    @ObservedObject var notificationManager = NotificationManager()
    @Binding var notification: NotificationModel
    @State var mode: RecordMode = .new
    var onSave: (NotificationModel, RecordMode) -> Void

    @State var showAlert = false
    @State private var alert: Alert!
    @State var isWaiting = false

    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alarm Details")) {
                    TextField("Name", text: $notification.name)

                    Picker("Type", selection: $notification.type) {
                        ForEach(NotificationType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }

                    switch notification.type {
                    case .interval, .appointment:
                    
                        HStack {
                            TextField("Interval", value: $notification.interval, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            Picker("", selection: $notification.unit) {
                                ForEach(TimeUnit.allCases) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }
                        }

                    case .datetime:
                        DatePicker(
                            "Date",
                            selection: $notification.datetime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    case .time:
                        DatePicker(
                            "Time",
                            selection: $notification.datetime,
                            displayedComponents: [.hourAndMinute]
                        )
                    }

                    TextField("Message", text: $notification.message)

                    Toggle(isOn: $notification.repeats) {
                        Text("Repeats")
                    }

                    Toggle(isOn: $notification.isActive) { // Campo Toggle
                        Text("Activate Notification")
                    }
                }

                Section {
                    if isWaiting {
                        ProgressView("")

                    } else {
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
            .navigationTitle(notification.recordMode == .new ? "New Alarm" : "Edit Alarm")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isWaiting {
                        ProgressView("")

                    } else {
                        Button {
                            doSave()

                        } label: {
                            Label("Save", systemImage: "externaldrive.fill")
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                alert
            }
        }
    }

    private func delete() async {
    }

    private func setAlert(title: String, message: String) {
        alert = Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        showAlert = true
    }

    private func doSave() {
        let alertMessage = notification.validForm()

        if alertMessage != "" {
            setAlert(title: "Message", message: alertMessage)
            return
        } else {
            isWaiting = true
        }

        // presentationMode.wrappedValue.dismiss()
        Task {
            await notificationManager.save(body: notification, mode: notification.recordMode) { result in
                switch result {
                case let .success(notification):
                    
                    if mode == .new {
                        self.notification = notification
                        self.notification.recordMode = .edit
                    }
                    setAlert(title: "Message", message: "record was saved correctly!")
                    onSave(notification, notification.recordMode)

                    Task {
                        await NotificationManager.initialize(userId: profile.userId)
                    }

                case let .failure(error):
                    print(error)
                    setAlert(title: "Error", message: "Failure, the operation was not completed.")
                }

                isWaiting = false
            }
        }
    }

    private func doDelete() {
        alert = Alert(
            title: Text("Confirmation"),
            message: Text("Are you sure you want to delete the notification?"),
            primaryButton: .destructive(Text("Delete")) {
                Task {
                    await notificationManager.save(body: notification, mode: .delete) { result in
                        switch result {
                        case let .success(notification):
                            
                            onSave(notification, .delete)
                            
                            Task {
                                await NotificationManager.initialize(userId: profile.userId)
                            }
                            
                            presentationMode.wrappedValue.dismiss()
                        case let .failure(error):
                            print("Error al guardar la notificación: \(error.localizedDescription)")
                            setAlert(title: "Error", message: "Failure, the operation was not completed.")
                        }
                    }
                }
            },
            secondaryButton: .cancel()
        )

        showAlert = true
    }
}
