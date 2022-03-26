//
//  PaintLine.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct PaintLine: Identifiable {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    let id = UUID()
}
