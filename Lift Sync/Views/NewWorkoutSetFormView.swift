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
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack {
            Section(header: Text(correctText + " Set")
                .font(isiPad ? .system(size: 60) : /*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .padding(.bottom, 50)
                .padding(.top, 20)) {
                if isiPad {
                    Spacer()
                }
                HStack {
                    // Complete radio button
                    VStack {
                        Text(isiPad ? "Complete" : "All")
                            .font(isiPad ? .title : .subheadline)
                        Button(action: {
                            complete.toggle()
                        }) {
                            if complete {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(isiPad ? .system(size: 40) : /*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color("BackgroundInvertedColor"))
                                    .frame(height: isiPad ? 300 : 150)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .font(isiPad ? .system(size: 40) : /*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                    .foregroundColor(Color(.orange))
                                    .frame(height: isiPad ? 300 : 150)
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    // Reps picker wheel
                    VStack {
                        Text("Reps")
                            .font(isiPad ? .title : .subheadline)
                        RepsPicker(reps: $reps)
                            .frame(width: isiPad ? 200 : 125, height: isiPad ? 300 : 150)
                    }
                    
                    Spacer()
                    
                    // Weight picker wheel
                    VStack {
                        Text("Weight")
                            .font(isiPad ? .title : .subheadline)
                        WeightPicker(weight: $weight)
                            .frame(width: isiPad ? 300 : 150, height: isiPad ? 300 : 150)
                    }
                }
                    if isiPad {
                        Spacer()
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
                            Label(update ? "Delete" : "Cancel", systemImage: update ? "minus.circle" : "chevron.backward.circle")
                                .font(isiPad ? .system(size: 30) : .title3)
                                .padding(isiPad ? 20 : 12)
                                .foregroundStyle(cancelButtonColor)
                                .padding(.horizontal, isiPad ? 30 : 0)
                        }
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
                            Label(correctText, systemImage: update ? "plus.circle" : "square.and.pencil")
                                .font(isiPad ? .system(size: 30) : .title3)
                                .padding(isiPad ? 20 : 12)
                                .foregroundColor(Color("TextAccentColor"))
                                .padding(.horizontal, isiPad ? 80 : 10)
 
                        }
                    })
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
