//
//  Circle.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 30/1/24.
//

import SwiftUI
import UIKit

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
func getUIImage(name: String)->StatusUIView{
    
    
    
    return StatusUIView(status: getStatusType(from:name))
    
}

func getStatusType(from statusString: String) -> StatusType {
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

final class StatusUIView: CircleIconView, UIViewRepresentable{
    private let status : StatusType
    init(status: StatusType) {
        self.status = status
        
        var color : UIColor
        var image: String
        switch status {
        case .uc:
            color = ColorFromHex("#CC6F3F")
            //image = "truck.box.fill"
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
        //return CircleIconView(systemName: image, color:color)
        
        super.init(systemName: image, color: color)
        
    }
    required init?(coder aDecoder: NSCoder) {
        self.status = .appt
        super.init(coder: aDecoder)
        // Puedes realizar configuraciones adicionales si es necesario
    }
    struct ToSwiftUIView: UIViewRepresentable {
        var statusUIView: StatusUIView
        
        func makeUIView(context: Context) -> StatusUIView {
            return statusUIView
        }
        
        func updateUIView(_ uiView: StatusUIView, context: Context) {
            // Implementa actualizaciones si es necesario
        }
    }
    
    func toView() -> some View {
        return ToSwiftUIView(statusUIView: self)
    }
    
    
    func makeUIView(context: Context) -> UIView {
        return CircleIconView(systemName: "trash", color: .red)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Implementa actualizaciones si es necesario
    }
}

struct SuperIconView {
    private var status : StatusType
    
    init(status: StatusType) {
        self.status = status
    }
    
    
    func get()-> CircleIconView{
        var color : UIColor
        var image: String
        switch status {
        case .uc:
            color = ColorFromHex("#CC6F3F")
            //image = "truck.box.fill"
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
        
        return CircleIconView(systemName: image, color:color)
    }
    
    
    
    mutating func set(status newStatus: StatusType) {
        self.status = newStatus
        // Puedes realizar acciones adicionales al actualizar el estado, si es necesario
        // Por ejemplo, podrías actualizar la vista con el nuevo estado
        // self.updateView()
    }
}


class CircleIconView: UIView {
    var color: UIColor = .white
    var image: String = ""
    var ui : UIImage = UIImage()
    
    private let circleLayer: CALayer = {
        let layer = CALayer()
        //layer.cornerRadius = 4 // La mitad del tamaño del círculo deseado
        //layer.backgroundColor = self.color.cgColor
        //.borderWidth = 30.0
        //layer.borderColor = UIColor.blue.cgColor
        //layer.shadowColor = UIColor.gray.cgColor
        
        
        layer.shadowRadius = 3
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        return layer
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        return imageView
    }()
    
    init(systemName: String, color: UIColor) {
        super.init(frame: CGRect.zero)
        self.color = color
        self.image = systemName
        configureView(systemName: systemName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView(systemName: "dot.radiowaves.up.forward")
    }
    
    public func configureView(systemName: String) {
        layer.addSublayer(circleLayer)
        
        iconImageView.image = UIImage(systemName: systemName)
        
        ui = iconImageView.image ?? UIImage()
        
        //iconImageView.tintColor = color
        addSubview(iconImageView)
    }
    
    override func layoutSubviews() {
       
        /*super.layoutSubviews()
        
        circleLayer.cornerRadius = bounds.width / 2
        
        circleLayer.bounds = bounds
        circleLayer.position = center
        iconImageView.frame = bounds.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))*/
        
        super.layoutSubviews()
        
        circleLayer.backgroundColor = color.cgColor
        // Ajusta el tamaño del círculo al doble del tamaño de la imagen
        let circleSize = bounds.width
        circleLayer.bounds = CGRect(x: 0+5, y: 0+5, width: circleSize, height: circleSize)
        circleLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        circleLayer.cornerRadius = circleSize / 2
        
        iconImageView.frame = bounds.inset(by: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
    }
}

class YourViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let circleIconView = CircleIconView(systemName: "dot.radiowaves.up.forward", color:.blue)
        circleIconView.frame = CGRect(x: 120, y: 120, width: 16, height: 16)
        view.addSubview(circleIconView)
    }
}

struct CircleIconViewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> CircleIconView {
        return CircleIconView(systemName: "house", color: UIColor.yellow)
    }
    
    func updateUIView(_ uiView: CircleIconView, context: Context) {
        // Implementa actualizaciones si es necesario
    }
}
struct IconView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> IconView2 {
        return IconView2()
    }
    
    func updateUIView(_ uiView: IconView2, context: Context) {
        // Implementa actualizaciones si es necesario
    }
}



struct SuperIconViewViewWrapper: UIViewRepresentable {
    var status:StatusType
    init(status:StatusType){
        self.status = status
    }
    func makeUIView(context: Context) -> CircleIconView {
        
        return SuperIconView(status: status).get()
            
    }
    
    func updateUIView(_ uiView: CircleIconView, context: Context) {
        
        
        let info = getIconInfo(status: status)
        uiView.color = info.color
        uiView.image = info.image
        //uiView.layoutSubviews()
        uiView.configureView(systemName: info.image)
    }
}


struct SuperIcon2: UIViewRepresentable {
    @Binding var status:StatusType
    
    init(status: Binding<StatusType>) {
        self._status = status
    }
    
    func makeUIView(context: Context) -> CircleIconView {
       
        return SuperIconView(status: self.status).get()
        
    }
    
    func updateUIView(_ uiView: CircleIconView, context: Context) {
       
        let info = getIconInfo(status: status)
        uiView.color = info.color
        uiView.configureView(systemName: info.image)
        //uiView.layoutSubviews()
        //uiView.status = status
        // Implementa actualizaciones si es necesario
    }
}



var testStatus: [StatusType] = [.uc, .ni, .ingl, .rent, .r, .appt, .demo, .win, .nho, .sm, .mycl ]
struct ContentView10: View {
    var body: some View {
        
        VStack {
            ForEach(testStatus, id: \.self) { status in
                SuperIconViewViewWrapper(status: status).frame(width: 50, height: 50)
            }
            
        }
        
        
        
        CircleIconViewWrapper()
            .frame(width: 60, height: 60)
    }
}

struct ContentView_Previews10: PreviewProvider {
    static var previews: some View {
        //ContentView10()
        StatusUIView(status: .r2).toView().frame(width: 50, height: 50)
    }
}



#Preview {
    ContentView10()
}

struct MyIcon: View {
    var body: some View{
        StatusUIView(status: .nho).toView().frame(width: 50, height: 50)
        Image(systemName: "dot.radiowaves.up.forward").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            .font(.system(size: 30))
            .padding(8)
            .overlay(
                Circle()
                    .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
            )
    }
    
    
}
#Preview("iconView"){
    MyIcon()
}
