//
//  Color+Hex.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import SwiftUI

extension Color {
    init?(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized = sanitized.replacingOccurrences(of: "#", with: "")

        guard sanitized.count == 6, let intValue = UInt64(sanitized, radix: 16) else {
            return nil
        }

        let red = Double((intValue >> 16) & 0xFF) / 255
        let green = Double((intValue >> 8) & 0xFF) / 255
        let blue = Double(intValue & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
