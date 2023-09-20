//
//  ViewExtension.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/5/23.
//

import Foundation
import SwiftUI

struct BackgroundColor: ViewModifier {
    let color: Color
    
    init(_ color: Color) {
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content.background(color.ignoresSafeArea())
    }
}

struct FullScreen: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func backgroundColor(_ color: Color) -> some View {
        self.modifier(BackgroundColor(color))
    }
    
    func fullScreen() -> some View {
        self.modifier(FullScreen())
    }
}
