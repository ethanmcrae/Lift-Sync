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
                .padding()
                .background(Color(#colorLiteral(red: 0.4, green: 0.0, blue: 0.6, alpha: 1.0)))
                .foregroundColor(.white)
                .clipShape(Circle())
        }
        .padding(.top, 50)
    }
}

struct QRScannerButton_Previews: PreviewProvider {
    @State static var isPresentingScanner = false
    
    static var previews: some View {
        QRScannerButton(isPresentingScanner: $isPresentingScanner)
    }
}
