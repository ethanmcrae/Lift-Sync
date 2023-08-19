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
                        let isSelected = category == selectedCategory
                        let shadowColor = isSelected ? Color("BackgroundColor-300") : Color(.clear)
                        Text(category)
//                            .font(.title2)
                            .font(.system(size: isSelected ? 30 : 20))
                            
                            .padding(.horizontal, 30)
                            .padding(.vertical, 25)
                            .foregroundColor(Color("BackgroundInvertedColor"))
                            .shadow(color: shadowColor, radius: 14)
                            .cornerRadius(15)
                            .opacity(selectedCategory == category ? 1.0 : 0.7)
                    }
                }
            }
            .padding(.vertical)
            .padding(.leading)
        }
    }
}


struct WorkoutCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = PreviewManager.container()
        let workoutManager = WorkoutManager(container: persistentContainer)
        let categoryManager = CategoryManager()
        @State var selectedCategory = "Legs"

        return ZStack {
            VStack {
                Color("AccentColor-600")
                Color("BackgroundColor")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Spacer()
                Spacer()
                WorkoutCategoryView(selectedCategory: $selectedCategory)
                    .environmentObject(workoutManager)
                    .environmentObject(categoryManager)
                Spacer()
                Spacer()
            }
        }
    }
}
