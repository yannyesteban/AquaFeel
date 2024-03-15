import Foundation

// Crear un DateFormatter
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" // Establecer el formato de fecha

print(1.12)

// Intentar convertir una cadena en una fecha utilizando el DateFormatter
if let date = dateFormatter.date(from: "2024-02-13T05:00:00.000Z") {
    // Si la conversión tiene éxito, imprimir la fecha
    print(2.12)
    print(date)
    
    // Convertir la fecha nuevamente a una cadena utilizando el mismo formato
    let dateString = dateFormatter.string(from: date)
}

print(3.12)
