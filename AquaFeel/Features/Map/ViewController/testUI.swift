//
//  testUI.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 19/2/24.
//

import Foundation


import SwiftUI

struct MySwiftUIView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        // Aquí creas e inicializas tu propio UIViewController
        let viewController = UIViewController()
        
        // Añadir un gesto a la vista del UIViewController
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap))
        viewController.view.addGestureRecognizer(tapGesture)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Puedes actualizar la vista si es necesario
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject {
        @objc func handleTap() {
            // Manejar el gesto aquí
            print("Tap detected")
        }
    }
}


struct GeoPreview22: PreviewProvider {
    static var previews: some View {
        MySwiftUIView()
    }
}
