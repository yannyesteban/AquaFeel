//
//  FilterOption.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/2/24.
//

import SwiftUI

struct FilterOption: View {
    @State private var selectedSortOption = SortOption.dateCreated
    @State private var selectedTimeOption = TimeOption.allTime
    @State private var fromDate = Date()
    @State private var toDate = Date()
    @State private var selectedSymbols: [String] = []
    @State private var selectedDate: Date?
    var statusList : [StatusId]
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Select Date")) {
                    DatePicker(
                        "Pick a Date",
                        selection: Binding(
                            get: { selectedDate ?? Date() },
                            set: { selectedDate = $0 }
                        ),
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                }
                
                Section(header: Text("Filter Date")) {
                    Picker("Filter Date By", selection: $selectedSortOption) {
                        Text("Date Created").tag(SortOption.dateCreated)
                        Text("Last Updated").tag(SortOption.lastUpdated)
                        Text("Appointment Date").tag(SortOption.appointmentDate)
                    }
                    //.pickerStyle(SegmentedPickerStyle())
                    Picker("Quick Date", selection: $selectedTimeOption) {
                        Text("All Time").tag(TimeOption.allTime)
                        Text("Custom").tag(TimeOption.custom)
                        Text("Today").tag(TimeOption.today)
                        Text("Yesterday").tag(TimeOption.yesterday)
                        Text("This Week").tag(TimeOption.thisWeek)
                    }
                    //.pickerStyle(SegmentedPickerStyle())
                }
                
                
                
                Section(header: Text("Date Range")) {
                    DatePicker("From Date", selection: $fromDate, displayedComponents: .date)
                    DatePicker("To Date", selection: $toDate, displayedComponents: .date)
                }
                /*
                Section(header: Text("Select Symbols")) {
                    ForEach(SFIcons.allCases, id: \.self) { icon in
                        Toggle(isOn: Binding(
                            get: { selectedSymbols.contains(icon.rawValue) },
                            set: { isSelected in
                                if isSelected {
                                    selectedSymbols.append(icon.rawValue)
                                } else {
                                    selectedSymbols.removeAll { $0 == icon.rawValue }
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: icon.rawValue)
                                Text(icon.rawValue)
                            }
                        }
                    }
                }
                */
                Section(header: Text("Select Status")) {
                    ForEach(statusList, id: \._id) { icon in
                        Toggle(isOn: Binding(
                            get: { selectedSymbols.contains(icon.name) },
                            set: { isSelected in
                                if isSelected {
                                    selectedSymbols.append(icon.name)
                                } else {
                                    selectedSymbols.removeAll { $0 == icon.name }
                                }
                            }
                        )) {
                            HStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: icon.name))
                                
                                
                                    .frame(width: 25, height: 25)
                                    .padding(5)
                                    .onTapGesture{
                                        //status = item
                                    }
                                Text(icon.name)
                            }
                        }
                    }
                }
                
                Text("Selected Symbols: \(selectedSymbols.joined(separator: ", "))")
                    .foregroundColor(.gray)
                    .italic()
                
                // Add more sections or form components as needed
                
            }
            .navigationTitle("Filter Options")
        }
    }
}

enum SFIcons: String, CaseIterable {
    case star = "star"
    case heart = "heart"
    case sun = "sun.max"
    case moon = "moon"
    // Add more symbols as needed
}

enum SortOption: String, CaseIterable {
    case dateCreated = "Date Created"
    case lastUpdated = "Last Updated"
    case appointmentDate = "Appointment Date"
}

enum TimeOption: String, CaseIterable {
    case allTime = "All Time"
    case custom = "Custom"
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
}


struct TestFilterOptionView:View {
    @StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    var body: some View {
        FilterOption(statusList: lead2.statusList)
            .onAppear{
                lead2.statusAll()
            }
    }
}

#Preview {
    TestFilterOptionView()
}
