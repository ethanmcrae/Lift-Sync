//
//  TutorialManager.swift
//  Lift Scan
//
//  Created by Ethan McRae on 9/16/23.
//

import Foundation
import SwiftUI

class TutorialManager: ObservableObject {
    enum Tutorial: String {
        // Tutorial Namespaces
        case home = "HomeView_0.1"
        // TODO: Add more cases here...
        
        // Tutorial Is Complete After x Steps
        var completeValue: Int {
            switch self {
            case .home:
                return 50
            // TODO: Add more cases here...
            }
        }
        
        // Function to produce a binding based on a current step against the completeValue
        func isStep(current step: Binding<Int>, matching checkForStep: Int) -> Binding<Bool> {
            Binding(
                get: { step.wrappedValue == checkForStep },
                set: { _ in completeTutorialStep(step, tutorial: self) }
            )
        }
    }
    
    static func completeTutorialStep(_ step: Binding<Int>, tutorial: Tutorial) {
        // Check for total completion
        if step.wrappedValue == tutorial.completeValue {
            step.wrappedValue = -1
            complete(tutorial)
        } else {
            step.wrappedValue += 1
            print("Incremented step to \(step.wrappedValue)")
        }
    }
    
    static func isShowingPopover(_ tutorial: Tutorial, currentStep: Binding<Int>, expected: Int) -> Binding<Bool> {
        return tutorial.isStep(current: currentStep, matching: expected)
    }
    
    static func getStep(_ tutorial: Tutorial) -> Int {
        return NSUbiquitousKeyValueStore.default.object(forKey: tutorial.rawValue) as? Int ?? 1
    }
    
    static func isComplete(_ tutorial: Tutorial, step: Int) -> Bool {
        return step >= tutorial.completeValue
    }
    
    static func complete(_ tutorial: Tutorial) {
        NSUbiquitousKeyValueStore.default.set(true, forKey: tutorial.rawValue)
    }
}
