//
//  OreChallengeLadder.swift
//  ForjaApp
//

import Foundation

struct OreChallenge: Identifiable, Equatable {
    let rank: Int
    let name: String
    let lore: String
    let creature: String
    let creatureEmoji: String
    let minFocusMinutes: Int
    let recommendedMinutes: Int
    let graceCap: Int
    let rewardMultiplier: Double
    let isSwamp: Bool

    var id: Int { rank }
    var oreGate: Int { rank * OreChallengeLadder.step }
    var isFinal: Bool { rank >= OreChallengeLadder.maxRank }
}

enum OreChallengeLadder {
    static let step = 100
    static let cap = 100_000
    static var maxRank: Int { cap / step }

    static func rank(lifetimeBars: Int) -> Int {
        min(maxRank, max(0, lifetimeBars / step))
    }

    static func nextOreGate(lifetimeBars: Int) -> Int {
        min(cap, (rank(lifetimeBars: lifetimeBars) + 1) * step)
    }

    static func active(lifetimeBars: Int) -> OreChallenge {
        challenge(rank: max(1, rank(lifetimeBars: lifetimeBars)))
    }

    static func challenge(rank: Int) -> OreChallenge {
        let clamped = min(maxRank, max(1, rank))
        let minMinutes = min(90, 15 + clamped / 12)
        let recommended = min(120, minMinutes + 10 + clamped / 40)
        let grace = max(0, 8 - clamped / 80)
        let multiplier = max(0.35, 1.0 - Double(clamped) / 1_400.0)
        let swamp = clamped.isMultiple(of: 3) || clamped % 7 == 0

        return OreChallenge(
            rank: clamped,
            name: title(for: clamped),
            lore: lore(for: clamped, swamp: swamp),
            creature: creature(for: clamped).name,
            creatureEmoji: creature(for: clamped).emoji,
            minFocusMinutes: minMinutes,
            recommendedMinutes: recommended,
            graceCap: grace,
            rewardMultiplier: multiplier,
            isSwamp: swamp
        )
    }

    static func adjustedReward(base: Int, durationSeconds: Int, lifetimeBars: Int) -> Int {
        let challenge = active(lifetimeBars: lifetimeBars)
        let minutes = durationSeconds / 60
        guard minutes >= challenge.minFocusMinutes else { return 0 }
        var value = Double(base) * challenge.rewardMultiplier
        if minutes < challenge.recommendedMinutes {
            value *= 0.55
        }
        return max(1, Int(value.rounded(.down)))
    }

    static func relic(rank: Int) -> ShopItem {
        let challenge = challenge(rank: rank)
        let rarity: ItemRarity
        switch challenge.oreGate {
        case ..<500: rarity = .comum
        case ..<2_500: rarity = .raro
        case ..<15_000: rarity = .epico
        default: rarity = .lendario
        }

        return ShopItem(
            id: relicID(rank: rank),
            name: "\(challenge.creature) · Marco \(challenge.oreGate)",
            description: "Selo do desafio \(challenge.name). Exige \(challenge.minFocusMinutes) min de forja.",
            emoji: challenge.creatureEmoji,
            price: challenge.oreGate,
            rarity: rarity,
            gradientColors: challenge.isSwamp
                ? ["#1A2F23", "#2F4F3A"]
                : ["#5C3A1E", "#C4A574"]
        )
    }

    static func relicID(rank: Int) -> String {
        "ore_mark_\(rank * step)"
    }

    static func relic(forItemID id: String) -> ShopItem? {
        guard id.hasPrefix("ore_mark_"),
              let ore = Int(id.replacingOccurrences(of: "ore_mark_", with: "")),
              ore.isMultiple(of: step),
              ore > 0,
              ore <= cap
        else { return nil }
        return relic(rank: ore / step)
    }

    static func visibleRelics(lifetimeBars: Int, ownedIDs: Set<String>) -> [ShopItem] {
        let start = max(1, rank(lifetimeBars: lifetimeBars))
        var relics: [ShopItem] = []
        var current = start
        while relics.count < 8 && current <= maxRank {
            let item = relic(rank: current)
            if !ownedIDs.contains(item.id) {
                relics.append(item)
            }
            current += 1
        }
        return relics
    }

    private static let titles = [
        "Estrada de Areia",
        "Barro da Forja",
        "Pântano Sombrio",
        "Charco do Lodoento",
        "Trilha do Grifo",
        "Brejo do Wyrm",
        "Clareira do Cervo-Brasão",
        "Névoa do Corvo-de-Ferro",
        "Lodaçal da Hidra",
        "Caminho do Umbrawolf",
        "Serpe de Musgo",
        "Fagulha do Drake-Pântano"
    ]

    private static let creatures: [(name: String, emoji: String)] = [
        ("Lodoento", "🐸"),
        ("Basilisco-Cinza", "🦎"),
        ("Grifo-do-Charco", "🦅"),
        ("Wyrm-de-Brejo", "🐉"),
        ("Cervo-Brasão", "🦌"),
        ("Corvo-de-Ferro", "🐦‍⬛"),
        ("Hidra-do-Lodo", "🐍"),
        ("Umbrawolf", "🐺"),
        ("Serpe-Musgo", "🐲"),
        ("Mandrágora-Vigia", "🌿"),
        ("Drake-Pântano", "🐊"),
        ("Fagulhento", "🔥")
    ]

    private static func title(for rank: Int) -> String {
        titles[(rank - 1) % titles.count]
    }

    private static func creature(for rank: Int) -> (name: String, emoji: String) {
        creatures[(rank - 1) % creatures.count]
    }

    private static func lore(for rank: Int, swamp: Bool) -> String {
        let minMinutes = min(90, 15 + rank / 12)
        if swamp {
            return "O pântano sombrio engole o desatento. Forje pelo menos \(minMinutes) min ou o lodo apaga a fornalha."
        }
        return "A estrada de areia e barro exige ofício firme. Cada 100 minérios endurece o reino até 100.000."
    }
}
