//
//  WorkoutGridView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct WorkoutGridView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedCategory: String

    var body: some View {
        let workouts = workoutManager.workouts[selectedCategory] ?? []
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
            ForEach(workouts) { workout in
                // This is a placeholder. Replace with the actual workout view.
                Rectangle()
                    .fill(Color(hex: workout.color ?? ""))
                    .frame(height: 150)
                    .cornerRadius(15)
            }
        }
        .padding(.horizontal)
    }
}

struct WorkoutGridView_Previews: PreviewProvider {
    @State static var selectedCategory = "Legs"

    static var previews: some View {
        WorkoutGridView(selectedCategory: $selectedCategory)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
