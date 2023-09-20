//
//  NewWorkoutSetFormView.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/4/23.
//

import SwiftUI

struct NewWorkoutSetFormView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var isPresented: Bool
    @Binding var weight: Float
    @Binding var reps: Int16
    @Binding var complete: Bool
    @Binding var selectedForDeletion: Bool
    let update: Bool
    var onPrimary: () -> Void
    var onSecondary: () -> Void
    @State var showingDeleteAlert = false
    
    var cancelButtonColor: Color { update ? Color.red : Color.backgroundInverted.opacity(0.8) }
    
    var correctText: String {
        return "\(update ? "Update" : "Record")"
    }

    var body: some View {
        VStack {
            Section(header: Text(correctText + " Set").font(.title).padding(.bottom, 50).padding(.top, 20)) {
                HStack {
                    // Complete radio button
                    VStack {
                        Text("All")
                            .font(.subheadline)
                        Button(action: {
                            print("")
                            complete.toggle()
                            print("Complete: \(complete)")
                        }) {
                            if complete {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color("BackgroundInvertedColor"))
                                    .frame(height: 150)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color(.orange))
                                    .frame(height: 150)
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    // Reps picker wheel
                    VStack {
                        Text("Reps")
                            .font(.subheadline)
                        RepsPicker(reps: $reps)
                            .frame(width: 125, height: 150)
                    }
                    
                    Spacer()
                    
                    // Weight picker wheel
                    VStack {
                        Text("Weight")
                            .font(.subheadline)
                        WeightPicker(weight: $weight)
                            .frame(width: 150, height: 150)
                    }
                }
            }
            Section {
                HStack {
                    // Cancel Button
                    Button(action: {
                        if update {
                            selectedForDeletion = true
                            showingDeleteAlert = true
                        } else {
                            isPresented = false
                        }
                    }, label: {
                        HStack(alignment: .center, spacing: 2) {
                            Image(systemName: update ? "minus.circle" : "chevron.backward.circle")
                                .font(.title2)
                            Text(update ? "Delete" : "Cancel")
                                .font(.title3)
                                .padding(12)
                        }
                        .foregroundStyle(cancelButtonColor)
                    })
                    .padding(.bottom, 20)
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    // Log New Workout Button
                    Button(action: {
                        onPrimary()
                        isPresented = false
                    }, label: {
                        HStack(alignment: .center, spacing: 2) {
                            Image(systemName: update ? "square.and.pencil" : "plus.circle")
                                .font(.title2)
                                .foregroundColor(Color("TextAccentColor"))
                            Text(correctText)
                                .font(.title3)
                                .foregroundColor(Color("TextAccentColor"))
                                .padding(12)
                        }
                    })
                    //                .padding()
                    .padding(.bottom, 20)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .padding(20)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete workout log?"),
                message: Text("Are you sure you want to delete this workout log? This cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    withAnimation {
                        onSecondary()
                        isPresented = false
                    }
                },
                secondaryButton: .cancel() {
                    withAnimation {
                        selectedForDeletion = false
                    }
                }
            )
        }
    }
}

//struct NewWorkoutSetFormView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}

#Preview("Create") {
    @State var weight: Float = 120.0
    @State var reps: Int16 = 12
    @State var complete = true
    @State var isPresented = true
    @State var selectedForDeletion = true
    let update = false
    let onPrimary = {}
    let onSecondary = {}

    return NewWorkoutSetFormView(isPresented: $isPresented, weight: $weight, reps: $reps, complete: $complete, selectedForDeletion: $selectedForDeletion, update: update, onPrimary: onPrimary, onSecondary: onSecondary)
}

#Preview("Update") {
    @State var weight: Float = 120.0
    @State var reps: Int16 = 12
    @State var complete = true
    @State var isPresented = true
    @State var selectedForDeletion = true
    let update = true
    let onPrimary = {}
    let onSecondary = {}

    return NewWorkoutSetFormView(isPresented: $isPresented, weight: $weight, reps: $reps, complete: $complete, selectedForDeletion: $selectedForDeletion, update: update, onPrimary: onPrimary, onSecondary: onSecondary)
}
