//
//  FilterOption.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 13/2/24.
//

import SwiftUI
/*

 [
 {
 "$addFields": {
 "location": [
 { "$toDouble": "$longitude" },
 { "$toDouble": "$latitude" }
 ]
 }
 },
 {
 "$match": {
 "$and": [
 {
 "location": {
 "$geoWithin": {
 "$center": [
 [-77.2679259, 38.5946187],
 1
 ]
 }
 }
 },
 {
 "zip": "22191"
 }
 ]
 }
 },

 ]

 */

struct DatePickerStringLite: View {
    var title: String
    @Binding var text: String

    private var realDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: text) {
            return date
        } else {
            // If the conversion fails, returns the current date as the default value
            return Date()
        }
    }

    var body: some View {
        DatePicker(
            title,
            selection: Binding<Date>(
                get: { self.realDate },
                set: { newValue in
                    // Convert the new selected date to a string format and assign to the ObservableLeadModel
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                    text = dateFormatter.string(from: newValue)
                }
            ),

            displayedComponents: [.date]
        )
    }
}

struct FilterOption: View {
    var profile: ProfileManager

    @Binding var filter: LeadFilter2
    @Binding var filters: LeadFilter

    // @State private var selectedSortOption = SortOption.dateCreated
    // @State private var selectedTimeOption = TimeOption.allTime
    // @State private var fromDate = Date()
    // @State private var toDate = Date()
    // @State private var selectedSymbols: [String] = []
    // @State private var selectedUsers: [String] = []
    // @State private var selectedDate: Date?
    @State private var searchText = ""
    @State private var isExpanded = false
    //@State var x: DateFind = DateFind.appointmentDate
    var statusList: [StatusId]
    var usersList: [User]

    @State private var dateString: String = "2024-03-04T21:41:31.803Z"
    @State private var fromDate: Date = Date()
    @State private var toDate: Date = Date()

    var onReset: () -> Void = { }

    func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC") // Asegura que el formato esté en UTC
        return formatter.string(from: date)
    }

    func parseStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC") // Asegura que el formato esté en UTC
        return formatter.date(from: dateString)
    }

    var filteredUsers2: [User] {
        if searchText.isEmpty {
            return usersList
        } else {
            return usersList.filter { user in
                user.firstName.localizedCaseInsensitiveContains(searchText) ||
                    user.lastName.localizedCaseInsensitiveContains(searchText)
                // Puedes agregar más criterios de búsqueda según tus necesidades
            }
        }
    }

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return usersList
        } else {
            let searchTerms = searchText
                .split(separator: ",")
                .map { String($0.trimmingCharacters(in: .whitespacesAndNewlines)) }

            return usersList.filter { user in
                searchTerms.contains(where: { term in
                    user.firstName.localizedCaseInsensitiveContains(term) ||
                        user.lastName.localizedCaseInsensitiveContains(term)
                })
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                /*
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
                 */
                Section(header: Text("Filter Date")) {
                    Picker("Quick Date", selection: $filters.dateFilters.selectedQuickDate) {
                        Text("All Time").tag(TimeOption.allTime.rawValue)
                        Text("Custom").tag(TimeOption.custom.rawValue)
                        Text("Today").tag(TimeOption.today.rawValue)
                        Text("Yesterday").tag(TimeOption.yesterday.rawValue)
                        Text("This Week").tag(TimeOption.currentWeek.rawValue)
                        Text("This Month").tag(TimeOption.currentMonth.rawValue)
                        Text("This Year").tag(TimeOption.currentYear.rawValue)
                    }

                    Picker("Find By", selection: $filters.dateFilters.selectedDateFilter) {
                        Text("Date Created").tag(DateFind.createOn.rawValue)
                        Text("Last Updated").tag(DateFind.updatedOn.rawValue)
                        Text("Appointment Date").tag(DateFind.appointmentDate.rawValue)
                    }
                    .disabled(filters.dateFilters.selectedQuickDate == TimeOption.allTime.rawValue)
                }

                if filters.dateFilters.selectedQuickDate == TimeOption.custom.rawValue {
                    Section(header: Text("Date Range")) {
                        DatePickerStringLite(title: "From Date", text: $filters.dateFilters.fromDate)
                        DatePickerStringLite(title: "From Date", text: $filters.dateFilters.toDate)
                    }
                    .disabled(filters.dateFilters.selectedQuickDate != TimeOption.custom.rawValue)
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
                            get: { filters.selectedStatuses.contains(where: { $0._id == icon._id }) },
                            set: { isSelected in
                                print("Toggle Value Changed: \(isSelected)")
                                if isSelected {
                                    let newStatus = LeadFilter.Status(isDisabled: false, _id: icon._id, name: icon.name)
                                    filters.selectedStatuses.append(newStatus)
                                } else {
                                    filters.selectedStatuses.removeAll { $0._id == icon._id }
                                }
                            }
                        )) {
                            HStack {
                                SuperIconViewViewWrapper(status: getStatusType(from: icon.name))
                                    .frame(width: 25, height: 25)
                                    .padding(5)
                                    .onTapGesture {
                                        // Realiza acciones al tocar la vista
                                    }
                                Text(icon.name)
                            }
                        }
                    }
                }

                if profile.role == "ADMIN" || profile.role == "MANAGER" {
                    DisclosureGroup(isExpanded: $isExpanded) {
                        TextField("Enter names, separated by commas", text: $searchText)
                            .padding(5)
                        ForEach(filteredUsers, id: \._id) { user in
                            Toggle(isOn: Binding(
                                get: { filters.selectedOwner.contains(user._id) },
                                set: { isSelected in
                                    if isSelected {
                                        filters.selectedOwner.append(user._id)
                                    } else {
                                        filters.selectedOwner.removeAll { $0 == user._id }
                                    }
                                }
                            )) {
                                Text("\(user.firstName) \(user.lastName)")
                            }
                        }
                    } label: {
                        Text("Select Users")
                        if filters.selectedOwner.count > 0 {
                            Text(" ")
                                .padding(.horizontal, 10)
                                // .padding(8)
                                .background(
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 24, height: 24)

                                        Text("\(filters.selectedOwner.count)")
                                            .foregroundColor(.white)
                                    }
                                )
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        onReset()

                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                        }
                    }
                }
            }
            .navigationTitle("Filter Options")
        }
    }
}

struct TestFilterOptionView: View {
    //@StateObject private var lead2 = LeadViewModel(first_name: "Juan", last_name: "")
    @StateObject private var statusManager = StatusManager()
    @StateObject var lead = LeadManager()
    // @StateObject var lead = LeadManager()
    @StateObject var user = UserManager()

    var body: some View {
        FilterOption(profile: ProfileManager(), filter: $lead.filter, filters: $lead.leadFilter, statusList: statusManager.statusList, usersList: user.users)
            .onAppear {
                statusManager.statusAll()
                user.list()
            }
    }
}

/*
 #Preview {
     TestFilterOptionView()
 }
 */
#Preview {
    LeadListHomeScreenPreview()
}
