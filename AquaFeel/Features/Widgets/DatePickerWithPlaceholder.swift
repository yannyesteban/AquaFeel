//
//  DatePickerWithPlaceholder.swift
//  AquaFeel
//
//  Created by Yanny Nuñez Jimenez on 10/28/25.
//

import SwiftUI

struct DatePickerWithPlaceholder: View {
    let label: String
    let placeholder: String
    @Binding var date: Date
    @Binding var isSet: Bool
    var displayedComponents: DatePickerComponents = .date
    
    @State private var showPicker = false
    @State private var showError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: {
                showPicker = true
            }) {
                HStack {
                    Text(label)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isSet {
                        Text(formattedDate)
                            .foregroundColor(.primary)
                    } else {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                    Image(systemName: "calendar")
                        .foregroundColor(showError ? .red : .gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showError && !isSet {
                Text("Please select a date")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showPicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        label,
                        selection: $date,
                        displayedComponents: displayedComponents
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle(label)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showPicker = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isSet = true
                            showError = false
                            showPicker = false
                        }
                    }
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Validación externa
    mutating func validate() -> Bool {
        showError = !isSet
        return isSet
    }
}

// MARK: - Versión más simple con overlay

struct SimpleDatePickerRequired: View {
    let label: String
    @Binding var date: Date
    @Binding var isSet: Bool
    var displayedComponents: DatePickerComponents = .date
    
    var body: some View {
        HStack {
            DatePicker(
                label,
                selection: Binding(
                    get: { date },
                    set: { newValue in
                        date = newValue
                        isSet = true
                    }
                ),
                displayedComponents: displayedComponents
            )
            .opacity(isSet ? 1.0 : 0.5)
            
            .foregroundColor(!isSet ? .gray : nil)
           
        }
    }
}
