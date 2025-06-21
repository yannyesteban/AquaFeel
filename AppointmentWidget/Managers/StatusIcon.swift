//
//  StatusIcon.swift
//  AquafeelExtension
//
//  Created by Yanny Esteban on 11/6/24.
//

import Foundation
import SwiftUI
import UIKit


struct IconInfo {
    let color: Color
    let imageName: String
}

func getIconInfo3(status: StatusType) -> IconInfo {
    var color: Color
    var imageName: String
    
    switch status {
    case .uc:
        color = ColorFromHex("#CC6F3F")
        imageName = "truck.box.fill"
    case .ni:
        color = .black
        imageName = "trash.fill"
    case .ingl:
        color = ColorFromHex("#CC96C6")
        imageName = "star.fill"
    case .rent:
        color = ColorFromHex("#34499A")
        imageName = "ladybug.fill"
    case .r:
        color = ColorFromHex("#A3C100")
        imageName = "arrow.counterclockwise"
    case .appt:
        color = ColorFromHex("#2BBBEB")
        imageName = "calendar"
    case .demo:
        color = ColorFromHex("#7E7F7F")
        imageName = "hand.thumbsdown.fill"
    case .win:
        color = ColorFromHex("#0056A3")
        imageName = "trophy.fill"
    case .nho:
        color = ColorFromHex("#FFE000")
        imageName = "house.fill"
    case .sm:
        color = ColorFromHex("#6769AF")
        imageName = "dot.radiowaves.up.forward"
    case .mycl:
        color = ColorFromHex("#00ACD3")
        imageName = "checkmark"
    case .nm:
        color = ColorFromHex("#00ff00")
        imageName = "house.fill"
    case .r2:
        color = ColorFromHex("#00ffff")
        imageName = "arrow.counterclockwise"
    case .none:
        color = ColorFromHex("#FFA500")
        imageName = "star.fill"
    }
    
    return IconInfo(color: color, imageName: imageName)
}

func ColorFromHex3(_ hex: String) -> Color {
    
    let scanner = Scanner(string: hex)
    scanner.currentIndex = scanner.string.startIndex
    var rgbValue: UInt64 = 0
    scanner.scanHexInt64(&rgbValue)
    let red = (rgbValue & 0xff0000) >> 16
    let green = (rgbValue & 0xff00) >> 8
    let blue = rgbValue & 0xff
    print(Color(red: Double(red) / 0xff, green: Double(green) / 0xff, blue: Double(blue) / 0xff))
    return Color(red: Double(red) / 0xff, green: Double(green) / 0xff, blue: Double(blue) / 0xff)
}


/*
 struct IconInfo {
 var color : UIColor
 var image: String
 }
 
 func getIconInfo(status: StatusType) -> IconInfo {
 var color : UIColor
 var image: String
 switch status {
 case .uc:
 color = ColorFromHex("#CC6F3F")
 if #available(iOS 17.0, *) {
 // Usa un símbolo específico de iOS 15 o posterior
 image = "truck.box.fill"
 } else {
 // Usa un símbolo diferente para versiones anteriores
 image = "hammer.fill"
 }
 
 case .ni:
 color = .black
 image = "trash.fill"
 case .ingl:
 color = ColorFromHex("#CC96C6")
 image = "star.fill"
 case .rent:
 color = ColorFromHex("#34499A")
 image = "ladybug.fill"
 case .r:
 color = ColorFromHex("#A3C100")
 image = "arrow.counterclockwise"
 case .appt:
 color = ColorFromHex("#2BBBEB")
 image = "calendar"
 case .demo:
 color = ColorFromHex("#7E7F7F")
 image = "hand.thumbsdown.fill"
 case .win:
 color = ColorFromHex("#0056A3")
 image = "trophy.fill"
 case .nho:
 color = ColorFromHex("#FFE000")
 image = "house.fill"
 case .sm:
 color = ColorFromHex("#6769AF")
 image = "dot.radiowaves.up.forward"
 case .mycl:
 color = ColorFromHex("#00ACD3")
 image = "checkmark"
 case .nm:
 color = ColorFromHex("#00ff00")
 image = "house.fill"
 case .r2:
 color = ColorFromHex("#00ffff")
 image = "arrow.counterclockwise"
 case .none:
 color = ColorFromHex("#FFA500")
 image = "star.fill"
 
 }
 
 return IconInfo(color: color, image: image)
 }
 */
class IconView2: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        // Configura la imagen de tu icono
        imageView.image = UIImage(named: "logo")
        // Configura el color de fondo de la vista (opcional)
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        // Agrega el UIImageView como subvista de la IconView
        addSubview(iconImageView)
        // Configura las restricciones del UIImageView para que ocupe todo el espacio disponible
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


func getStatusType3(from statusString: String) -> StatusType {
    let lowercaseStatus = statusString.lowercased()
    
    switch lowercaseStatus {
    case "uc":
        return .uc
    case "ni":
        return .ni
    case "ingl":
        return .ingl
    case "rent":
        return .rent
    case "r":
        return .r
    case "appt":
        return .appt
    case "demo":
        return .demo
    case "win":
        return .win
    case "nho":
        return .nho
    case "sm":
        return .sm
    case "mycl":
        return .mycl
    case "nm":
        return .nm
    case "r2":
        return .r2
    default:
        return .none
    }
}

func ColorFromHex(_ hex: String) -> Color{
    
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
        return Color.init(red: 0.0, green: 0.0, blue: 0.0)
    }
    
    let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(rgb & 0x0000FF) / 255.0
    
    
    
    return Color.init(red: red, green: green, blue: blue)
}

func ColorFromHex(_ hex: String) -> UIColor{
    
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
        return UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(rgb & 0x0000FF) / 255.0
    
    
    
    return UIColor.init(red: red, green: green, blue: blue, alpha: 1.0)
}
enum StatusType: String {
    case uc // truck brown #CC6F3F
    case ni // trash black
    case ingl // start pink #CC96C6
    case rent // bug purple #34499A
    case r // arrow anti clocl green #A3C100
    case appt // calendar blue aqua #2BBBEB
    case demo // pulgar down gary #7E7F7F
    case win // cup blue #0056A3
    case nho // home yellow #FFE000
    case sm // wifi purple #6769AF
    case mycl // checklist blue.. #00ACD3
    
    case nm // home  #00ff00
    case r2 // arrow anti clocl green #00ffff
    case none // star anti clocl green #00ffff
}
