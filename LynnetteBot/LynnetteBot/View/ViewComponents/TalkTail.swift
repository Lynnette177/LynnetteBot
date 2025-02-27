//
//  TalkTail.swift
//  LynnetteBot
//
//  Created by 张凯扬 on 2025/2/15.
//
import SwiftUI
struct TalkTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.47933*width, y: 0))
        path.addCurve(to: CGPoint(x: width, y: height), control1: CGPoint(x: 0.65345*width, y: 0), control2: CGPoint(x: 0.80906*width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addCurve(to: CGPoint(x: 0.21336*width, y: 0.55294*height), control1: CGPoint(x: 0.06453*width, y: height), control2: CGPoint(x: 0.13745*width, y: 0.7841*height))
        path.addLine(to: CGPoint(x: 0.22328*width, y: 0.52272*height))
        path.addCurve(to: CGPoint(x: 0.22825*width, y: 0.50758*height), control1: CGPoint(x: 0.22493*width, y: 0.51767*height), control2: CGPoint(x: 0.22659*width, y: 0.51263*height))
        path.addLine(to: CGPoint(x: 0.23821*width, y: 0.47728*height))
        path.addCurve(to: CGPoint(x: 0.47933*width, y: 0), control1: CGPoint(x: 0.31803*width, y: 0.23508*height), control2: CGPoint(x: 0.40045*width, y: 0))
        path.closeSubpath()
        return path
    }
}
