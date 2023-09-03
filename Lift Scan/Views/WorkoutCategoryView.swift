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
    @State var isAddNewSelected = false
    @State var showingDeleteAlert = false
    @State var categoryForDeletion = ""

    var body: some View {
        ScrollViewReader { scrollView in
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categoryManager.categories, id: \.self) { category in
                            let isSelected = category == selectedCategory
                            let shadowColor = isSelected ? Color("BackgroundColor-300") : Color(.clear)
                            CategoryLabel(categoryName: category, isSelected: isSelected, shadowColor: shadowColor)
                                .simultaneousGesture(TapGesture().onEnded {
                                    withAnimation {
                                        selectedCategory = category
                                        isAddNewSelected = false
                                    }
                                })
                                .onLongPressGesture {
                                    print("LONG PRESS")
                                    categoryForDeletion = category
                                    showingDeleteAlert = true
                                }
                        }
                        if isAddNewSelected {
                            AddCategoryForm(isAddNewSelected: $isAddNewSelected, width: geometry.size.width * 0.9)
                                .id("AddCategoryFormID")
                        } else {
                            Button(action: {
                                isAddNewSelected = true
                                selectedCategory = ""
                            }) {
                                CategoryLabel(categoryName: "Add New...", isSelected: false, shadowColor: Color(.clear))
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.leading)
                    .onChange(of: isAddNewSelected) { scrollRight in
                        if scrollRight {
                            withAnimation {
                                scrollView.scrollTo("AddCategoryFormID")
                            }
                        }
                    }
                }
                .alert(isPresented: $showingDeleteAlert, content: {
                    Alert(
                        title: Text("Delete \(categoryForDeletion)?"),
                        message: Text("The associated workouts will not be deleted."),
                        primaryButton: .destructive(Text("Remove")) {
                            categoryManager.removeCategory(categoryForDeletion)
                        },
                        secondaryButton: .cancel())
                })
            }
        }
    }
}

struct CategoryLabel: View {
    let categoryName: String
    let isSelected: Bool
    let shadowColor: Color
    
    var body: some View {
        Text(categoryName)
            .font(.system(size: isSelected ? 30 : 20))
            .padding(.horizontal, 30)
            .padding(.vertical, 25)
            .foregroundColor(Color("BackgroundInvertedColor"))
            .shadow(color: shadowColor, radius: 14)
            .cornerRadius(15)
            .opacity(isSelected ? 1.0 : 0.7)
    }
}

struct AddCategoryForm: View {
    @EnvironmentObject var categoryManager: CategoryManager
    @State private var categoryName: String = ""
    @Binding var isAddNewSelected: Bool
    let width: CGFloat
    
    var body: some View {
        HStack {
            // Text Input for "Workout Category"
            TextField("New workout...", text: $categoryName)
                .padding(10)
                .background(Color("BackgroundInvertedColor").opacity(0.1)) // Assuming you have this color or replace it with any other
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .font(.system(size: 22))

            // Spacing
            Spacer()
                .frame(width: 20)

            // Add Button
            Button(action: {
                guard !categoryName.isEmpty else { return }
                withAnimation {
                    categoryManager.categories.append(categoryName)
                    categoryName = ""
                    isAddNewSelected = false
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(width: width)
        .padding()
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
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
