//
//  CardLayout.swift
//  MyPinch
//
//  Created by Kondamoori, S. (Srinivasarao) on 21/10/2024.
//

import Foundation
import SwiftUI

enum Constants {
    static let cardBackgroundColor: Color = Color.white
    static let shadowColor: Color = Color(#colorLiteral(red: 0.850, green: 0.850, blue: 0.850, alpha: 1))
}

extension View {
    public func cardView(padding: CGFloat = 0) -> some View {
        modifier(CardViewModifier(padding: padding))
    }
}

struct CardViewModifier: ViewModifier {
    var padding: CGFloat
    func body(content: Content) -> some View {
        content
            .padding([.all], padding)
            .background(
                Color.white
                    .modifier(ShadowViewModifier())
            )
    }
    
}

private struct ShadowViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content.shadow(color: Constants.shadowColor, radius: 4, y: 4)
    }
}

// MARK: - Previews

struct CardViewContainer_Previews: PreviewProvider {
    
    static var previews: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Text("Hello")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardView(padding: 20)
                
                VStack(spacing: 16) {
                    Text("Hello")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .cardView(padding: 16)
            }
        }
    }
    
}
