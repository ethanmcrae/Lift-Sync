//
//  WeightPicker.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/21/23.
//

import SwiftUI

struct WeightPicker: View {
    // Generates 0 -> 300 with an increment of 2.5
    let values: [Float] = stride(from: 0.0, through: 300.0, by: 2.5).map { $0 }
    
    @Binding var weight: Float

    var body: some View {
        VStack {
            Picker("Select Value", selection: $weight) {
                ForEach(values, id: \.self) { value in
                    Text("\(value, specifier: "%.1f")").tag(value)
                }
            }
            .pickerStyle(.inline)
        }
        .onAppear {
            print("WightPicker: \(weight)")
        }
    }
}

struct WeightPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var weight: Float = 120.0
        WeightPicker(weight: $weight)
    }
}
