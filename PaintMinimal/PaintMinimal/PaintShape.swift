//
//  PaintShape.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct PaintShape: Shape {
    let engine = PaintEngine()
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        engine.createPath(for: points)
    }
}
