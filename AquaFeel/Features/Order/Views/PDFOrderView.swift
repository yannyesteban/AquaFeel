//
//  PDFOrderView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/6/24.
//

import SwiftUI
import PDFKit

struct PDFCreator {
    static func createPDF(view: UIView, fileName: String) -> URL? {
        let pdfPageFrame = view.bounds
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: pdfContext)
        
        UIGraphicsEndPDFContext()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfURL = documentsURL.appendingPathComponent("\(fileName).pdf")
        pdfData.write(to: pdfURL, atomically: true)
        
        return pdfURL
    }
}

struct PDFOrderView: View {
    var body: some View {
        VStack {
            Text("Contrato")
                .font(.largeTitle)
                .padding()
            Text("Este es un contrato entre el cliente y la empresa.")
                .padding()
            // Añade más contenido aquí según lo necesites
        }
    }
}

#Preview {
    PDFOrderView()
}
