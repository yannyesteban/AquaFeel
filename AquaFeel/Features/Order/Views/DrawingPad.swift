//
//  DrawingPad.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 2/7/24.
//

import SwiftUI
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize

        view?.bounds = CGRect(origin: .zero, size: controller.view.intrinsicContentSize)

        view?.backgroundColor = .clear

        // let renderer = UIGraphicsImageRenderer(size: view?.bounds.size ?? CGSize.zero)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        }
    }
}

struct RenderView: View {
    @Binding var sign: String
    var text: String = "yanny"
    @State var lines: [Line] = []
    @State var currentLine: Line = Line(points: [])

    var canvasSize = CGSize(width: 540, height: 270)

    //@State var scale = 0.65 * 1.8

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        GeometryReader { geometry in
            
            let scale = geometry.size.width * 0.90 / 540
            
            
            VStack {
                /* CanvasView(lines: $lines, currentLine: $currentLine, canvasSize: canvasSize)
                 .border(Color.red)
                 */
               
                HStack {
                    if orientation.isLandscape {
                        CanvasView(lines: $lines, currentLine: $currentLine, useGrid: true, canvasSize: CGSize(width: canvasSize.width, height: canvasSize.height))
                            .border(Color.blue)
                       
                    } else {
                        CanvasView(lines: $lines, currentLine: $currentLine, useGrid: true, canvasSize: CGSize(width: // canvasSize.width, height: canvasSize.height))
                            canvasSize.width, height: canvasSize.height))
                            .border(Color.red)
                            .scaleEffect(scale)
                            .frame(width: canvasSize.width * scale, height: canvasSize.height * scale)
                    }
                }
                
                .background(Color.white)

                .shadow(radius: 10)
                Text("Please sign your name inside the rectangle")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            .overlay(alignment: .topLeading) {
                VStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.secondary)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding(10)
                    Button {
                        resetDrawing()

                    } label: {
                        Image(systemName: "gobackward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }

                    .padding(10)
                    Button {
                        saveImage()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "externaldrive.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }

                    .padding(10)
                }
                
            }

            .onAppear {
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    self.orientation = UIDevice.current.orientation
                }
            }
        }
    }

    private func resetDrawing() {
        lines = []
        currentLine = Line(points: [])
    }

    @MainActor
    func saveImage() {
        let canvasSize = CGSize(width: 600, height: 300)
        let renderer = ImageRenderer(content: CanvasView(lines: $lines, currentLine: $currentLine, canvasSize: canvasSize))
        if let uiImage = renderer.uiImage {
            if let pngData = uiImage.pngData() {
                sign = pngData.base64EncodedString()
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct CanvasView: View {
    @Binding var lines: [Line]
    @Binding var currentLine: Line
    var useGrid = false
    var canvasSize: CGSize

    var body: some View {
        Canvas { context, size in
            if useGrid {
                drawGrid(context: context, size: size)
            }

            for line in lines {
                var path = Path()
                if let firstPoint = line.points.first {
                    path.move(to: firstPoint)
                    for point in line.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(path, with: .color(.black), lineWidth: 3)
            }

            var currentPath = Path()
            if let firstPoint = currentLine.points.first {
                currentPath.move(to: firstPoint)
                for point in currentLine.points.dropFirst() {
                    currentPath.addLine(to: point)
                }
            }
            context.stroke(currentPath, with: .color(.blue), lineWidth: 3)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentLine.points.append(value.location)
                }
                .onEnded { _ in
                    lines.append(currentLine)
                    currentLine = Line(points: [])
                }
        )
        .background(useGrid ? Color.yellow.opacity(0.1) : Color.white)
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    func drawGrid(context: GraphicsContext, size: CGSize) {
        let step: CGFloat = 20.0

        for x in stride(from: 0, through: size.width, by: step) {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(.gray.opacity(0.7)), lineWidth: 0.5)
        }

        for y in stride(from: 0, through: size.height, by: step) {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(.gray.opacity(0.7)), lineWidth: 0.5)
        }
    }
}

struct ContentView1024: View {
    @Binding var sign: String
    @State private var text = "Your text here"
    @State private var renderedImage = Image(systemName: "photo")
    @Environment(\.displayScale) var displayScale

    // @State var v = RenderView()

    var body: some View {
        VStack {
            // renderedImage
            RenderView(sign: $sign)
            // ShareLink("Export", item: renderedImage, preview: SharePreview(Text("Shared image"), image: renderedImage))
        }
        // .onChange(of: v.currentLine) { _ in render() }
        .onTapGesture {
            // render()
        }
        // .onAppear { render() }
    }
    /*
     @MainActor func render() {
     let renderer = ImageRenderer(content: v)

     // make sure and use the correct display scale for this device
     renderer.scale = displayScale

     if let uiImage = renderer.uiImage {
     renderedImage = Image(uiImage: uiImage)
     }
     }
     */
}

struct RenderView1: View {
    var text: String = "yanny"
    @State var lines: [Line] = []
    @State var currentLine: Line = Line(points: [])

    let canvasSize = CGSize(width: 300, height: 400)
    var body: some View {
        Canvas { context, _ in
            for line in lines {
                var path = Path()
                if let firstPoint = line.points.first {
                    path.move(to: firstPoint)
                    for point in line.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }

            var currentPath = Path()
            if let firstPoint = currentLine.points.first {
                currentPath.move(to: firstPoint)
                for point in currentLine.points.dropFirst() {
                    currentPath.addLine(to: point)
                }
            }
            context.stroke(currentPath, with: .color(.blue), lineWidth: 2)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentLine.points.append(value.location)
                }
                .onEnded { _ in
                    lines.append(currentLine)
                    currentLine = Line(points: [])
                }
        )
        .background(Color.white)
        // .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(width: canvasSize.width, height: canvasSize.height) // Ajusta el tamaño del canvas

        .border(Color.red)
    }
}

struct DrawingPad: View {
    @Binding var sign: String

    @State private var lines: [Line] = []
    @State private var currentLine: Line = Line(points: [])
    let canvasSize = CGSize(width: 300, height: 400)

    @Environment(\.displayScale) var displayScale
    @State private var renderedImage = Image(systemName: "photo")

    var body: some View {
        renderedImage
        ZStack {
            // Canvas for drawing
            Canvas { context, _ in
                for line in lines {
                    var path = Path()
                    if let firstPoint = line.points.first {
                        path.move(to: firstPoint)
                        for point in line.points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    context.stroke(path, with: .color(.black), lineWidth: 2)
                }

                var currentPath = Path()
                if let firstPoint = currentLine.points.first {
                    currentPath.move(to: firstPoint)
                    for point in currentLine.points.dropFirst() {
                        currentPath.addLine(to: point)
                    }
                }
                context.stroke(currentPath, with: .color(.blue), lineWidth: 2)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentLine.points.append(value.location)
                    }
                    .onEnded { _ in
                        lines.append(currentLine)
                        currentLine = Line(points: [])
                    }
            )
            .background(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // .frame(width: canvasSize.width, height: canvasSize.height)  // Ajusta el tamaño del canvas

            .border(Color.red)

            // Buttons on top of the canvas
            VStack {
                HStack {
                    Button(action: resetDrawing) {
                        Text("Reset")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    Spacer()
                    Button(action: saveDrawing2) {
                        Text("Save")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func resetDrawing() {
        lines = []
        currentLine = Line(points: [])
    }

    func saveDrawing() {
        let image = snapshot(size: canvasSize)
        if let fileURL = saveImageToFile(image: image) {
            uploadImage(url: fileURL, apiEndpoint: "https://your-api-endpoint.com/upload")
        }
    }

    private func saveDrawing2() {
        let image = snapshot()
        if let imageData = image.pngData() {
            let base64String = imageData.base64EncodedString()
            sign = base64String
            // uploadSignature(base64String: base64String)
        }
    }
}

struct Line {
    var points: [CGPoint]
}

struct DrawingPad_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPad(sign: .constant(""))
    }
}

extension View {
    func snapshot4() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        // Obtener el tamaño de la pantalla del dispositivo
        let screenSize = UIScreen.main.bounds.size

        // Ajustar el tamaño de la vista al tamaño de la pantalla
        view?.bounds = CGRect(origin: .zero, size: screenSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: screenSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    func snapshot(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    func snapshot2() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.bounds.size // .intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

func saveImageToFile(image: UIImage) -> URL? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = UUID().uuidString + ".png"
    let fileURL = documentsDirectory.appendingPathComponent(fileName)

    if let data = image.pngData() {
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
        }
    }

    return nil
}

func uploadImage(url: URL, apiEndpoint: String) {
    let boundary = UUID().uuidString
    var request = URLRequest(url: URL(string: apiEndpoint)!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var body = Data()

    // Add image data
    if let imageData = try? Data(contentsOf: url) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(url.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
    }

    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    let task = URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
            print("Error uploading image: \(error)")
            return
        }

        if let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                print("Image uploaded successfully")
            } else {
                print("Server error: \(response.statusCode)")
            }
        }
    }

    task.resume()
}

struct DrawingPad_Previews2: PreviewProvider {
    static var previews: some View {
        DrawingPad(sign: .constant(""))
    }
}
