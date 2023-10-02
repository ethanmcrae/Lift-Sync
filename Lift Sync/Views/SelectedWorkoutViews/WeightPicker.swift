//
//  WeightPicker.swift
//  Lift Sync
//
//  Created by Ethan McRae on 8/21/23.
//

import SwiftUI

struct WeightPicker: View {
    @Binding var weight: Float
    let values: [Float]
    
    
    init(weight: Binding<Float>) {
        self._weight = weight
        
        // Generates 0 -> 300 with increments of 1 and 2.5
        let firstValues: [Float] = stride(from: 0.0, through: 12.0, by: 1.0).map { $0 }
        let secondValues: [Float] = stride(from: 12.5, through: 300.0, by: 2.5).map { $0 }
        self.values = firstValues + secondValues
    }
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        VStack {
            Picker("Select Value", selection: $weight) {
                ForEach(values, id: \.self) { value in
                    if isiPad {
                        Text("\(value, specifier: "%.1f")").tag(value)
                            .font(.system(size: 25))
                    } else {
                        Text("\(value, specifier: "%.1f")").tag(value)
                    }
                }
            }
            .pickerStyle(.inline)
        }
    }
}

struct WeightPicker_Previews: PreviewProvider {
    static var previews: some View {
        @State var weight: Float = 120.0
        WeightPicker(weight: $weight)
    }
}
