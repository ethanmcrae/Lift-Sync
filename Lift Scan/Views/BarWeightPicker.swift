//
//  BarWeightPicker.swift
//  Lift Scan
//
//  Created by Ethan McRae on 9/12/23.
//

import SwiftUI

struct BarWeightPicker: View {
    // Generates 0 -> 300 with an increment of 5
    let values: [Int16] = stride(from: 0, through: 300, by: 5).map { $0 }
    
    @Binding var barWeight: Int16

    var body: some View {
//        VStack {
            Picker("Select Value", selection: $barWeight) {
                ForEach(values, id: \.self) { value in
                    Text("\(value)").tag(value)
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
