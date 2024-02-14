//
//  MapMenuViewController.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 5/2/24.
//

import Foundation
import UIKit




struct MapMenuItem {
    var title: String
    var image: String
    var color: UIColor
    var action: (() -> Void)?
    
}

class XXX: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Crear un UIButton
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 50))
        button.setTitle("Hola", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = .white
        
        // Agregar el botón a la vista
        self.view.addSubview(button)
        
        // Añadir una acción al botón
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    // Función que se ejecuta cuando se presiona el botón
    @objc func buttonPressed() {
        print("Hola")
    }
}

class MyCustomView: UIView {
    // Creamos un botón
    let miBoton: UIButton = {
        let boton = UIButton(type: .system)
        boton.setTitle("Presionar", for: .normal)
        boton.addTarget(self, action: #selector(botonPresionado), for: .touchUpInside)
        return boton
    }()
    
    // Función llamada cuando se presiona el botón
    @objc func botonPresionado() {
        print("Hola")
    }
    
    // Configuración inicial de la vista
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurarVista()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurarVista()
    }
    
    // Configuración de la vista y disposición de los elementos
    func configurarVista() {
        // Configurar otros elementos o diseño de la vista aquí
        backgroundColor = UIColor.white
        
        // Agregar el botón a la vista y establecer su posición
        addSubview(miBoton)
        miBoton.translatesAutoresizingMaskIntoConstraints = true
        NSLayoutConstraint.activate([
            miBoton.centerXAnchor.constraint(equalTo: centerXAnchor),
            miBoton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

protocol MapMenuDelegate: AnyObject {
    func buttonTapped(title: String)
}

class MapMenuView: UIView {
    
    weak var delegate: MapMenuDelegate?
    
    private var size: CGFloat
    private let stackView = UIStackView()
    
    init(size: CGFloat, items: [MapMenuItem]) {
        self.size = size
        super.init(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        stackView.isUserInteractionEnabled = true
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = .red
        items.forEach { item in
            let button = UIButton(type: .system)
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            let trashImage = UIImage(systemName: item.image, withConfiguration: symbolConfiguration)
            button.setImage(trashImage, for: .normal)
            
            button.tintColor = item.color
            button.backgroundColor = .white
            button.layer.cornerRadius = 0.5 * size
            button.layer.borderWidth = 0.5
            button.layer.borderColor = item.color.cgColor
            button.isUserInteractionEnabled = true
            button.isUserInteractionEnabled = true
            stackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalToConstant: size).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            //addSubview(button)
            if let action = item.action {
                button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
            } else {
                button.addAction(UIAction(handler: { _ in
                    print("nothing")
                    self.delegate?.buttonTapped(title: item.title)
                }), for: .touchUpInside)
            }
        }
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Cancel", for: .normal)
        button2.addTarget(self, action: #selector(toggleGestures2), for: .touchUpInside)
        button2.backgroundColor = .green
        //button2.frame = CGRect(x: 200, y: view.frame.height + 60, width: 150, height: 40) // Adjust position as needed
        //view.addSubview(button2)
        
        button2.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button2.heightAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        stackView.addArrangedSubview(button2)
        
        addSubview(stackView)
        
        /*
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
         */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleGestures2() {
        print("y")
        //start = false
        //map.settings.setAllGesturesEnabled(true)
        //map.settings.scrollGestures = true
        //button.setTitle(true ? "Disable Gestures" : "Enable Gestures", for: .normal)
    }
}




class MapMenuViewController: UIViewController {
    
    private var size: CGFloat
    // Puedes agregar propiedades y métodos personalizados según tus necesidades
    private let stackView = UIStackView()
    
    var items : [MapMenuItem] = [
        MapMenuItem(title: "a", image: "line.horizontal.3.decrease.circle", color: .darkGray),
        MapMenuItem(title: "b", image: "magnifyingglass", color: .darkGray),
        MapMenuItem(title: "c", image: "app.connected.to.app.below.fill", color: .darkGray),
        MapMenuItem(title: "d", image: "pin.fill", color: .darkGray),
        MapMenuItem(title: "d", image: "hand.draw.fill", color: .darkGray)
    ]
    
    init(size: CGFloat, items: [MapMenuItem]) {
        self.size = size
        self.items = items
        super.init(nibName: nil, bundle: nil)
        
        // Configura tu UIViewController aquí con el tamaño proporcionado
        // ...
        
        // Ejemplo: establecer el tamaño de la vista
        //self.view.frame.size = CGSize(width: size, height: size)
        
        // Configura otras propiedades o métodos según sea necesario
    }
    
    // Requerido por el compilador
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // Configuración del stack view
        stackView.axis = .vertical
        stackView.alignment = .leading
        //stackView.distribution = .fill
        stackView.backgroundColor = .magenta
        stackView.spacing = 30  // Puedes ajustar el espaciado según tus necesidades
        //stackView.isLayoutMarginsRelativeArrangement = true
        //stackView.isLayoutMarginsRelativeArrangement = true
        //stackView.translatesAutoresizingMaskIntoConstraints = true
        //stackView.clipsToBounds = true
        items.forEach{ item in
            let button = UIButton(type: .system)
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            let trashImage = UIImage(systemName: item.image, withConfiguration: symbolConfiguration)
            button.setImage(trashImage, for: .normal)
            
            // Ajustar el color del símbolo
            button.tintColor = item.color
            
            // Ajustar la apariencia del botón para que tenga un fondo circular grande y un borde
            button.backgroundColor = .white
            button.layer.cornerRadius = 0.5 * size // Tamaño del círculo (ajustar según sea necesario)
            button.layer.borderWidth = 0.5  // Ancho del borde
            button.layer.borderColor = item.color.cgColor  // Color del borde
            
            // Configuración de acciones y restricciones
            //button.addTarget(self, action: #selector(toggleGestures), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            
            // Aplicar restricciones al botón
            button.widthAnchor.constraint(equalToConstant: size).isActive = true
            button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
            
            if let action = item.action {
                button.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
            }else{
                //button.addTarget(self, action: #selector(defaultTouche), for: .touchUpInside)
                button.addAction(UIAction(handler: { _ in
                        print("nothing")
                }), for: .touchUpInside)
            }
            
            stackView.addArrangedSubview(button)
         
        }
      
        view.addSubview(stackView)
        /*
        stackView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       
        
        // Configura las restricciones para el stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
       */
        
        
        
        
        
    }
    
    @objc func defaultTouche() {
        
        print("toggleGestures x")
       
    }
}
