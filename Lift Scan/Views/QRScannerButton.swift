//
//  QRScannerButton.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI

struct QRScannerButton: View {
    @Binding var isPresentingScanner: Bool

    var body: some View {
        Button(action: {
            isPresentingScanner = true
        }) {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .frame(width: 80, height: 80)
                .padding(40)
                .background(Color("AccentColor"))
                .foregroundColor(.white)
//                .clipShape(Circle())
                .cornerRadius(50)
        }
        .padding(.top, 30)
        .padding(.bottom, 10)
    }
}

struct QRScannerButton_Previews: PreviewProvider {
    @State static var isPresentingScanner = false
    
    static var previews: some View {
        QRScannerButton(isPresentingScanner: $isPresentingScanner)
    }
}
