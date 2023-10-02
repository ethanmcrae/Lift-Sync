//
//  CompletePicker.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/29/23.
//

import SwiftUI

struct CompletePicker: View {
    @Binding var completionIcon: String
    
    let iconChoices = ["xmark.circle.fill", "checkmark.circle.fill", "flame.fill", "eurozonesign.circle.fill"]
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack {
            Text(WorkoutManager.completionIconToName(completionIcon))
                .font(isiPad ? .title : .subheadline)
            
            Picker("Select Value", selection: $completionIcon) {
                ForEach(iconChoices, id: \.self) { value in
                    Image(systemName: value)
                        .font(.system(size: isiPad ? 25 : 21))
                        .tag(value)
                }
            }
            .pickerStyle(.inline)
            .frame(width: isiPad ? 200 : 125, height: isiPad ? 300 : 150)
        }
    }
}

#Preview {
    @State var completionIcon = "checkmark.circle.fill"
    
    return CompletePicker(completionIcon: $completionIcon)
}
