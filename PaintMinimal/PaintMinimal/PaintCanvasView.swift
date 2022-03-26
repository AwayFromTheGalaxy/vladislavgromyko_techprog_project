//
//  PaintCanvasView.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct PaintCanvasView: View {
    @State private var lines = [PaintLine]()
    @State private var deletedLines = [PaintLine]()
    @State private var selectedColor: Color = .black
    @State private var selectedLineWidth: CGFloat = 1
    @State private var clearConfirmationState: Bool = false
    
    let paintEngine = PaintEngine()

    var body: some View {
        VStack {
            HStack {
                ColorPicker("Color Palette", selection: $selectedColor)
                    .labelsHidden()
                Slider(value: $selectedLineWidth, in: 1...20) {
                    Text("linewidth")
                }
                    .frame(maxWidth: 100)
                Text(String(format: "%.0f", selectedLineWidth))
                    .fontWeight(.medium)
                
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
                
                Button("Очистить") {
                    clearConfirmationState = true
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
            }.padding()

            ZStack {
                Color.white

                ForEach(lines){ line in
                    PaintShape(points: line.points)
                        .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                }
            }
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ value in
                let newPoint = value.location
                if value.translation.width + value.translation.height == 0 {
                    lines.append(PaintLine(points: [newPoint], color: selectedColor, lineWidth: selectedLineWidth))
                } else {
                    let index = lines.count - 1
                    lines[index].points.append(newPoint)
                }
                
            }).onEnded({ value in
                if let last = lines.last?.points, last.isEmpty {
                    lines.removeLast()
                }
            })
            )
        }
    }
}

struct PaintCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PaintCanvasView()
    }
}
