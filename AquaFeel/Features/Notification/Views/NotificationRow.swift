//
//  NotificationRow.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 22/5/24.
//

import SwiftUI

struct NotificationRow: View {
    @Binding var notification: NotificationModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(notification.name)
                .font(.headline)
            Text(notification.message)
                .font(.subheadline)
            HStack {
                Text("Interval: \(notification.interval)")
                Text("Unit: \(notification.unit.id)")
            }
            .font(.caption)
            Text("Type: \(notification.type.id)")
                .font(.caption)
            Text(notification.isActive ? "Notification is active" : "Notification is inactive")
                .font(.caption)
                .foregroundColor(notification.isActive ? .green : .red)
        }
        //.padding(.vertical, 8)
    }
}

#Preview {
    NotificationRow(notification: .constant(NotificationModel()))
}
