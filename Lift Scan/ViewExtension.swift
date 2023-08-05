//
//  ViewExtension.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/5/23.
//

import Foundation
import SwiftUI

struct BackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content.background(Color("BackgroundColor").ignoresSafeArea())
    }
}

struct FullScreen: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func backgroundColor() -> some View {
        self.modifier(BackgroundColor())
    }
    
    func fullScreen() -> some View {
        self.modifier(FullScreen())
    }
}
