//
//  generatePDF.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/6/24.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

func generatePDF(data: Data, name: String, completion: @escaping (URL) -> Void) {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)

    do {
        try data.write(to: url)
        print("PDF: \(url)")
        completion(url)
    } catch {
        print("PDF: \(error)")
    }
}
