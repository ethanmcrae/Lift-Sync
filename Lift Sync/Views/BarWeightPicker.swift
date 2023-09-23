//
//  BarWeightPicker.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/12/23.
//

import SwiftUI

struct BarWeightPicker: View {
    // Generates 0 -> 300 with an increment of 5
    let values: [Int16] = stride(from: 0, through: 300, by: 5).map { $0 }
    
    @Binding var barWeight: Int16
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
//        VStack {
            Picker("Select Value", selection: $barWeight) {
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
//        }
    }
}

struct BarWeightPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var barWeight: Int16 = 35
        BarWeightPicker(barWeight: $barWeight)
    }
}
