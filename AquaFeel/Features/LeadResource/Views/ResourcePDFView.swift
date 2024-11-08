//
//  ResourcePDFView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 9/10/24.
//

import SwiftUI
import PDFKit


struct ResourcePDFView: View {
    //@State var resource: ResourceModel
    @State var url: URL?
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
        guard let pdfURL = url else { return }
        isLoading = true
        downloadPDF(from: pdfURL) { localURL in
            DispatchQueue.main.async {
                self.isLoading = false
                self.pdfURL = localURL
            }
        }
    }
}
