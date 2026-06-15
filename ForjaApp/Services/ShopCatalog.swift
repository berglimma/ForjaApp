//
//  Shopcatalog.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Foundation

enum ShopCatalog {
    static let items: [ShopItem] = [
        ShopItem(
            id: "spark_hammer",
            name: "Martelo das Faíscas",
            description: "Um martelo que brilha a cada golpe na bigorna.",
            emoji: "🔨",
            price: 5,
            rarity: .comum,
            gradientColors: ["#4A5568", "#718096"]
        ),
        ShopItem(
            id: "coal_pouch",
            name: "Bolsa de Carvão Vivo",
            description: "Carvão que nunca esfria completamente.",
            emoji: "🪨",
            price: 8,
            rarity: .comum,
            gradientColors: ["#2D3748", "#4A5568"]
        ),
        ShopItem(
            id: "iron_shield",
            name: "Escudo de Ferro",
            description: "Protege sua concentração contra distrações.",
            emoji: "🛡️",
            price: 15,
            rarity: .raro,
            gradientColors: ["#2B6CB0", "#4299E1"]
        ),
        ShopItem(
            id: "molten_gloves",
            name: "Luvas Fundidas",
            description: "Forjadas no calor extremo da fornalha.",
            emoji: "🧤",
            price: 20,
            rarity: .raro,
            gradientColors: ["#C05621", "#ED8936"]
        ),
        ShopItem(
            id: "anvil_spirit",
            name: "Espírito da Bigorna",
            description: "Um guardião ancestral do ofício.",
            emoji: "⚒️",
            price: 35,
            rarity: .epico,
            gradientColors: ["#6B46C1", "#9F7AEA"]
        ),
        ShopItem(
            id: "dragon_furnace",
            name: "Fornalha do Dragão",
            description: "Chamas eternas de uma criatura mítica.",
            emoji: "🐉",
            price: 50,
            rarity: .epico,
            gradientColors: ["#9B2C2C", "#F56565"]
        ),
        ShopItem(
            id: "master_crown",
            name: "Coroa do Mestre Ferreiro",
            description: "O símbolo supremo de quem domina o foco.",
            emoji: "👑",
            price: 80,
            rarity: .lendario,
            gradientColors: ["#B7791F", "#F6E05E"]
        ),
        ShopItem(
            id: "star_ingot",
            name: "Barra Estelar",
            description: "Metal raro caído do céu noturno.",
            emoji: "⭐",
            price: 100,
            rarity: .lendario,
            gradientColors: ["#1A365D", "#63B3ED"]
        )
    ]

    static func item(for id: String) -> ShopItem? {
        items.first { $0.id == id }
    }
}
