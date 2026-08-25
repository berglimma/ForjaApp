//
//  MedievalAvatar.swift
//  ForjaApp
//

import Foundation

struct MedievalAvatar: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let title: String
    let emoji: String
    let lore: String
    let accentHex: String

    var imageName: String { "Avatar_\(id)" }

    static let catalog: [MedievalAvatar] = [
        MedievalAvatar(
            id: "smith",
            name: "Aldric",
            title: "Mestre Ferreiro",
            emoji: "⚒️",
            lore: "Forja o próprio destino no calor da concentração.",
            accentHex: "#ED8936"
        ),
        MedievalAvatar(
            id: "knight",
            name: "Seren",
            title: "Cavaleira da Vigília",
            emoji: "🛡️",
            lore: "Protege o foco como um juramento sagrado.",
            accentHex: "#63B3ED"
        ),
        MedievalAvatar(
            id: "mage",
            name: "Lyra",
            title: "Feiticeira das Brasas",
            emoji: "🧙‍♀️",
            lore: "Transforma minutos em feitiços de produtividade.",
            accentHex: "#9F7AEA"
        ),
        MedievalAvatar(
            id: "archer",
            name: "Rowan",
            title: "Arqueiro do Horizonte",
            emoji: "🏹",
            lore: "Cada sessão é uma flecha certeira no alvo do dia.",
            accentHex: "#68D391"
        ),
        MedievalAvatar(
            id: "monk",
            name: "Kael",
            title: "Monge da Bigorna",
            emoji: "🧘",
            lore: "Silêncio, respiração e um fogo que não se apaga.",
            accentHex: "#F6E05E"
        ),
        MedievalAvatar(
            id: "barbarian",
            name: "Bruna",
            title: "Guardiã do Forno",
            emoji: "🪓",
            lore: "Quebra distrações com a força de uma fornalha.",
            accentHex: "#F56565"
        ),
        MedievalAvatar(
            id: "cavalier",
            name: "Alaric",
            title: "Cavaleiro da Brasa",
            emoji: "⚔️",
            lore: "Jura permanecer na sela até o último segundo da forja.",
            accentHex: "#90CDF4"
        ),
        MedievalAvatar(
            id: "wizard",
            name: "Eldrin",
            title: "Mago do Cristal",
            emoji: "🧙‍♂️",
            lore: "Conjura foco puro a partir do calor da bigorna.",
            accentHex: "#76E4F7"
        ),
        MedievalAvatar(
            id: "warlock",
            name: "Vesper",
            title: "Bruxo das Cinzas",
            emoji: "🔮",
            lore: "Pactua com o fogo: cada sessão alimenta um feitiço antigo.",
            accentHex: "#B794F4"
        ),
        MedievalAvatar(
            id: "paladin",
            name: "Isolde",
            title: "Paladina da Forja",
            emoji: "⚜️",
            lore: "Abençoa o minério e não deixa a chama vacilar.",
            accentHex: "#FAF089"
        ),
        MedievalAvatar(
            id: "druid",
            name: "Thorn",
            title: "Druida do Carvão",
            emoji: "🌿",
            lore: "Trata o tempo de foco como uma floresta que precisa crescer.",
            accentHex: "#48BB78"
        ),
        MedievalAvatar(
            id: "rogue",
            name: "Nyx",
            title: "Ladina da Fagulha",
            emoji: "🗡️",
            lore: "Rouba minutos das distrações e devolve em barras.",
            accentHex: "#A0AEC0"
        )
    ]

    static let `default` = catalog[0]

    static func avatar(for id: String) -> MedievalAvatar {
        catalog.first { $0.id == id } ?? .default
    }
}
