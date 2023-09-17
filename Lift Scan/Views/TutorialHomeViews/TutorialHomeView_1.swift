//
//  TutorialHomeView_1.swift
//  Lift Scan
//
//  Created by Ethan McRae on 9/16/23.
//

import SwiftUI

struct TutorialHomeView_1: View {
    @Binding var tutorialStep: Int
    let tutorial: TutorialManager.Tutorial
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.black)
                .opacity(0.85)
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 200, height: 250)
                        .foregroundStyle(Color.backgroundInverted)
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(.accent)
                        .font(.system(size: 100))
                        .padding()
                }
                VStack {
                    Text("Welcome to Lift Scan")
                        .font(.title)
                        .padding(.vertical, 4)
                    Text("Let's get started...")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20.0).foregroundStyle(Color.black))
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
