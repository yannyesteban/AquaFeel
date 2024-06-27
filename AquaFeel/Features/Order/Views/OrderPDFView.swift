//
//  OrderPDFView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 27/6/24.
//

import SwiftUI

struct OrderPDFView: View {
    
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
        guard let pdfURL = pdfURL else { return }
        isLoading = true
        downloadPDF(from: pdfURL) { localURL in
            DispatchQueue.main.async {
                self.isLoading = false
                self.pdfURL = localURL
            }
        }
    }
}
