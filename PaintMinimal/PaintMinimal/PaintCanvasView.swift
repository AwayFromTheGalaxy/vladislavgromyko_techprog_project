//
//  PaintCanvasView.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct DrawingCanvas: View {
    @Binding var drawingLines: [PaintLine]
    
    let paintEngine = PaintEngine()
    
    var body: some View {
        Canvas { context, size in
            for line in drawingLines {
                let path = paintEngine.createPath(for: line.points)
                context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

struct PaintCanvasView: View {
    @State private var lines = [PaintLine]()
    @State private var deletedLines = [PaintLine]()
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 1
    @State private var clearConfirmationState: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                DrawingCanvas(drawingLines: $lines)
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
                    Button(action: saveCanvas) {
                        Label("Сохранить", systemImage: "square.and.arrow.down")
                    }
                    Button(action: shareCanvas) {
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

func saveCanvas() {
    print("Saved Canvas")
}

func shareCanvas() {
    print("Shared Canvas")
}

struct PaintCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PaintCanvasView()
            .preferredColorScheme(.light)
        PaintCanvasView()
            .preferredColorScheme(.dark)
    }
}
