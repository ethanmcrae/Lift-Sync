//
//  WorkoutCategoryView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct WorkoutCategoryView: View {
    @Binding var selectedCategory: String
    @EnvironmentObject var categoryManager: CategoryManager
    @Binding var homeTutorialStep: Int
    @State var isAddNewSelected = false
    @State var showingDeleteAlert = false
    @State var categoryForDeletion = ""
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

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
                                        scrollView.scrollTo(category, anchor: .center)
                                        isAddNewSelected = false
                                    }
                                })
                                .onLongPressGesture {
                                    print("LONG PRESS")
                                    categoryForDeletion = category
                                    showingDeleteAlert = true
                                }
                                .popover(isPresented: TutorialManager.isShowingPopover(TutorialManager.Tutorial.home, currentStep: $homeTutorialStep, expected: 5)) {
                                    TutorialHomePopup(text: "Workouts go here", step: $homeTutorialStep, tutorial: TutorialManager.Tutorial.home)
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
//                    .padding(.vertical)
                    .padding(.leading)
                    .onChange(of: isAddNewSelected) { scrollRight in
                        if scrollRight {
                            withAnimation {
                                scrollView.scrollTo("AddCategoryFormID")
                            }
                        }
                    }
                }
                .padding(.vertical, selectedCategory.isEmpty ? 0 : 10)
                .alert(isPresented: $showingDeleteAlert, content: {
                    Alert(
                        title: Text("Delete \(categoryForDeletion)?"),
                        message: Text("This deletes the category. The associated workouts will not be deleted."),
                        primaryButton: .destructive(Text("Remove")) {
                            categoryManager.delete(categoryForDeletion)
                            selectedCategory = ""
                        },
                        secondaryButton: .cancel())
                })
                .frame(height: isiPad ? 120 : 80)
//                .background(Color.orange)
            }
        }
        .frame(height: isiPad ? 120 : 80)
//        .background(Color.yellow)
    }
}

struct CategoryLabel: View {
    let categoryName: String
    let isSelected: Bool
    let shadowColor: Color
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var labelTextSize: CGFloat {
        if isiPad {
            return isSelected ? 45 : 30
        } else {
            return isSelected ? 30 : 20
        }
    }
    
    var body: some View {
        Text(categoryName)
            .font(.system(size: labelTextSize))
            .padding(.horizontal, 30)
            .foregroundColor(Color("BackgroundInvertedColor"))
            .frame(height: 60)
            .shadow(color: shadowColor, radius: 14)
            .cornerRadius(15)
            .opacity(isSelected ? 1.0 : 0.7)
//            .background(Color.green)
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
            TextField("New category...", text: $categoryName)
                .autocapitalization(.words)
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
                    // Update state
                    categoryManager.create(categoryName)
                    // Update UI
                    categoryName = ""
                    isAddNewSelected = false
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
//                    .background(Color.accentColor)
//                    .cornerRadius(8)
                    .foregroundColor(Color("AccentColor-400"))
            }
        }
//        .padding()
        .frame(width: width, height: 60)
        .padding(.horizontal)
//        .background(Color.teal)
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        let workoutManager = PreviewManager.mockWorkoutManager()
        let categoryManager = PreviewManager.mockCategoryManager()
        @State var selectedCategory = "Legs"
        @State var homeTutorialStep = 4

        return ZStack {
            VStack {
                Color("AccentColor-600")
                Color("BackgroundColor")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                    .frame(height: 50)
                WorkoutCategoryView(selectedCategory: $selectedCategory, homeTutorialStep: $homeTutorialStep)
                    .environmentObject(workoutManager)
                    .environmentObject(categoryManager)
            }
        }
    }
}
