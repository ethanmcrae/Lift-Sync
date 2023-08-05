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
                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b386e"), Color(hex: "#314594")]), startPoint: .leading, endPoint: .trailing))
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
    @State static var selectedCategory = ""
    
    static var previews: some View {
        WorkoutCategoryView(selectedCategory: $selectedCategory)
    }
}
