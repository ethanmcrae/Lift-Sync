//
//  UpdateWorkoutDateForm.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/24/23.
//

import SwiftUI

struct UpdateWorkoutDateForm: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var isPresented: Bool
    @Binding var date: Date
    @Binding var log: WorkoutLog
    
    var FormHeader: some View {
        Text("Select a new date")
            .font(isiPad ? .system(size: 60) : .title)
            .padding(.bottom, 20)
            .padding(.top, 25)
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func updateDate() {
        log.date = date
        workoutManager.updateLog(log, date: date)
        isPresented = false
    }

    var body: some View {
        VStack {
            // Section Contents: Title, Data Picker
            Section(header: FormHeader) {
                if isiPad {
                    Spacer()
                }
                
                // Date Picker
                HStack {
                    DatePicker(selection: $date) {
                        Text("Select a new date...")
                    }
                    .datePickerStyle(.graphical)
                }
                .padding()
                
                if isiPad {
                    Spacer()
                }
            }
            
            // Section Contents: Submit button
            Section {
                Button(action: updateDate) {
                    Text("Save")
                    .font(isiPad ? .system(size: 30) : .title3)
                    .padding(isiPad ? 20 : 12)
                    .foregroundColor(Color("TextAccentColor"))
                    .padding(.horizontal, isiPad ? 80 : 30)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 20)
        }
        .padding(20)
    }
}

#Preview {
    @State var date = Date()
    @State var isPresented = true
    @State var workoutLog = PreviewManager.createMockWorkoutLog()
    let onComplete = {}

    return UpdateWorkoutDateForm(isPresented: $isPresented, date: $date, log: $workoutLog)
}
