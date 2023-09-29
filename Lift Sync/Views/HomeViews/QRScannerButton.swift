//
//  QRScannerButton.swift
//  Lift Sync
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
                .frame(width: 100, height: 100)
                .padding(30)
                .background(Color("BackgroundColor"))
                .foregroundColor(Color("BackgroundInvertedColor").opacity(0.9))
                .cornerRadius(42)
        }
        .padding(.vertical, 50)
    }
}

struct QRScannerButton_Previews: PreviewProvider {
    @State static var isPresentingScanner = false
    
    static var previews: some View {
        ZStack {
            Color("AccentColor-600")
            QRScannerButton(isPresentingScanner: $isPresentingScanner)
        }
    }
}
