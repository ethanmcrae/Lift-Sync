//
//  WorkoutGridView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI
import UIKit

struct WorkoutGridView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedCategory: String

    var body: some View {
        let workouts = workoutManager.workouts[selectedCategory]?.filter { $0.name != nil } ?? []
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
            ForEach(workouts) { workout in
                NavigationLink(destination: ScannedWorkoutView(workout: workout)
                    .environmentObject(workoutManager)) {
                    VStack {
                        Rectangle()
                            .fill(Color(hex: workout.color ?? "#000000"))
                            .frame(height: 150)
                            .cornerRadius(15)
                        Text(workout.name ?? "")
                    }
                    .padding(.vertical, 10)
                    .background(Color(hex: workout.color ?? "#ffffff"))
                    .cornerRadius(15)
                    .shadow(color: .gray, radius: 4, x: 0.0, y: 0.0)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct WorkoutGridView_Previews: PreviewProvider {
    static var previews: some View {
        @State var selectedCategory = "Legs"
        let persistentContainer = previewContainer()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let categoryManager = CategoryManager()

        return WorkoutGridView(selectedCategory: $selectedCategory)
            .environmentObject(workoutManager)
            .environmentObject(categoryManager)
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
    
    var hexString: String {
        let uiColor = UIColor(self)
        let components = uiColor.cgColor.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        let a = components?[3] ?? 0
        let red = Int(r * 255)
        let green = Int(g * 255)
        let blue = Int(b * 255)
        let alpha = Int(a * 255)
        let hex = String(format: "%02X%02X%02X%02X", red, green, blue, alpha)
        return hex
    }
    
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            let r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            let g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            let b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            let a = CGFloat(hexNumber & 0x000000ff) / 255
            return (r, g, b, a)
        }
        return (0, 0, 0, 1)
    }
}

extension UIColor {
    convenience init(_ color: Color) {
        let components = color.components()
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
}
