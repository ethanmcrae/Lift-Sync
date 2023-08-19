//
//  DateExtension.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/8/23.
//

import Foundation

extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
