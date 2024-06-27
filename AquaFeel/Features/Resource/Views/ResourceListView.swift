//
//  ResourceListView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 29/5/24.
//

import Foundation
import PDFKit
import SwiftUI

func downloadPDF(from url: URL, completion: @escaping (URL?) -> Void) {
    let configuration = URLSessionConfiguration.default
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    let session = URLSession(configuration: configuration)
    
    let task = session.downloadTask(with: url) { localURL, _, error in
        guard let localURL = localURL, error == nil else {
            print("Error downloading PDF: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        completion(localURL)
    }
    task.resume()
}

func downloadPDF2(from url: URL, completion: @escaping (URL?) -> Void) {
    let task = URLSession.shared.downloadTask(with: url) { localURL, _, error in
        guard let localURL = localURL, error == nil else {
            print("Error downloading PDF: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }
        completion(localURL)
    }
    task.resume()
}
struct PDFViewer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        pdfView.autoScales = true
        //pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.pageBreakMargins.top = 0.0
        pdfView.pageBreakMargins.bottom = 0.0
        pdfView.pageShadowsEnabled = true
        pdfView.usePageViewController(true, withViewOptions: nil)
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct PDFViewer2: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

struct ResourceDetailView2: View {
    @State var resource: ResourceModel
    @State private var pdfURL: URL?

    var body: some View {
        VStack {
            if let pdfURL = pdfURL {
                PDFViewer(url: pdfURL)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Loading PDF...")
                    .onAppear {
                        loadPDF()
                    }
            }
        }
        .navigationTitle("Resource Details")
    }

    private func loadPDF() {
        guard let pdfURL = URL(string: resource.fileURL) else { return }
        print("pdfURL             ...", pdfURL)
        downloadPDF(from: pdfURL) { localURL in
            if let localURL = localURL {
                DispatchQueue.main.async {
                    self.pdfURL = localURL
                }
            }
        }
    }
}

struct ResourceListView: View {
    var profile: ProfileManager
    @StateObject var resourceManager = ResourceManager()
    @State private var resources: [ResourceModel] = []

    @State var resource = ResourceModel()

    var body: some View {
        NavigationStack {
            List(resourceManager.resources.filter { $0.active }) { resource in
                NavigationLink(destination: ResourceDetailView(resource: resource)) {
                    ResourceRow(resource: resource)
                }
            }
            .navigationTitle("Resources")

            .task {
                try? await resourceManager.list()
            }
        }
    }
}

// Formateador de fecha para mostrar las fechas correctamente
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

struct ResourceDetailView: View {
    @State var resource: ResourceModel
    @State private var pdfURL: URL?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if let pdfURL = pdfURL {
                PDFViewer(url: pdfURL)
                    .edgesIgnoringSafeArea(.all)
            } else if isLoading {
                ProgressView("Loading PDF...")
            } else {
                Text("Failed to load PDF.")
            }
        }
        .navigationTitle("Resource Details")
        .onAppear {
            loadPDF()
        }
    }
    
    private func loadPDF() {
        guard let pdfURL = URL(string: resource.fileURL) else { return }
        isLoading = true
        downloadPDF(from: pdfURL) { localURL in
            DispatchQueue.main.async {
                self.isLoading = false
                self.pdfURL = localURL
            }
        }
    }
}

struct ResourceRow: View {
    let resource: ResourceModel

    var body: some View {
        HStack {
            Image(systemName: resource.type.iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .padding(.trailing, 8)
            VStack(alignment: .leading) {
                Text(resource.description)
                    .font(.headline)
                Text("Type: \(resource.type.description.uppercased())")
                    .font(.subheadline)
            }
            Spacer()
            if resource.active {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}
