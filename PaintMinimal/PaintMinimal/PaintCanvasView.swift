//
//  PaintCanvasView.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct PaintCanvasView: View {
    @State private var lines = [PaintLine]()

    var body: some View {
        VStack {
            ZStack {
                Color.white

                ForEach(lines){ line in
                    PaintShape(points: line.points)
                        .stroke(line.color, style: StrokeStyle(lineWidth: line.lineWidth, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

struct PaintCanvasView_Previews: PreviewProvider {
    static var previews: some View {
        PaintCanvasView()
    }
}
