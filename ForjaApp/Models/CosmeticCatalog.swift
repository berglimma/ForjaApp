//
//  CosmeticCatalog.swift
//  ForjaApp
//

import Foundation
import SwiftUI

enum ShopCurrency: String, Codable, Hashable {
    case ore
    case gems

    var label: String {
        switch self {
        case .ore: return "Minério"
        case .gems: return "Gemas"
        }
    }

    var emoji: String {
        switch self {
        case .ore: return "🪨"
        case .gems: return "💎"
        }
    }
}

enum CosmeticKind: String, Codable, Hashable {
    case anvilSkin
    case furnaceSkin
    case shopTheme
    case seasonalPack
}

enum CosmeticSeason: String, Codable, Hashable {
    case halloween
    case natal

    var label: String {
        switch self {
        case .halloween: return "Halloween"
        case .natal: return "Natal"
        }
    }
}

struct CosmeticItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let emoji: String
    let kind: CosmeticKind
    let gemPrice: Int
    let requiresSubscription: Bool
    let productID: String?
    let season: CosmeticSeason?
    let gradientColors: [String]

    var swiftUIColors: [Color] {
        gradientColors.compactMap { Color(hex: $0) }
    }

    var isDirectIAP: Bool { productID != nil }
}

enum CosmeticCatalog {
    static let defaultAnvilID = "anvil_iron"
    static let defaultFurnaceID = "furnace_ember"
    static let defaultThemeID = "theme_forge"

    static let items: [CosmeticItem] = [
        CosmeticItem(
            id: "anvil_iron",
            name: "Bigorna de Ferro",
            description: "A bigorna clássica da oficina.",
            emoji: "⚒️",
            kind: .anvilSkin,
            gemPrice: 0,
            requiresSubscription: false,
            productID: nil,
            season: nil,
            gradientColors: ["#4A5568", "#A0AEC0"]
        ),
        CosmeticItem(
            id: "anvil_obsidian",
            name: "Bigorna de Obsidiana",
            description: "Pedra vulcânica que segura o calor da sessão.",
            emoji: "🖤",
            kind: .anvilSkin,
            gemPrice: 80,
            requiresSubscription: false,
            productID: nil,
            season: nil,
            gradientColors: ["#1A202C", "#805AD5"]
        ),
        CosmeticItem(
            id: "anvil_royal",
            name: "Bigorna Real",
            description: "Exclusiva da assinatura Mestre Ferreiro.",
            emoji: "👑",
            kind: .anvilSkin,
            gemPrice: 0,
            requiresSubscription: true,
            productID: nil,
            season: nil,
            gradientColors: ["#B7791F", "#F6E05E"]
        ),
        CosmeticItem(
            id: "furnace_ember",
            name: "Fornalha de Brasas",
            description: "O fogo padrão da forja.",
            emoji: "🔥",
            kind: .furnaceSkin,
            gemPrice: 0,
            requiresSubscription: false,
            productID: nil,
            season: nil,
            gradientColors: ["#C05621", "#F6AD55"]
        ),
        CosmeticItem(
            id: "furnace_dragon",
            name: "Fornalha do Dragão",
            description: "Chamas mais altas e vermelhas.",
            emoji: "🐉",
            kind: .furnaceSkin,
            gemPrice: 120,
            requiresSubscription: false,
            productID: nil,
            season: nil,
            gradientColors: ["#9B2C2C", "#FC8181"]
        ),
        CosmeticItem(
            id: "furnace_aurora",
            name: "Fornalha Aurora",
            description: "Tema exclusivo de assinante.",
            emoji: "🌌",
            kind: .furnaceSkin,
            gemPrice: 0,
            requiresSubscription: true,
            productID: nil,
            season: nil,
            gradientColors: ["#553C9A", "#63B3ED"]
        ),
        CosmeticItem(
            id: "theme_forge",
            name: "Oficina Clássica",
            description: "A loja original do ferreiro.",
            emoji: "🏪",
            kind: .shopTheme,
            gemPrice: 0,
            requiresSubscription: false,
            productID: nil,
            season: nil,
            gradientColors: ["#2D2416", "#1A202C"]
        ),
        CosmeticItem(
            id: "theme_royal",
            name: "Salão Real",
            description: "Tema dourado exclusivo de assinante.",
            emoji: "🏰",
            kind: .shopTheme,
            gemPrice: 0,
            requiresSubscription: true,
            productID: nil,
            season: nil,
            gradientColors: ["#744210", "#1A202C"]
        ),
        CosmeticItem(
            id: "pack_halloween",
            name: "Noite das Bruxas",
            description: "Bigorna encantada, fogo roxo e loja assombrada. Não gasta minério.",
            emoji: "🎃",
            kind: .seasonalPack,
            gemPrice: 0,
            requiresSubscription: false,
            productID: StoreProductID.packHalloween,
            season: .halloween,
            gradientColors: ["#553C9A", "#DD6B20"]
        ),
        CosmeticItem(
            id: "pack_natal",
            name: "Inverno na Forja",
            description: "Fogo gélido, bigorna nevada e vitrine natalina.",
            emoji: "🎄",
            kind: .seasonalPack,
            gemPrice: 0,
            requiresSubscription: false,
            productID: StoreProductID.packNatal,
            season: .natal,
            gradientColors: ["#2B6CB0", "#9AE6B4"]
        )
    ]

    static func item(for id: String) -> CosmeticItem? {
        items.first { $0.id == id }
    }

    static var gemSkins: [CosmeticItem] {
        items.filter { $0.kind != .seasonalPack && $0.gemPrice > 0 }
    }

    static var subscriptionSkins: [CosmeticItem] {
        items.filter { $0.requiresSubscription }
    }

    static var seasonalPacks: [CosmeticItem] {
        items.filter { $0.kind == .seasonalPack }
    }

    static func ownedIDs(from pack: CosmeticItem) -> [String] {
        switch pack.season {
        case .halloween:
            return ["pack_halloween", "anvil_obsidian", "theme_royal"]
        case .natal:
            return ["pack_natal", "furnace_aurora"]
        case .none:
            return [pack.id]
        }
    }
}

struct ShopThemePalette {
    let backgroundHex: String
    let cardHex: String
    let accentHex: String

    static func palette(for themeID: String) -> ShopThemePalette {
        switch themeID {
        case "theme_royal":
            return ShopThemePalette(backgroundHex: "#1A1208", cardHex: "#3D2B12", accentHex: "#F6E05E")
        case "pack_halloween":
            return ShopThemePalette(backgroundHex: "#160C1C", cardHex: "#2D1B3D", accentHex: "#DD6B20")
        case "pack_natal":
            return ShopThemePalette(backgroundHex: "#0B1A24", cardHex: "#1A365D", accentHex: "#9AE6B4")
        default:
            return ShopThemePalette(backgroundHex: "#0D1117", cardHex: "#1A202C", accentHex: "#F6AD55")
        }
    }
}

struct FurnaceSkinPalette {
    let inner: [String]
    let mid: [String]
    let outer: [String]

    static func palette(for skinID: String) -> FurnaceSkinPalette {
        switch skinID {
        case "furnace_dragon":
            return FurnaceSkinPalette(
                inner: ["#9B2C2C", "#F56565", "#FED7D7"],
                mid: ["#742A2A", "#C53030", "#FC8181"],
                outer: ["#63171B", "#9B2C2C", "#F56565"]
            )
        case "furnace_aurora", "pack_natal":
            return FurnaceSkinPalette(
                inner: ["#2B6CB0", "#63B3ED", "#E9D8FD"],
                mid: ["#553C9A", "#9F7AEA", "#BEE3F8"],
                outer: ["#1A365D", "#6B46C1", "#90CDF4"]
            )
        case "pack_halloween":
            return FurnaceSkinPalette(
                inner: ["#6B46C1", "#DD6B20", "#FAF089"],
                mid: ["#44337A", "#C05621", "#F6AD55"],
                outer: ["#322659", "#9B2C2C", "#ED8936"]
            )
        default:
            return FurnaceSkinPalette(
                inner: ["#C05621", "#ED8936", "#FBD38D"],
                mid: ["#9B2C2C", "#DD6B20", "#F6AD55"],
                outer: ["#742A2A", "#C05621", "#ED8936"]
            )
        }
    }
}
