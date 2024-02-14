//
//  Test3.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/1/24.
//

import SwiftUI

struct Test3: View {
    var body: some View {
        VStack {
                    Text("Encabezado u otros contenidos")

                    Form {
                        // Contenido de la Form
                        Text("Campo 1")
                        Text("Campo 2")
                        // Otros elementos de la Form
                    }
                    //.containerRelativeFrame([.horizontal, .vertical])
                    //.frame(minHeight: 20, maxHeight: .signalingNaN)
                    //.frame(width: 300, height: 200)  // Ajusta el ancho y alto según tus necesidades

                    Text("Pie de página u otros contenidos")
                }
                .padding()
    }
}

#Preview {
    Test3()
}
