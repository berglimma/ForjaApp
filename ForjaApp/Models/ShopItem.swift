//
//  ShopItem.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Foundation
import SwiftUI

struct ShopItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let price: Int
    let rarity: ItemRarity
    let gradientColors: [String]

    var swiftUIColors: [Color] {
        gradientColors.compactMap { hex in Color(hex: hex) }
    }
}

enum ItemRarity: String, Codable, CaseIterable {
    case comum
    case raro
    case epico
    case lendario

    var label: String {
        switch self {
        case .comum: return "Comum"
        case .raro: return "Raro"
        case .epico: return "Épico"
        case .lendario: return "Lendário"
        }
    }

    var color: Color {
        switch self {
        case .comum: return .gray
        case .raro: return .blue
        case .epico: return .purple
        case .lendario: return .orange
        }
    }
}

struct OwnedCollectible: Identifiable, Codable, Hashable {
    let id: String
    let itemID: String
    let acquiredAt: Date
}
