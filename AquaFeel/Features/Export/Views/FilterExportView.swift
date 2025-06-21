//
//  FilterExportView.swift
//  AquaFeel
//
//  Created by Yanny Nuñez Jimenez on 4/2/25.
//

import SwiftUI

class FilterModel: ObservableObject {
    @Published var searchKey: String = "all"
    @Published var searchValue: String = ""
    @Published var statusIds: [String] = []
    @Published var ownerIds: [String] = []
    @Published var field: String = "created_on"
    @Published var quickDate: String = "today"
    @Published var fromDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var toDate: Date = Date()
    @Published var exportFormat: String = "excel"

    // URL generada para la exportación
    @Published var exportURL: URL?
}

struct FilterExportView: View {
    var profile: ProfileManager
    @StateObject private var filterModel = FilterModel()
    @StateObject var manager = LeadManager()
    @State var filter: LeadFilter2 = LeadFilter2()
    @State var filters: LeadFilter = LeadFilter()

    // @State private var selectedSortOption = SortOption.dateCreated
    // @State private var selectedTimeOption = TimeOption.allTime
    // @State private var fromDate = Date()
    // @State private var toDate = Date()
    // @State private var selectedSymbols: [String] = []
    // @State private var selectedUsers: [String] = []
    // @State private var selectedDate: Date?
    @State private var searchText = ""
    @State private var isExpanded = false
    // @State var x: DateFind = DateFind.appointmentDate
    @State var statusList: [StatusId]
    @State var usersList: [User]

    @State private var dateString: String = "2024-03-04T21:41:31.803Z"
    @State private var fromDate: Date = Date()
    @State private var toDate: Date = Date()
    @State private var isLoading = false

    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var downloadedFileURL: URL?

    @State private var showingShareSheet = false
    private var url: String {
        var components = URLComponents()
        components.scheme = APIValues.scheme
        components.host = APIValues.host
        components.port = APIValues.port
        components.path = "/leads/export/\(filterModel.exportFormat)"

        return components.url?.absoluteString ?? ""

        /*
         if APIValues.port == "" {
             return APIValues.scheme + "://" + APIValues.host + "/leads/export/\(filterModel.exportFormat)"
         }
         return APIValues.scheme + "://" + APIValues.host + ":\(APIValues.port)" + "/leads/export/\(filterModel.exportFormat)"
          */
    }

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()

    @State private var showQR = false

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

    func downloadFile() {
        guard let url = filterModel.exportURL else { return }

        isLoading = true

        // Configurar la sesión para manejo de descargas
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    alertMessage = "Error downloading: \(error.localizedDescription)"
                    showingAlert = true
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200 ... 299).contains(httpResponse.statusCode),
                      let data = data else {
                    alertMessage = "Error in server response"
                    showingAlert = true
                    return
                }

                // Guardar el archivo descargado
                let temporaryDirectoryURL = FileManager.default.temporaryDirectory
                let fileName = httpResponse.suggestedFilename ?? "leads_export.\(filterModel.exportFormat)"
                let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURL)
                    downloadedFileURL = fileURL

                    // Mostrar el documento picker para guardar el archivo permanentemente
                    let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(documentPicker, animated: true)
                    }
                    // Mostrar opciones para abrir el archivo
                    /* let documentInteractionController = UIDocumentInteractionController(url: fileURL)
                     if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let rootViewController = windowScene.windows.first?.rootViewController {
                         documentInteractionController.presentOpenInMenu(from: .zero, in: rootViewController.view, animated: true)
                     } */
                } catch {
                    alertMessage = "Error saving the file: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }

        task.resume()
    }

    func generateExportURL() {
        isLoading = true

        let urlString = url

        // Construir los parámetros de la URL basados en los filtros
        var urlComponents = URLComponents(string: urlString)!
        var queryItems = [URLQueryItem]()

        if !filterModel.searchValue.isEmpty {
            queryItems.append(URLQueryItem(name: "search_key", value: filterModel.searchKey))
            queryItems.append(URLQueryItem(name: "search_value", value: filterModel.searchValue))
        }

        if !filters.selectedStatuses.isEmpty {
            queryItems.append(URLQueryItem(name: "status_id", value: filters.selectedStatuses.map { $0._id }.joined(separator: ",")))
        }

        if !filters.selectedOwner.isEmpty {
            queryItems.append(URLQueryItem(name: "owner_id", value: filters.selectedOwner.joined(separator: ",")))
        }

        if filters.dateFilters.selectedQuickDate != TimeOption.allTime.rawValue {
            queryItems.append(URLQueryItem(name: "quickDate", value: filters.dateFilters.selectedQuickDate))
            queryItems.append(URLQueryItem(name: "field", value: filters.dateFilters.selectedDateFilter))

            if filters.dateFilters.selectedQuickDate == TimeOption.custom.rawValue {
                queryItems.append(URLQueryItem(name: "fromDate", value: filters.dateFilters.fromDate))
                queryItems.append(URLQueryItem(name: "toDate", value: filters.dateFilters.toDate))
            }
        }

        urlComponents.queryItems = queryItems
        filterModel.exportURL = urlComponents.url

        isLoading = false
        alertMessage = "Export URL generated successfully"
        showingAlert = true
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
                Section(header: Text("Export Options")) {
                    Picker("Format", selection: $filterModel.exportFormat) {
                        Text("Excel").tag("excel")
                        Text("CSV").tag("csv")
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Button(action: {
                        generateExportURL()
                    }) {
                        HStack {
                            Spacer()
                            Text("Generate Export")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(isLoading)

                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                if filterModel.exportURL != nil {
                    Section(header: Text("Actions")) {
                        Button(action: {
                            downloadFile()

                        }) {
                            HStack {
                                Text("Download File")
                                Spacer()
                                Image(systemName: "square.and.arrow.down.fill")
                            }
                        }

                        Button(action: {
                            showQR = true

                        }) {
                            HStack {
                                Text("Show QR Code")
                                Spacer()
                                Image(systemName: "qrcode")
                            }
                        }

                        Button(action: {
                            showingShareSheet = true

                        }) {
                            HStack {
                                Text("Share Link")
                                Spacer()
                                Image(systemName: "square.and.arrow.up.fill")
                            }
                        }
                    }
                }
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
                        DatePickerStringLite(title: "To Date", text: $filters.dateFilters.toDate)
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
                        // onReset()
                        filters = LeadFilter()

                    } label: {
                        HStack {
                            Image(systemName: "gobackward")
                        }
                    }
                }
            }
            .navigationTitle("Filter Options")
            .sheet(isPresented: $showQR) {
                if let _url = filterModel.exportURL {
                    QRCodeView(url: _url.absoluteString)
                        .padding()
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = filterModel.exportURL {
                    ShareSheet(items: [url])
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

        }.onAppear {
            manager.userId = profile.userId
            manager.token = profile.token
            manager.role = profile.role

            manager.initFilter(completion: { _, _ in

                statusList = manager.statusList

            })
            Task {
                try? await manager.getSellers()

                DispatchQueue.main.async {
                    usersList = manager.users
                }
                
                
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareSheet2: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        if let excludedActivityTypes = excludedActivityTypes {
            controller.excludedActivityTypes = excludedActivityTypes
        }

        // Manejar la finalización
        controller.completionWithItemsHandler = { _, _, _, error in
            if let error = error {
                print("Error al compartir: \(error.localizedDescription)")
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
