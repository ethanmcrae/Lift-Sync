//
//  WorkoutCategoryView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct WorkoutCategoryView: View {
    @Binding var selectedCategory: String
    let categories = ["Legs", "Back / Biceps", "Chest / Triceps", "Core / Shoulders"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .padding(.horizontal)
                            .background(selectedCategory == category ? Color(#colorLiteral(red: 0.4, green: 0.0, blue: 0.6, alpha: 1.0)) : Color(#colorLiteral(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.top)
        }
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    @State static var selectedCategory = "Legs"
    
    static var previews: some View {
        WorkoutCategoryView(selectedCategory: $selectedCategory)
    }
}
