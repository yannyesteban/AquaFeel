//
//  Reverse.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 26/6/24.
//

import Foundation
import SwiftUI
import UIKit

func createPDFWithContent() -> Data {
    let pdfMetaData = [
        kCGPDFContextCreator: "My App",
        kCGPDFContextAuthor: "me@example.com"
    ]
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = pdfMetaData as [String: Any]
    
    let pageWidth = 8.5 * 72.0
    let pageHeight = 11.0 * 72.0
    let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    
    let data = renderer.pdfData { (context) in
        context.beginPage()
        
        // Definir el contenido
        let content = """
        OTHER TERMS AND CONDITIONS
        STATE LAW REQUIRES THAT ANYONE WHO CONTRACTS TO DO CONSTRUCTION WORK TO BE LICENSED BY THE CONTRACTORS STATE LICENSE BOARD IN THE LICENSE CATEGORY IN WHICH THE CONTRACTOR IS GOING TO BE WORKING- IF THE TOTAL PRICE OF THE JOB IS $500 OR MORE (INCLUDING LABOR AND MATERIALS). LICENSED CONTRACTORS ARE REGULATED BY LAWS DESIGNED TO PROTECT THE PUBLIC. IF YOU CONTRACT WITH SOMEONE WHO DOES NOT HAVE A LICENSE, THE CONTRACTORS STATE LICENSE BOARD MAY BE UNABLE TO ASSIST YOU WITH A COMPLAINT. YOUR ONLY REMEDY AGAINST UNLICENSED CONTRACTOR MAY BE IN CIVIL COURT AND YOU MAY BE LIABLE FOR DAMAGES ARISING OUT OF ANY INJURIES TO THE CONTRACTOR OR HIS OR HER EMPLOYEES. YOU MAY CONTACT THE CONTRACTORS STATE LICENSE BOARD TO FIND OUT IF THIS CONTRACTOR HAS A VALID LICENSE. THE BOARD HAS COMPLETE INFORMATION ON THE HISTORY OF LICENSED CONTRACTORS, INCLUDING ANY POSSIBLE SUSPENSIONS, REVOCATIONS, JUDGMENTS, AND CITATIONS. SEARCH IN THE WHITE PAGES FOR CONTRACTORS STATE LICENSE BOARD OFFICE NEAREST TO YOU.
        
        1. The tittle to the equipment and materials covered in this Contract shall remain the legal property of Aquafeel Solutions, until the equipment and materials are paid in full. You acknowledge that you are giving a security interest in the goods purchased. The Buyer(s) hereby agrees that there is no written agreement or verbal understanding of any kind or nature, with Aquafeel Solutions, or any of its representatives, whereby this Contract, or any part of it is be altered, modified, or varied in any manner whatsoever from the conditions herein. The terms and conditions of this Contract are complete and exclusive statement of the agreements between the parties, constitute the entire agreement, and supersede and cancel all prior or contemporaneous negotiations, statements, and representations. There are no representations, inducements, promises, or agreements, oral or otherwise, with reference to this sale other than expressly set forth herein. If it is not in writing, and approved by employed management personnel at Aquafeel Solutions, it will not be honored.
        I have received a copy of this document:
        Buyer’s Signature: _________________________ Buyer’s Signature: ____________________________
        
        2. Aquafeel Solutions, agrees to start and diligently pursue work through to completion, but shall not be responsible for delays for any of the following reasons: Funding of loans, acts of neglect or omissions of the Buyer(s) or the Buyer(s) agent, acts of God, stormy or inclement weather, extra work ordered by the Buyer(s), acts of Public Enemy, riots or civil commotion, failure of Buyer(s) to make your payment(s) when due, or for acts of independent contractors, or Holidays, or other causes beyond Aquafeel Solutions' control. Buyer(s) shall grant free access to work areas for workers, equipment, and vehicles. Aquafeel Solutions' workers shall not be responsible for keeping gates closed for animals and children.
        
        3. This contract shall be construed in accordance with and governed by the laws of the State in which this Contract is signed. If any provision(s) of this contract shall be invalid for any reason, such invalidity shall be confined to the requirements of applicable law and shall not affect the remainder hereof, which shall continue in full force and effect or constitute a binding agreement between parties.
        
        4. In the even a dispute relating to this Contract resulted in litigation between the parties, concerning the work hereunder or any event related thereto, the party prevailing in such dispute shall be entitled to reasonable attorney's fees and cost.
        
        5. All work will be done according to the approved standards in the industry. This does not included correction of defects in existing plumbing or other inadequate building conditions.
        
        6. Financing terms are subject to approval and verification by the financing institution. You hereby authorize the seller to obtain a credit report for the purpose of financing this Contract. Additional financing terms and truth-in-lending information will be provided by the finance company. In the event Buyer(s) is denied credit financing Contracts, upon demand, from any other financing institutions, companies, corporations, or banks, including but not limited to Security Agreements, Lien Contracts, or Assignments of Rent Contracts, repayments period, amount financed, and the APR (interest rate) are subject to change due to varying terms and conditions from secondary financing sources.
        
        7. Additional terms and conditions may be stated on a separate Addendum to Contract. If an Addendum is executed by the Buyer, it shall be incorporated herein and become a part of this Proposal-Work Order-Contract.
        
        NOTICE OF CANCELLATION
        Date of Transaction: ___/___/___ Cancellation Date: ___/___/___ (No later than midnight of this date)
        You, the Buyer(s), may cancel this transaction, without penalty or obligation, at any time prior to midnight of the third business day after the date of this transaction noted above (i.e., within three business days from the above date). If you cancel, any property traded in, any payments made by you will under the contract sale, and any negotiable instrument executed by you will be returned within 10 days following receipt by the seller of you cancellation notice, and any security interest arising out of the transaction will be cancelled. If you cancel, you must make available to the seller at your residence, in substantially as good condition as when received. If you fail to make the goods available to the seller, or if you agree to return the goods to the seller and fail to do so, then you remain liable for performance of all obligations under the Contract. If you do make the goods available to the seller and they are not picked up within 20 days following the date of this Notice of Cancellation, you may retain or dispose of the goods without any further obligation. To cancel this transaction, mail (if mailed, the copy should be post marked by the third day after the date of the transaction) or deliver a signed and dated copy of this Cancellation Notice or any other written notice, or send a telegram to:
        
        Aquafeel Solutions
        230 Capcom Ave Ste. 103, Wake Forest NC 27587 PH (919) 790-5475 • FAX (919) 790-5476
        I hereby cancel this transaction:
        Date:___/___/___ Buyer’sSignature:________________________ Date:___/___/___ Buyer’sSignature:________________________
        """
        
        // Definir los atributos del texto
        let textFont = UIFont.systemFont(ofSize: 10.0)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: UIColor.black
        ]
        
        // Definir el rectángulo para el texto
        let textRect = CGRect(x: 20, y: 20, width: pageRect.width - 40, height: pageRect.height - 40)
        
        // Dibujar el texto en el PDF
        content.draw(in: textRect, withAttributes: textAttributes)
    }
    
    return data
}
