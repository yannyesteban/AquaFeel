//
//  LeadStatus.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/1/24.
//

import SwiftUI

struct LeadStatus: View {
    var body: some View {
        
        VStack{
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(Color.blue)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .frame(width: 50, height: 50)
            
            ZStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 50, height: 50)
                    .shadow(color: .gray, radius: 3, x: 0, y: 2) // Ajusta los valores según sea necesario
                
                Image(systemName: "dot.radiowaves.up.forward")
                
                    .foregroundColor(Color.white)
                    .shadow(color: .gray, radius: 1, x: 0, y: 1) // Ajusta los valores según sea necesario
            }
            .frame(width: 50, height: 50)
            
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(Color.blue)
            }
            .frame(width: 50, height: 50)
            
            
            Image(systemName: "trash")
                .renderingMode(.template)
                .foregroundColor(.white)
                .background(.black)
                .font(.system(size: 30))
                .padding(10)
                .overlay(
                    Circle()
                        .stroke(lineWidth: 4) // Configura el color y el ancho del trazo
                )
            
            
            Image(systemName: "star").foregroundColor(.blue)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            
            Image(systemName: "dot.radiowaves.up.forward").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "truck.box").foregroundColor(.white)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                    //.foregroundColor(.brown)
                    //.stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "trophy").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "house").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "checkmark").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "hand.thumbsdown").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "arrow.counterclockwise").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "house").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
            Image(systemName: "arrow.counterclockwise").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .font(.system(size: 30))
                .padding(8)
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 4) // Configura el color y el ancho del trazo
                )
        }
    }
}


struct StatusListView: View {
    var statusList: [StatusId] = []
    @Binding var selected: String
    @State var status: StatusType = .appt
    @State var selected2: String = ""
    var body: some View {
        HStack {
            VStack{
                if selected != selected2 {
                    SuperIcon2(status: $status)
                        .frame(width: 50, height: 50)
                    
                    Text(selected)
                        .frame(width: 50, height: 30)
                }
               
                
                
                // SuperIconViewViewWrapper(status: getStatusType(from: "NHO"))
                
                
                
                
                
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(statusList, id: \._id) { item in
                        // Utiliza Label para combinar una imagen y un texto
                        VStack{
                            
                            SuperIconViewViewWrapper(status: getStatusType(from: item.name))
                            
                            
                                .frame(width: 30, height: 30)
                                .padding(5)
                                .onTapGesture {
                                    
                                    selected = item.name
                                    status = getStatusType(from: selected)
                                }
                            Text(item.name )
                                .frame(width: 50, height: 30)
                                .foregroundColor(.blue)
                        }
                        
                        
                        
                    }
                }
            }
            .padding(5)
            //.background(.gray.opacity(0.2))
        }.padding(0)
            .onChange(of: status) { newStatus in
                status = newStatus
                //selected2 = getStatusType(from: newStatus)
                // Actualizar la vista cuando cambia el estado
                // Aquí puedes realizar las actualizaciones necesarias en tu vista
                print("Status changed to \(newStatus)")
                print(selected, selected2)
            }
    }
}

struct TestLeadStatusView: View {
    @StateObject private var lead = LeadViewModel(first_name: "Juan", last_name: "")
    @State var selected = ""
    var body: some View {
        StatusListView(statusList: lead.statusList, selected: $selected)
            .onAppear(){
                lead.statusAll()
            }
    }
}

struct LeadStatus2: View {
    var status: StatusType
    var color: UIColor {
        switch status {
        case .uc:
            return ColorFromHex("#CC6F3F")
        case .ni:
            return .black
        case .ingl:
            return ColorFromHex("#CC96C6")
        case .rent:
            return ColorFromHex("#34499A")
        case .r:
            return ColorFromHex("#A3C100")
        case .appt:
            return ColorFromHex("#2BBBEB")
        case .demo:
            return ColorFromHex("#7E7F7F")
        case .win:
            return ColorFromHex("#0056A3")
        case .nho:
            return ColorFromHex("#FFE000")
        case .sm:
            return ColorFromHex("#6769AF")
        case .mycl:
            return ColorFromHex("#00ACD3")
        }
    }
    
    var image: String {
        switch status {
        case .uc:
            return "truck.box.fill"
        case .ni:
            return "trash.fill"
        case .ingl:
            return "star.fill"
        case .rent:
            return "ladybug.fill"
        case .r:
            return "arrow.counterclockwise"
        case .appt:
            return "calendar"
        case .demo:
            return "hand.thumbsdown.fill"
        case .win:
            return "trophy.fill"
        case .nho:
            return "house.fill"
        case .sm:
            return "dot.radiowaves.up.forward"
        case .mycl:
            return "checkmark"
        }
    }
    
    
    
    
    var body: some View {
        
        
        
        
        SuperIconViewViewWrapper(status: getStatusType(from: ""))
    }
}
#Preview {
    //LeadStatus()
    TestLeadStatusView()
}

