//
//  TutorialHomePopup.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/17/23.
//

import SwiftUI

struct TutorialHomePopup: View {
    let text: String
    @Binding var step: Int
    var tutorial: TutorialManager.Tutorial
    var small: Bool = false
    var lotsOfText: Bool {
        isiPad
            ? text.count > 30
            : text.count > 45
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(lotsOfText ? (isiPad ? .title : .title3) : (isiPad ? .title2 : .body))
                    .foregroundStyle(Color.dark)
                    .padding(.leading)
                    .opacity(0.75)
                
                if lotsOfText {
                    Rectangle()
                        .fill(Color.backgroundInverted.opacity(0.5))
                        .frame(width: 1)
                        .padding(.vertical)
                }
                
                Text(text)
                    .font(isiPad ? .title2 : .body)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.dark)
                    .padding(.trailing)
                    .padding(.top)
                    .padding(.bottom)
            }
            .presentationCompactAdaptation(horizontal: .popover, vertical: .sheet)
            .lineLimit(1...5)
            .frame(width: small ? (isiPad ? 250 : 175) : (isiPad ? 600 : 300))
            .frame(minHeight: 70)
            .background(Color.accentAlt.gradient)
    }
}

#Preview("Longer Text") {
    @State var tutorialStep = 2
    var tutorial = TutorialManager.Tutorial.home
    
    return Text("Hello, World!")
        .popover(isPresented: Binding<Bool>(get: { true }, set: { _ in })) {
            TutorialHomePopup(text: "Name your first workout category here, such as: Legs, Core, Back / Biceps, etc...", step: $tutorialStep, tutorial: tutorial, small: false)
        }
}

#Preview("Shorter Text") {
    @State var tutorialStep = 2
    var tutorial = TutorialManager.Tutorial.home
    
    return Text("Hello, World!")
        .popover(isPresented: Binding<Bool>(get: { true }, set: { _ in })) {
            TutorialHomePopup(text: "Tap me!", step: $tutorialStep, tutorial: tutorial, small: false)
        }
}

#Preview("Small") {
    @State var tutorialStep = 2
    var tutorial = TutorialManager.Tutorial.home
    
    return Text("Hello, World!")
        .popover(isPresented: Binding<Bool>(get: { true }, set: { _ in })) {
            TutorialHomePopup(text: "Tap me!", step: $tutorialStep, tutorial: tutorial, small: true)
        }
}
