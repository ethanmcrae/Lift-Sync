//
//  WorkoutCategoryView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct WorkoutCategoryView: View {
    @Binding var selectedCategory: String
    @EnvironmentObject var categoryManager: CategoryManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categoryManager.categories, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 25)
                            .background(
                                category == selectedCategory
                                    ? LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color("AccentColor-600")]), startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(gradient: Gradient(colors: [Color.clear]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .opacity(selectedCategory == category ? 1.0 : 0.7)
                    }
                }
            }
            .padding(.top)
            .padding(.leading)
        }
    }
}


struct WorkoutCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = previewContainer()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let categoryManager = CategoryManager()
        @State var selectedCategory = "Legs"
        
        // Create Mock Workouts
        let workout1 = Workout(context: workoutManager.viewContext)
        workout1.name = "Seated Rows"
        workout1.color = "#00ffff"
        workout1.category = "Legs"
        
        let workout2 = Workout(context: workoutManager.viewContext)
        workout2.name = "Bench Press"
        workout2.color = "#cc00dd"
        workout2.category = "Legs"
        
        let workout3 = Workout(context: workoutManager.viewContext)
        workout3.name = "Squats"
        workout3.color = "#cc55dd"
        workout3.category = "Legs"
        
        workoutManager.workouts["Legs"] = [workout1, workout2, workout3]

        return ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            WorkoutCategoryView(selectedCategory: $selectedCategory)
                .environmentObject(workoutManager)
                .environmentObject(categoryManager)
        }
    }
}
