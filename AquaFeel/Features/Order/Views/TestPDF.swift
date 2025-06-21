//
//  TestPDF.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 25/6/24.
//

import SwiftUI
import UIKit


class PDFPreviewCoordinator: NSObject, UIDocumentInteractionControllerDelegate {
    var documentInteractionController: UIDocumentInteractionController?
    
    func presentPreview(url: URL, from viewController: UIViewController) {
        documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController?.delegate = self
        documentInteractionController?.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
}

struct PDFPreview: UIViewControllerRepresentable {
    let url: URL
    
    func makeCoordinator() -> PDFPreviewCoordinator {
        return PDFPreviewCoordinator()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            context.coordinator.presentPreview(url: url, from: viewController)
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct TestPDF: View {
    @State private var name: String = "aaaaa"
    @State private var email: String = "aaaa"
    @State private var showPDFPreview = false
    @State private var pdfURL: URL?
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                
                Text(pdfURL?.absoluteString ?? "....")
            }
            Button(action: {
                generatePDF(name: name, email: email)
            }) {
                Text("Generate PDF")
            }
            
            Button(action: {
                generatePDF(name: name, email: email) { url in
                    DispatchQueue.main.async {
                      
                        self.pdfURL = url
                        self.showPDFPreview = true
                    }
                    
                }
            }) {
                Text("Generate PDF")
            }
            
            Button(action: {
                self.showPDFPreview = true
            }) {
                Text("Show PDF")
            }
        }
        .sheet(isPresented: $showPDFPreview) {
           
            
            if let url = pdfURL {
               // PDFPreview(url: url)
                PDFViewer(url: url)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text( pdfURL?.absoluteURL.absoluteString ?? "nada...")
            }
        }
    }
    func generatePDF(name: String, email: String, completion: @escaping (URL) -> Void) {
        let pdfMetaData = [
            kCGPDFContextCreator: "Your App Name",
            kCGPDFContextAuthor: "Your Name"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18)
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            let title = "User Information"
            title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
            
            let nameText = "Name: \(name)"
            nameText.draw(at: CGPoint(x: 20, y: 50), withAttributes: bodyAttributes)
            
            let emailText = "Email: \(email)"
            emailText.draw(at: CGPoint(x: 20, y: 70), withAttributes: bodyAttributes)
            
            if let image = UIImage(named: "aqua") {
                let imageRect = CGRect(x: 20, y: 100, width: 100, height: 100)
                image.draw(in: imageRect)
            }
        }
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("UserInfo.pdf")
        
        do {
            try data.write(to: url)
            print("PDF generado correctamente en: \(url)")
            completion(url)
        } catch {
            print("No se pudo generar el PDF: \(error)")
        }
    }
    
    func generatePDF(name: String, email: String) {
        let pdfMetaData = [
            kCGPDFContextCreator: "Your App Name",
            kCGPDFContextAuthor: "Your Name"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18)
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            let title = "User Information"
            title.draw(at: CGPoint(x: 20, y: 20), withAttributes: titleAttributes)
            
            let nameText = "Name: \(name)"
            nameText.draw(at: CGPoint(x: 20, y: 50), withAttributes: bodyAttributes)
            
            let emailText = "Email: \(email)"
            emailText.draw(at: CGPoint(x: 20, y: 70), withAttributes: bodyAttributes)
            
            if let image = UIImage(named: "aqua") {
                let imageRect = CGRect(x: 20, y: 100, width: 100, height: 100)
                image.draw(in: imageRect)
            }
        }
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("UserInfo.pdf")
        
        do {
            try data.write(to: url)
            print("PDF generado correctamente en: \(url)")
        } catch {
            print("No se pudo generar el PDF: \(error)")
        }
    }
}

struct ContentViewTestPDF_Previews: PreviewProvider {
    static var previews: some View {
        TestPDF()
    }
}

#Preview {
    TestPDF()
}
