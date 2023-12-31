//
//  repsPicker.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/22/23.
//

import SwiftUI

struct RepsPicker: View {
    // Generates 0 -> 200 with an increment of 1
    let values: [Int16] = stride(from: 1, through: 200, by: 1).map { $0 }
    
    @Binding var reps: Int16
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack {
            Picker("Select Value", selection: $reps) {
                ForEach(values, id: \.self) { value in
                    if isiPad {
                        Text("\(value)").tag(value)
                            .font(.system(size: 25))
                    } else {
                        Text("\(value)").tag(value)
                    }
                }
            }
            .pickerStyle(.inline)
        }
    }
}

struct RepsPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var reps: Int16 = 12
        RepsPicker(reps: $reps)
    }
}
