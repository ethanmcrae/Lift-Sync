//
//  ContentView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    @State private var isPresentingScanner = false
    @State private var scannedCode: String?
    @State private var selectedCategory = "Legs" // Default category
    
    var body: some View {
        NavigationView {
            VStack {
                QRScannerButton(isPresentingScanner: $isPresentingScanner)
                if let scannedCode = scannedCode {
                    ScannedWorkoutView(scannedCode: scannedCode)
                } else {
                    WorkoutCategoryView(selectedCategory: $selectedCategory)
                    WorkoutGridView(selectedCategory: $selectedCategory)
                }
            }
            .sheet(isPresented: $isPresentingScanner) {
                QRScannerView { code in
                    scannedCode = code
                    isPresentingScanner = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

