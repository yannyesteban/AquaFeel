//
//  DraggableView.swift
//  AquaFeel
//
//  Created by Yanny Esteban on 24/3/24.
//

import SwiftUI

struct DraggableView<Content>: View where Content: View {
    @GestureState private var dragOffset = CGSize.zero
    @State private var currentPosition: CGSize = .zero
    
    let content: () -> Content
    
    var body: some View {
        content()
            .offset(x: currentPosition.width + dragOffset.width, y: currentPosition.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset, body: { (value, dragOffset, _) in
                        dragOffset = value.translation
                    })
                    .onEnded({ (value) in
                        currentPosition.width += value.translation.width
                        currentPosition.height += value.translation.height
                    })
            )
    }
}

struct ContentView1000: View {
    @State private var isShowingDraggableView = false
    
    var body: some View {
        VStack {
            Button("Mostrar Vista Draggable") {
                isShowingDraggableView.toggle()
            }
            .padding()
            
            if isShowingDraggableView {
                DraggableView {
                    VStack {
                        Text("¡Arrastra esta vista libremente!")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Spacer()
                    }
                    .frame(width: 200, height: 200)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}


struct ResizableSheetView<Content>: View where Content: View {
    @State private var offset: CGFloat = .zero
    @State private var startPosition: CGFloat = .zero
    @State private var currentHeight: CGFloat = UIScreen.main.bounds.height / 2
    @State private var isVisible = false
    
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                self.content()
                    .frame(height: self.currentHeight)
                    .background(Color.white)
                    .cornerRadius(10)
                    .offset(y: max(self.offset, 0))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let y = value.translation.height + self.startPosition
                                let minY = geometry.size.height - self.currentHeight
                                self.offset = max(minY, y)
                            }
                            .onEnded { value in
                                let screenHeight = geometry.size.height
                                let threshold = screenHeight * 0.25
                                if value.translation.height > threshold {
                                    self.isVisible = false
                                } else if value.translation.height < -threshold {
                                    self.isVisible = true
                                }
                                self.currentHeight = self.isVisible ? screenHeight / 2 : 0
                                self.startPosition = self.offset
                            }
                    )
            }
            .frame(height: geometry.size.height)
            .background(Color.black.opacity(0.3))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView1001: View {
    @State private var isResizableSheetVisible = false
    
    var body: some View {
        VStack {
            Button("Mostrar Vista Redimensionable") {
                self.isResizableSheetVisible.toggle()
            }
            .padding()
            
            if isResizableSheetVisible {
                ResizableSheetView {
                    VStack {
                        Text("¡Arrastra esta vista para cambiar su altura!")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct SheetView: View {
    @Binding var isSheetShown: Bool
    
    var body: some View {
        VStack {
            Text("Contenido de la hoja")
                .padding()
            
            Button("Cerrar") {
                self.isSheetShown = false
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .padding()
        .shadow(radius: 10)
    }
}

struct ContentView1002: View {
    @State private var isSheetShown = false
    
    var body: some View {
        ZStack {
            // Contenido principal de tu vista
            Color.green.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button("Mostrar hoja") {
                    self.isSheetShown.toggle()
                }
                .padding()
            }
            
            if isSheetShown {
                // Hoja que no es modal
                SheetView(isSheetShown: $isSheetShown)
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}


//https://sarunw.com/posts/swiftui-bottom-sheet/
struct ContentView1003: View {
    @State var presentSheet = false
    // 1
    @State var selectedDetent: PresentationDetent = .medium
    
    private let availableDetents: [PresentationDetent] = [.medium, .large]
    
    var body: some View {
        NavigationView {
            Button("Modal") {
                presentSheet = true
            }
            .navigationTitle("Main")
        }.sheet(isPresented: $presentSheet) {
            // 3
            Picker("Selected Detent", selection: $selectedDetent) {
                
                ForEach(availableDetents, id: \.self) {
                    Text($0.description.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            // 2
            .presentationDetents([.medium, .large], selection: $selectedDetent)
            
            .presentationDragIndicator(.hidden)
        }
    }
}

// For presenting in a picker
extension PresentationDetent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        default:
            return "n/a"
        }
    }
}

struct FullScreenView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            Color.orange
            VStack {
                Button("Dismiss Me") { isPresented = false }
            }
        }
        .ignoresSafeArea()
    }
}



struct ContentView1004: View {
    
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var showingDaiolg = false
    @State private var showModal = false
    @State private var selectedColor: String = ""
    
    var body: some View {
        HStack {
            Button("Bottom Sheet") {
                showSheet.toggle()
            }
            Button("Choose color") { showingDaiolg.toggle() }
            Button("Modal") { showModal.toggle() }
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        
        .alert(isPresented: $showAlert) {
            // show the alert here
            Alert(title: Text("Title: Slected Color \(selectedColor)"), message: Text("This is Alert message"))
        }
        .sheet(isPresented: $showSheet) {
            // show the sheet/snackbar here
            Text("Some sheet container from Bottom")
                .presentationDetents([.fraction(0.2)])
        }
        .fullScreenCover(isPresented: $showModal, content: {
            // full screen model
            FullScreenView(isPresented: $showModal)
        })
        .confirmationDialog("choose a color",
                            isPresented: $showingDaiolg,
                            titleVisibility: .visible) {
            // this is actionSheet
            Button("Red") {
                showAlert.toggle()
                self.selectedColor = "Red"
            }
            Button("Green") {
                showAlert.toggle()
                self.selectedColor = "Green"
            }
            Button("Blue") {
                showAlert.toggle()
                self.selectedColor = "Blue"
            }
            
        }
        
    }
}


struct CitiesList: View {
    
    var buttonAction: () -> Void
    var handleAction: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                // List Handle
                HStack(alignment: .center) {
                    Rectangle()
                        .frame(width: 25, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10)
                        .opacity(0.25)
                        .padding(.vertical, 8)
                }
                .frame(width: geometry.size.width, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .onTapGesture {
                    handleAction()
                }
                
                // List of Cities
                Text("Hello World")
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ContentView1005: View {
   
    @State var zoomInCenter: Bool = false
    @State var expandList: Bool = false
    
    @State var yDragTranslation: CGFloat = 0
    
    var body: some View {
        
        let scrollViewHeight: CGFloat = 80
        
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                
                Button {
                    self.zoomInCenter = true
                } label: {
                   Text("Aqui")
                }
                
               
                CitiesList() {
                    
                    
                    self.zoomInCenter = false
                    self.expandList = false
                }  handleAction: {
                    self.expandList.toggle()
                }.background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .offset(
                        x: 0,
                        y: geometry.size.height - (expandList ? scrollViewHeight + 150 : scrollViewHeight)
                    )
                    .offset(x: 0, y: self.yDragTranslation)
                    .animation(.spring(), value: self.yDragTranslation)
                    .gesture(
                        DragGesture().onChanged { value in
                            self.yDragTranslation = value.translation.height
                        }.onEnded { value in
                            self.expandList = (value.translation.height < -120)
                            self.yDragTranslation = 0
                        }
                    )
                    .shadow(radius: 10)
                
            }
        }
    }
}

struct ContentView1006: View {
    @State var presentSheet = false
    // 1
    @State var selectedDetent: PresentationDetent = .medium
    
    private let availableDetents: [PresentationDetent] = [.medium, .large]
    
    var body: some View {
        NavigationView {
            Button("Modal") {
                presentSheet = true
            }
            .navigationTitle("Main")
        }.sheet(isPresented: $presentSheet) {
            // 3
            Picker("Selected Detent", selection: $selectedDetent) {
                
                ForEach(availableDetents, id: \.self) {
                    Text($0.description.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            // 2
            .presentationDetents([.medium, .large], selection: $selectedDetent)
            
            .presentationDragIndicator(.hidden)
        }
    }
}

#Preview ("IMPORTANTE !!"){
    ContentView1005()
}

#Preview ("1006"){
    ContentView1006()
}


#Preview {
    ContentView1000()
}

#Preview {
    ContentView1001()
}

#Preview {
    ContentView1002()
}

#Preview ("1003"){
    ContentView1003()
}


#Preview ("1004"){
    ContentView1004()
}

