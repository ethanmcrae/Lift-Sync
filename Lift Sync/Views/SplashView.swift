//
//  SplashView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/16/23.
//

import SwiftUI

struct SplashView: View {
    // List of system SF Symbols that are fitness-themed
    let symbols = ["figure.run", "figure.archery", "figure.boxing", "figure.cooldown", "figure.core.training", "figure.cross.training", "figure.strengthtraining.functional", "figure.highintensity.intervaltraining", "figure.jumprope", "figure.kickboxing", "figure.martial.arts", "figure.pool.swim", "figure.outdoor.cycle", "figure.pilates", "figure.play", "figure.rolling", "figure.rower", "figure.stairs", "figure.step.training", "figure.track.and.field", "figure.strengthtraining.traditional", "figure.yoga"]

    // Shuffled symbols, this gets set once in the initializer
    let shuffledSymbols: [String]

    @State private var currentIndex = 0
    @State private var opacity = 1.0
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()  // Every 2 seconds, adjust to your preference

    init() {
        shuffledSymbols = symbols.shuffled()
    }

    var body: some View {
        VStack {
            Spacer()

            Image(systemName: shuffledSymbols[currentIndex])
                .resizable()
                .foregroundColor(Color.accentColor400)
                .scaledToFit()
                .frame(width: 100, height: 100)  // Adjust frame size as needed
                .opacity(opacity)
                .onReceive(timer) { _ in
                    withAnimation {
                        opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {  // Wait for half the timer duration
                        if currentIndex < shuffledSymbols.count - 1 {
                            currentIndex += 1
                        } else {
                            currentIndex = 0
                        }
                        withAnimation {
                            opacity = 1.0
                        }
                    }
                }
            
            Text("Catching up to speed...")
                .font(.title2)
                .padding(.top, 50)
                .opacity(0.8)
                .padding(.bottom, 100)

            Spacer()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
