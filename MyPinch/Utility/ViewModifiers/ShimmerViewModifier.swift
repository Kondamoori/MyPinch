//
//  ShimmerViewModifier.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import SwiftUI

struct ShimmerViewModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.gray, Color.clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase * 350, y: 0)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
            )
            .mask(content)
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerViewModifier())
    }
}

struct ShimmerCellView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 150, height: 200)
            .shimmer()
    }
}

