//
//  PaintCanvasView.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct SaveCanvas: View {
    @Binding var drawingLines: [PaintLine]

    @Environment(\.colorScheme) var deviceColorScheme: ColorScheme

    let paintEngine = PaintEngine()
    let screenSize: CGRect = UIScreen.main.bounds

    var body: some View {
        if deviceColorScheme == .dark {
            Color.black
                .frame(width: screenSize.width, height: screenSize.height / 1.25, alignment: .center)
                .overlay(
                    Canvas { context, size in
                        for line in drawingLines {
                            let path = paintEngine.createPath(for: line.points)
                            context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                        }
                    }
                )
                .edgesIgnoringSafeArea(.all)
        } else {
            Color.white
                .frame(width: screenSize.width, height: screenSize.height / 1.25, alignment: .center)
                .overlay(
                    Canvas { context, size in
                        for line in drawingLines {
                            let path = paintEngine.createPath(for: line.points)
                            context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                        }
                    }
                )
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct PaintCanvasView: View {
    @State private var lines = [PaintLine]()
    @State private var deletedLines = [PaintLine]()
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 1
    @State private var clearConfirmationState: Bool = false
    @State private var showingAlert = false

    let paintEngine = PaintEngine()

    var body: some View {
        NavigationView {
            VStack {
                Canvas { context, size in
                    for line in lines {
                        let path = paintEngine.createPath(for: line.points)
                        context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                    }
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let newPoint = value.location

                        if value.translation.width + value.translation.height == 0 {
                            lines.append(PaintLine(color: selectedColor, points: [newPoint], lineWidth: selectedLineWidth))
                        } else {
                            let index = lines.count - 1
                            lines[index].points.append(newPoint)
                        }
                    })
                    .onEnded({ value in
                        if let last = lines.last?.points, last.isEmpty {
                            lines.removeLast()
                        }
                    })
                )
                HStack {
                    ColorPicker("Выбор цвета", selection: $selectedColor)
                        .labelsHidden()
                    Slider(value: $selectedLineWidth, in: 1...20) {
                        Text("linewidth")
                    }
                        .frame(maxWidth: 100)
                    Text(String(format: "Размер: %.0f", selectedLineWidth))
                        .fontWeight(.medium)

                    Spacer()

                    Button {
                        let last = lines.removeLast()
                        deletedLines.append(last)
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .imageScale(.large)
                    }
                    .disabled(lines.count == 0)

                    Button {
                        let last = deletedLines.removeLast()
                        lines.append(last)
                    } label: {
                        Image(systemName: "arrow.uturn.forward.circle")
                            .imageScale(.large)
                    }
                    .disabled(deletedLines.count == 0)

                    Button {
                        clearConfirmationState = true
                    }
                    label: {
                        Image(systemName: "trash")
                            .imageScale(.large)
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $clearConfirmationState) {
                        Alert(
                            title: Text("Вы действительно хотите очистить поле?"),
                            message: Text("Это действие нельзя будет отменить"),
                            primaryButton: .destructive(Text("Очистить")) {
                                lines = [PaintLine]()
                                deletedLines = [PaintLine]()
                            },
                            secondaryButton: .cancel(Text("Отменить"))
                        )
                    }
                }
                .padding([.leading, .bottom, .trailing], 16.0)
            }
            .navigationTitle("Paint Minimal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    Button {
                        saveCanvas(SaveCanvas(drawingLines: $lines))
                        showingAlert = true
                    } label: {
                        Label("Сохранить", systemImage: "square.and.arrow.down")
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Рисунок успешно сохранен!"), message: Text("Вы можете найти его в вашей галерее"), dismissButton: .default(Text("Понятно")))
                    }
                    Button {
                        shareCanvas(SaveCanvas(drawingLines: $lines))
                    } label: {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
            }
        }
    }
}

func convertViewToUIImage(_ canvasView: SaveCanvas) -> UIImage {
    var uiImage = UIImage()
    let controller = UIHostingController(rootView: canvasView)

    if let view = controller.view {
        let contentSize = view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: contentSize)
        view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: contentSize)
        uiImage = renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    return uiImage
}

func saveCanvas(_ canvasView: SaveCanvas) {
    let image = convertViewToUIImage(canvasView)
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}

func shareCanvas(_ canvasView: SaveCanvas) {
    let image = convertViewToUIImage(canvasView)
    let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
    UIApplication
        .shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?
        .rootViewController?
        .present(av, animated: true, completion: nil)
}

struct PaintCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PaintCanvasView()
            .preferredColorScheme(.light)
        PaintCanvasView()
            .preferredColorScheme(.dark)
    }
}
