//
//  OreChallengeLadder.swift
//  ForjaApp
//

import Foundation

struct OreChallenge: Identifiable, Equatable {
    let rank: Int
    let oreGate: Int
    let name: String
    let lore: String
    let creature: String
    let creatureEmoji: String
    let minFocusMinutes: Int
    let recommendedMinutes: Int
    let graceCap: Int
    let isSwamp: Bool

    var id: Int { rank }
    var isFinal: Bool { oreGate >= OreChallengeLadder.cap }
}

enum OreChallengeLadder {
    static let cap = 100_000

    static let milestones: [OreChallenge] = [
        named(
            rank: 1, gate: 100, minutes: 15, grace: 8, swamp: false,
            name: "Jornada da Areia",
            creature: "Lodoento", emoji: "🐸",
            lore: "Os primeiros 100 minérios abrem a estrada de areia. Forje 15 min para o reino reconhecer o ofício."
        ),
        named(
            rank: 2, gate: 1_000, minutes: 20, grace: 6, swamp: false,
            name: "Prova do Barro",
            creature: "Basilisco-Cinza", emoji: "🦎",
            lore: "Mil minérios no barro da forja. Sessões de 20 min firmam o passo até o pântano."
        ),
        named(
            rank: 3, gate: 10_000, minutes: 25, grace: 5, swamp: true,
            name: "Cerco do Pântano Sombrio",
            creature: "Grifo-do-Charco", emoji: "🦅",
            lore: "Dez mil minérios no charco. O Grifo-do-Charco só respeita forjas de 25 min."
        ),
        named(
            rank: 4, gate: 20_000, minutes: 25, grace: 4, swamp: true,
            name: "Guerra do Charco",
            creature: "Wyrm-de-Brejo", emoji: "🐉",
            lore: "Vinte mil. O Wyrm desperta no brejo — mantenha 25 min ou o lodo vence."
        ),
        named(
            rank: 5, gate: 30_000, minutes: 30, grace: 4, swamp: false,
            name: "Marcha do Cervo-Brasão",
            creature: "Cervo-Brasão", emoji: "🦌",
            lore: "Trinta mil na clareira. A marcha pede 30 min de brasa contínua."
        ),
        named(
            rank: 6, gate: 40_000, minutes: 35, grace: 3, swamp: false,
            name: "Vigília do Corvo-de-Ferro",
            creature: "Corvo-de-Ferro", emoji: "🐦‍⬛",
            lore: "Quarenta mil sob a névoa. O corvo marca quem forja 35 min sem olhar para o lado."
        ),
        named(
            rank: 7, gate: 50_000, minutes: 40, grace: 3, swamp: true,
            name: "Hidra das Cinco Correntes",
            creature: "Hidra-do-Lodo", emoji: "🐍",
            lore: "Meio caminho das cem mil. A Hidra cobra 40 min — uma cabeça para cada desculpa."
        ),
        named(
            rank: 8, gate: 60_000, minutes: 45, grace: 2, swamp: false,
            name: "Caçada do Umbrawolf",
            creature: "Umbrawolf", emoji: "🐺",
            lore: "Sessenta mil. O lobo do pântano só recua diante de 45 min de ofício."
        ),
        named(
            rank: 9, gate: 70_000, minutes: 45, grace: 2, swamp: true,
            name: "Serpe de Musgo",
            creature: "Serpe-Musgo", emoji: "🐲",
            lore: "Setenta mil enrolados no musgo. 45 min ou a serpe aperta o foco."
        ),
        named(
            rank: 10, gate: 80_000, minutes: 50, grace: 1, swamp: true,
            name: "Coração do Drake-Pântano",
            creature: "Drake-Pântano", emoji: "🐊",
            lore: "Oitenta mil. O drake pulsa lento: só 50 min aquecem o coração."
        ),
        named(
            rank: 11, gate: 90_000, minutes: 55, grace: 1, swamp: false,
            name: "Grito da Mandrágora-Vigia",
            creature: "Mandrágora-Vigia", emoji: "🌿",
            lore: "Noventa mil. A mandrágora grita se a forja for menor que 55 min."
        ),
        named(
            rank: 12, gate: 100_000, minutes: 60, grace: 0, swamp: false,
            name: "Coroa das Cem Mil Barras",
            creature: "Fagulhento", emoji: "🌟",
            lore: "O desafio final. Sessenta minutos de aço puro até a estrela das cem mil."
        )
    ]

    static var maxRank: Int { milestones.count }

    static func active(lifetimeBars: Int) -> OreChallenge {
        if lifetimeBars >= cap { return milestones[milestones.count - 1] }
        return milestones.first { lifetimeBars < $0.oreGate } ?? milestones[milestones.count - 1]
    }

    static func rank(lifetimeBars: Int) -> Int {
        active(lifetimeBars: lifetimeBars).rank
    }

    static func nextOreGate(lifetimeBars: Int) -> Int {
        active(lifetimeBars: lifetimeBars).oreGate
    }

    static func formatOre(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func challenge(rank: Int) -> OreChallenge {
        let clamped = min(maxRank, max(1, rank))
        return milestones[clamped - 1]
    }

    static func relic(rank: Int) -> ShopItem {
        let challenge = challenge(rank: rank)
        let rarity: ItemRarity
        switch challenge.oreGate {
        case ..<1_000: rarity = .comum
        case ..<10_000: rarity = .raro
        case ..<50_000: rarity = .epico
        default: rarity = .lendario
        }

        return ShopItem(
            id: relicID(oreGate: challenge.oreGate),
            name: "\(challenge.name)",
            description: "\(challenge.creatureEmoji) \(challenge.creature). \(challenge.lore)",
            emoji: challenge.creatureEmoji,
            price: challenge.oreGate,
            rarity: rarity,
            gradientColors: challenge.isSwamp
                ? ["#1A2F23", "#2F4F3A"]
                : ["#5C3A1E", "#C4A574"]
        )
    }

    static func relicID(oreGate: Int) -> String {
        "ore_mark_\(oreGate)"
    }

    static func relic(forItemID id: String) -> ShopItem? {
        guard id.hasPrefix("ore_mark_"),
              let ore = Int(id.replacingOccurrences(of: "ore_mark_", with: "")),
              milestones.contains(where: { $0.oreGate == ore })
        else { return nil }
        guard let challenge = milestones.first(where: { $0.oreGate == ore }) else { return nil }
        return relic(rank: challenge.rank)
    }

    static func visibleRelics(lifetimeBars: Int, ownedIDs: Set<String>) -> [ShopItem] {
        milestones
            .map { relic(rank: $0.rank) }
            .filter { !ownedIDs.contains($0.id) }
    }

    private static func named(
        rank: Int,
        gate: Int,
        minutes: Int,
        grace: Int,
        swamp: Bool,
        name: String,
        creature: String,
        emoji: String,
        lore: String
    ) -> OreChallenge {
        OreChallenge(
            rank: rank,
            oreGate: gate,
            name: name,
            lore: lore,
            creature: creature,
            creatureEmoji: emoji,
            minFocusMinutes: minutes,
            recommendedMinutes: min(90, minutes + 15),
            graceCap: grace,
            isSwamp: swamp
        )
    }
}
