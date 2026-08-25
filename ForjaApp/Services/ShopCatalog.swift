//
//  Shopcatalog.swift
//  ForjaApp
//
//  Created by Berg Limma on 14/06/26.

import Foundation

enum ShopCatalog {
    static let items: [ShopItem] = uniqueItems

    static func item(for id: String) -> ShopItem? {
        uniqueItems.first { $0.id == id } ?? OreChallengeLadder.relic(forItemID: id)
    }

    static func oficinaItems(lifetimeBars: Int, ownedIDs: Set<String>) -> [ShopItem] {
        uniqueItems + OreChallengeLadder.visibleRelics(lifetimeBars: lifetimeBars, ownedIDs: ownedIDs)
    }

    private static let uniqueItems: [ShopItem] = [
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
            id: "clay_mold",
            name: "Molde de Barro Crú",
            description: "Barro da estrada, pronto para receber o minério quente.",
            emoji: "🧱",
            price: 12,
            rarity: .comum,
            gradientColors: ["#7B341E", "#C4A574"]
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
            id: "sand_hourglass",
            name: "Ampulheta de Areia Real",
            description: "A areia da estrada mede cada minuto da forja.",
            emoji: "⏳",
            price: 18,
            rarity: .comum,
            gradientColors: ["#D4A574", "#8B5A2B"]
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
            id: "swamp_lantern",
            name: "Lanterna do Pântano",
            description: "Fica acesa mesmo no charco mais sombrio.",
            emoji: "🏮",
            price: 28,
            rarity: .raro,
            gradientColors: ["#1C3A2A", "#68D391"]
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
            id: "griffon_quill",
            name: "Pena do Grifo-do-Charco",
            description: "Assina pactos de foco. O grifo não perdoa atraso.",
            emoji: "🪶",
            price: 42,
            rarity: .raro,
            gradientColors: ["#2A4365", "#90CDF4"]
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
            id: "umbrawolf_pelt",
            name: "Manto do Umbrawolf",
            description: "Pele do lobo do pântano. Afasta distrações na névoa.",
            emoji: "🐺",
            price: 65,
            rarity: .epico,
            gradientColors: ["#1A202C", "#4A5568"]
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
        ),
        ShopItem(
            id: "lodoento_bell",
            name: "Sino do Lodoento",
            description: "O sapo-bruxo do charco avisa quando a forja esfria.",
            emoji: "🔔",
            price: 150,
            rarity: .raro,
            gradientColors: ["#22543D", "#9AE6B4"]
        ),
        ShopItem(
            id: "basilisk_scale",
            name: "Escama do Basilisco-Cinza",
            description: "Quem olha demais para o celular vira pedra. Literalmente.",
            emoji: "🦎",
            price: 220,
            rarity: .epico,
            gradientColors: ["#4A5568", "#A0AEC0"]
        ),
        ShopItem(
            id: "moss_serpent_ring",
            name: "Anel da Serpe-Musgo",
            description: "Enrolado no punho, cobra o próximo bloco de foco.",
            emoji: "💍",
            price: 350,
            rarity: .epico,
            gradientColors: ["#276749", "#48BB78"]
        ),
        ShopItem(
            id: "ember_stag_horn",
            name: "Chifre do Cervo-Brasão",
            description: "Brasa viva. Só acende para quem já cruzou 500 minérios.",
            emoji: "🦌",
            price: 500,
            rarity: .epico,
            gradientColors: ["#C05621", "#F6AD55"]
        ),
        ShopItem(
            id: "iron_raven_sigil",
            name: "Sinete do Corvo-de-Ferro",
            description: "O corvo marca cada sessão cumprida no livro do reino.",
            emoji: "🐦‍⬛",
            price: 750,
            rarity: .epico,
            gradientColors: ["#1A202C", "#718096"]
        ),
        ShopItem(
            id: "hydralode_vial",
            name: "Ampola da Hidra-do-Lodo",
            description: "Três cabeças, três blocos. Falhou um, as outras cobram.",
            emoji: "🧪",
            price: 1_200,
            rarity: .lendario,
            gradientColors: ["#234E52", "#38B2AC"]
        ),
        ShopItem(
            id: "swamp_drake_heart",
            name: "Coração do Drake-Pântano",
            description: "Pulso lento. Forjas curtas já não bastam.",
            emoji: "❤️‍🔥",
            price: 2_500,
            rarity: .lendario,
            gradientColors: ["#742A2A", "#E53E3E"]
        ),
        ShopItem(
            id: "wyrm_anvil",
            name: "Bigorna do Wyrm-de-Brejo",
            description: "A bigorna que o dragão do charco não conseguiu derreter.",
            emoji: "🐲",
            price: 5_000,
            rarity: .lendario,
            gradientColors: ["#322659", "#9F7AEA"]
        ),
        ShopItem(
            id: "mandragora_crown",
            name: "Coroa da Mandrágora-Vigia",
            description: "Grita se você sair do app. Os vizinhos que lutem.",
            emoji: "👑",
            price: 10_000,
            rarity: .lendario,
            gradientColors: ["#22543D", "#F6E05E"]
        ),
        ShopItem(
            id: "royal_sand_scepter",
            name: "Cetro de Areia Real",
            description: "Comanda a estrada. Só ferreiros de 25 mil minérios o empunham.",
            emoji: "🪄",
            price: 25_000,
            rarity: .lendario,
            gradientColors: ["#D4A574", "#B7791F"]
        ),
        ShopItem(
            id: "kingdom_ore_throne",
            name: "Trono de Minério",
            description: "O assento do ofício. 50 mil minérios de respeito.",
            emoji: "🪑",
            price: 50_000,
            rarity: .lendario,
            gradientColors: ["#2D3748", "#F6E05E"]
        ),
        ShopItem(
            id: "hundred_thousand_star",
            name: "Estrela das Cem Mil Barras",
            description: "O desafio final do reino. Quase ninguém chega aqui.",
            emoji: "🌟",
            price: 100_000,
            rarity: .lendario,
            gradientColors: ["#1A365D", "#F6E05E"]
        )
    ]
}
