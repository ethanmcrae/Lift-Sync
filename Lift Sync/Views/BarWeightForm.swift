//
//  BarWeightForm.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/12/23.
//

import SwiftUI

struct BarWeightForm: View {
    @Binding var barWeight: Int16
    
    var body: some View {
        HStack {
            // Title
            Text("Bar Weight")
                .frame(width: 100, alignment: .leading)
            
            // Weight Picker
            BarWeightPicker(barWeight: $barWeight)
                .frame(height: 100)
        }
        .padding(.horizontal, 30)
    }
}

struct BarWeightForm_Previews: PreviewProvider {
    static var previews: some View {
        @State var barWeight: Int16 = 35
        
        BarWeightForm(barWeight: $barWeight)
    }
}
