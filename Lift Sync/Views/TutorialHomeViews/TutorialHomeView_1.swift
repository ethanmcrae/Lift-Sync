//
//  TutorialHomeView_1.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/16/23.
//

import SwiftUI

struct TutorialHomeView_1: View {
    @Binding var tutorialStep: Int
    let tutorial: TutorialManager.Tutorial
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.black)
                .opacity(0.85)
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 225, height: 250)
                        .foregroundStyle(Color.light)
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                }
                VStack {
                    Text("Welcome to Lift Sync")
                        .shadow(color: .black, radius: 4, x: 0, y: 2)
                        .font(isiPad ? .largeTitle : .title)
                        .padding(.vertical, 4)
                    Text("Let's get started...")
                        .font(isiPad ? .title2 : .body)
                        .shadow(color: .black, radius: 4, x: 0, y: 2)
                }
                .foregroundStyle(Color.light)
                .padding()
//                .background(RoundedRectangle(cornerRadius: 20.0).foregroundStyle(Color.black))
                .padding(.bottom, 100)
            }
        }
        .onTapGesture {
            TutorialManager.completeTutorialStep($tutorialStep, tutorial: tutorial)
        }
    }
}

#Preview {
    @State var tutorialStep = 1
    let tutorial = TutorialManager.Tutorial.home
    
    return TutorialHomeView_1(tutorialStep: $tutorialStep, tutorial: tutorial)
}
