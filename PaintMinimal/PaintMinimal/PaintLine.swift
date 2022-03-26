//
//  PaintLine.swift
//  PaintMinimal
//
//  Created by Владислав on 26.03.2022.
//

import SwiftUI

struct PaintLine: Identifiable {
    let id = UUID()
    var color: Color
    var points: [CGPoint]
    var lineWidth: CGFloat
}
