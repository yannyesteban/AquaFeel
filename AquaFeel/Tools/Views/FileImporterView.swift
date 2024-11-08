//
//  FileImporterView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 16/10/24.
//
import SwiftUI
import UIKit
import UniformTypeIdentifiers

import MobileCoreServices

struct FileImporterView: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Binding var fileData: Data?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item, .commaSeparatedText])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileImporterView

        init(_ parent: FileImporterView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            // Security scoped access
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                parent.fileURL = url
                if let data = try? Data(contentsOf: url) {
                    parent.fileData = data
                }
            } else {
                print("Could not access file: \(url)")
            }

            // parent.fileURL = urls.first
            // parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
