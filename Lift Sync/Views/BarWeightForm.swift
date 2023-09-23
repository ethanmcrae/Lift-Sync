//
//  BarWeightForm.swift
//  Lift Sync
//
//  Created by Ethan McRae on 9/12/23.
//

import SwiftUI

struct BarWeightForm: View {
    @Binding var barWeight: Int16
    
    var isiPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        HStack {
            // Title
            if isiPad {
                Text("Bar Weight / Resistance")
                    .font(.system(size: 25))
                    .frame(width: 400, alignment: .leading)
            } else {
                Text("Bar Weight")
                    .frame(width: 100, alignment: .leading)
            }
            
            // Weight Picker
            BarWeightPicker(barWeight: $barWeight)
                .frame(height: isiPad ? 300 : 100)
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
