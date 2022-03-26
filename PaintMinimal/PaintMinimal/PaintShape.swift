//
//  PaintShape.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct PaintShape: Shape {
    let points: [CGPoint]
    let engine = PaintEngine()
    func path(in rect: CGRect) -> Path {
        engine.createPath(for: points)
    }
}
