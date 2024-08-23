//
//  SignView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/7/24.
//

import SwiftUI

struct SignView: View {
    @Binding var sign: String
    @State private var imageSize: CGFloat = 100
    @State var showDrawingPad = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            if let image = base64ToImage(base64String: sign) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit() // Asegura que la imagen se ajuste al marco
                    .frame(width: imageSize) // Ajusta el marco de la imagen
                    .border(Color.black, width: 1) // Agrega un borde para ver los límites de la imagen

            } else {
                Text("No signature available")
            }

            Slider(value: $imageSize, in: 50 ... 300, step: 10) {
                Text("Image Size")
            }.padding()

        }.sheet(isPresented: $showDrawingPad) {
            RenderView(sign: $sign)
                
            
            //RenderView(sign: $sign)
            //ContentView1024(sign: $sign)
            // DrawingPad(sign: $sign)
        }

        Button {
            showDrawingPad.toggle()
        } label: {
            Text("sign")
        }
    }

    func base64ToImage(base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

#Preview {
    SignView(sign: .constant(""))
}
