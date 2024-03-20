import Foundation

import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var selectedMonthIndex = 0
    @State private var selectedYearIndex = 0
    
    private var months = DateFormatter().shortStandaloneMonthSymbols ?? []
    private var years: [String] = {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return (currentYear-10...currentYear+10).map { String($0) }
    }()
    
    var body: some View {
        VStack {
            // Picker para seleccionar el mes
            Picker(selection: $selectedMonthIndex, label: Text("")) {
                ForEach(0..<months.count) { index in
                    Text(self.months[index]).tag(index)
                }
            }
            .labelsHidden()
            .onChange(of: selectedMonthIndex) { _ in
                updateSelectedDate()
            }
            
            // Picker para seleccionar el año
            Picker(selection: $selectedYearIndex, label: Text("")) {
                ForEach(0..<years.count) { index in
                    Text(self.years[index]).tag(index)
                }
            }
            .labelsHidden()
            .onChange(of: selectedYearIndex) { _ in
                updateSelectedDate()
            }
            
            // DatePicker
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .onChange(of: selectedDate) { _ in
                    updateMonthAndYear()
                }
        }
        .padding()
    }
    
    private func updateSelectedDate() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.month = selectedMonthIndex + 1
        selectedDate = calendar.date(from: components) ?? Date()
    }
    
    private func updateMonthAndYear() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        selectedMonthIndex = components.month! - 1
        selectedYearIndex = years.firstIndex(of: String(components.year!)) ?? 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func fechaInicioDeMes(mes: Int) -> Date? {
    // Obtenemos el calendario actual
    var calendar = Calendar.current
    
    // Establecemos el primer día del mes para el año actual
    let currentDate = Date()
    
    // Configuramos el mes deseado
    var components = DateComponents()
    components.month = mes
    components.day = 1
    
    // Creamos la fecha correspondiente al primer día del mes deseado
    guard let inicioMes = calendar.date(from: components) else {
        return nil
    }
    
    return inicioMes
}

// Uso de la función para obtener la fecha de inicio de un mes específico
if let fechaInicio = fechaInicioDeMes(mes: 3) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: fechaInicio)
    print("La fecha de inicio del mes es: \(dateString)")
} else {
    print("No se pudo obtener la fecha de inicio del mes.")
}



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
