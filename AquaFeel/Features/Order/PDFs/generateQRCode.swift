//
//  GenerateQR.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/6/24.
//

import Foundation
import UIKit

func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 10, y: 10)

        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
    }
    return nil
}
