//
//  Order.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/6/24.
//

import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI

func workOrderPDF(order: OrderModel, url: String) -> Data {
    let pdfMetaData = [
        kCGPDFContextCreator: "aquafeel",
        kCGPDFContextAuthor: "Aquafeel",
        kCGPDFContextTitle: "Order Details",
    ]
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]

    let pageWidth = 8.5 * 72.0
    let pageHeight = 11 * 72.0
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

    let data = renderer.pdfData { context in
        context.beginPage()
        let textFont = UIFont.systemFont(ofSize: 12)
        let titleFont = UIFont.boldSystemFont(ofSize: 18)

        var currentY: CGFloat = 20

        func drawText(_ text: String, at point: CGPoint, font: UIFont = textFont) {
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: NSMutableParagraphStyle(),
            ]
            let attributedText = NSAttributedString(string: text, attributes: textAttributes)
            attributedText.draw(at: point)
        }

        func drawSectionTitle(_ title: String) {
            drawText(title, at: CGPoint(x: 20, y: currentY), font: titleFont)
            currentY += 24
        }

        func drawSectionContent(_ content: [(String, String)]) {
            for (label, value) in content {
                drawText(label, at: CGPoint(x: 20, y: currentY))
                drawText(value, at: CGPoint(x: 150, y: currentY))
                currentY += 18
            }
            currentY += 12
        }

        // QR Code
        if let qrCodeImage = generateQRCode(from: url) {
            qrCodeImage.draw(in: CGRect(x: 20, y: currentY, width: 100, height: 100))
            currentY += 120
        }

        drawSectionTitle("Buyer1 Information")
        drawSectionContent([
            ("Buyer 1 Name:", order.buyer1.name),
            ("Buyer 1 Phone:", order.buyer1.phone),
            ("Buyer 1 Cell:", order.buyer1.cel),
        ])

        drawSectionTitle("Buyer2 Information")
        drawSectionContent([
            ("Buyer 2 Name:", order.buyer2.name),
            ("Buyer 2 Phone:", order.buyer2.phone),
            ("Buyer 2 Cell:", order.buyer2.cel),
        ])

        drawSectionTitle("Address Information")
        drawSectionContent([
            ("Address:", order.address),
            ("City:", order.city),
            ("State:", order.state),
            ("ZIP:", order.zip),
        ])

        drawSectionTitle("System Information 1")
        drawSectionContent([
            ("System 1 Name:", order.system1.name),
            ("System 1 Brand:", order.system1.brand),
            ("System 1 Model:", order.system1.model),
        ])

        drawSectionTitle("System Information 2")
        drawSectionContent([
            ("System 2 Name:", order.system2.name),
            ("System 2 Brand:", order.system2.brand),
            ("System 2 Model:", order.system2.model),
            ("Promotion:", order.promotion),
        ])

        drawSectionTitle("Installation Information")
        drawSectionContent([
            ("Water source:", order.installation.waterSouce),
            ("Installation Day:", order.installation.day),
            ("Ice Maker:", order.installation.iceMaker ? "Yes" : "No"),
            ("Time (hours):", "\(order.installation.time)"),
        ])

        // Format and display installation date
        drawText("Installation Date:", at: CGPoint(x: 20, y: currentY))
        let dateString = formatDateToString2(order.installation.date)
        drawText(dateString, at: CGPoint(x: 150, y: currentY))
        currentY += 18
        currentY += 12

        drawSectionTitle("People Involved")
        drawSectionContent([
            ("People:", "\(order.people)"),
            ("The floor is:", order.floorType),
        ])

        drawSectionTitle("Terms or Payment Methods")
        drawSectionContent([
            ("Credit Card:", order.creditCard ? "Yes" : "No"),
            ("Check:", order.check ? "Yes" : "No"),
        ])

        drawSectionTitle("Price Information")
        drawSectionContent([
            ("Cash Price:", "\(order.price.cashPrice)"),
            ("Installation:", "\(order.price.installation)"),
            ("Taxes:", "\(order.price.taxes)"),
            ("Total Cash:", "\(order.price.totalCash)"),
            ("Down Payment:", "\(order.price.downPayment)"),
            ("Amount to Finance:", "\(order.price.toFinance)"),
            ("Terms Amount:", "\(order.price.terms.amount)"),
            ("APR:", "\(order.price.APR)"),
            ("Finance Charge:", "\(order.price.finaceCharge)"),
        ])

        drawSectionTitle("Approval / Purchaser 1")
        drawSectionContent([
            ("Approval / Purchaser:", order.approval1.purchaser),
        ])
        drawText("Date:", at: CGPoint(x: 20, y: currentY))
        let approval1DateString = formatDateToString2(order.approval1.date)
        drawText(approval1DateString, at: CGPoint(x: 150, y: currentY))
        currentY += 18
        currentY += 12

        drawSectionTitle("Approval / Purchaser 2")
        drawSectionContent([
            ("Approval / Purchaser:", order.approval2.purchaser),
        ])
        drawText("Date:", at: CGPoint(x: 20, y: currentY))
        let approval2DateString = formatDateToString2(order.approval2.date)
        drawText(approval2DateString, at: CGPoint(x: 150, y: currentY))
        currentY += 18
        currentY += 12

        drawSectionTitle("Approved for")
        drawSectionContent([
            ("Rep. of Aquafeel:", order.employee),
            ("App central off:", order.approvedBy),
        ])
    }

    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("UserInfo.pdf")

    return data
}
