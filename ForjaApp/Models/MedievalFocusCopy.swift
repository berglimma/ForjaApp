//
//  MedievalFocusCopy.swift
//  ForjaApp
//

import Foundation

enum MedievalFocusCopy {
    enum NoticeSlot: String, CaseIterable {
        case dawn
        case peak
        case highSun
        case swamp
        case vespers
        case nightWatch

        var identifier: String { "forja.\(rawValue)" }

        func hour(peakHour: Int) -> Int {
            switch self {
            case .dawn: return 7
            case .peak: return min(22, max(6, peakHour))
            case .highSun: return 12
            case .swamp: return 16
            case .vespers: return 19
            case .nightWatch: return 21
            }
        }

        var minute: Int {
            switch self {
            case .dawn: return 15
            case .peak: return 0
            case .highSun: return 20
            case .swamp: return 40
            case .vespers: return 30
            case .nightWatch: return 45
            }
        }
    }

    static func notification(slot: NoticeSlot, avatar: MedievalAvatar, salt: Int) -> (title: String, body: String) {
        let name = avatar.name
        let title = avatar.title
        let pool: [(String, String)]
        switch slot {
        case .dawn:
            pool = [
                ("O galo do charco cantou", "\(name), a fornalha ainda está fria. Acenda o fogo antes que o Lodoento acorde no pântano."),
                ("Alvorada na estrada de areia", "A névoa baixa sobre o barro. \(title) \(name), o reino espera a primeira forja do dia."),
                ("Tocha da sentinela", "As muralhas clareiam. Uma sessão agora vale mais do que três depois do meio-dia.")
            ]
        case .peak:
            pool = [
                ("Seu horário de ofício", "\(name), a bigorna está quente neste horário. O minério rende mais quando o pulso está firme."),
                ("O sino da forja", "Esse costuma ser o pico de \(name). Entre na oficina antes que o carvão esfrie."),
                ("Brasa no ponto", "\(title), o fogo está no ponto certo. Uma forja agora segura a sequência.")
            ]
        case .highSun:
            pool = [
                ("Sol na estrada de areia", "O chão queima e o Umbrawolf busca sombra. \(name), forje agora — o pântano espera a tarde."),
                ("Poço do meio-dia", "Viajantes param no barro quente. Uma sessão curta ainda conta como juramento."),
                ("Grifo-do-Charco no céu", "A sombra do grifo cruzou a oficina. \(name), não deixe a bigorna sozinha.")
            ]
        case .swamp:
            pool = [
                ("O pântano sombrio chamou", "Lanternas se apagam no charco. \(name), o Lodoento canta — volte à forja e afaste o lodo."),
                ("Hidra-do-Lodo à espreita", "Três cabeças, três desculpas. Nenhuma delas forja minério. \(title), volte à bigorna."),
                ("Névoa do Corvo-de-Ferro", "O corvo pousou na ampulheta. Se a areia cair sem você, o ofício esfria.")
            ]
        case .vespers:
            pool = [
                ("A fornalha está esfriando", "O minério escurece sem o martelo. \(name), uma última forja antes do castelo fechar as portas."),
                ("Véspera no reino", "Tochas acendem nas muralhas. \(title) ainda pode cumprir a meta do dia."),
                ("Carvão quase cinza", "O Drake-Pântano adormece cedo. Forje agora ou o dia vira só fumaça.")
            ]
        case .nightWatch:
            pool = [
                ("Ronda da noite", "A sentinela pergunta por \(name). O pântano está quieto demais — isso nunca é bom."),
                ("Cervo-Brasão na clareira", "A brasa do cervo ainda brilha. Uma sessão noturna salva a sequência."),
                ("O castelo apagou as luzes", "Quase ninguém forja agora. Quase. \(title) \(name), o ofício não dorme se você não deixar.")
            ]
        }
        return pool[abs(salt + slot.hashValue) % pool.count]
    }

    static func forgeIdleSubtitle(avatar: MedievalAvatar, challengeName: String) -> String {
        let lines = [
            "\(avatar.name) na \(challengeName.lowercased()). Mantenha o foco e forje.",
            "A estrada de areia espera \(avatar.name). Acenda o forno.",
            "\(avatar.title): o pântano não perdoa ferreiro distraído.",
            "Bigorna pronta. \(avatar.name), o minério só nasce de foco."
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return lines[day % lines.count]
    }

    static func forgingLine(avatar: MedievalAvatar) -> String {
        let lines = [
            "\(avatar.name) golpeia a face da bigorna. Não saia do reino.",
            "O fogo está no ponto. \(avatar.title) não abandona a forja.",
            "Faíscas no metal. O Umbrawolf observa da estrada — continue."
        ]
        let minute = Calendar.current.component(.minute, from: Date())
        return lines[minute % lines.count]
    }

    static func liveActivityTitle(avatar: MedievalAvatar) -> String {
        "\(avatar.name) na forja"
    }

    static func practiceActivityTitle(avatar: MedievalAvatar) -> String {
        "\(avatar.name) em treino"
    }

    static func successTitle(avatar: MedievalAvatar) -> String {
        "\(avatar.name) concluiu a forja"
    }

    static func practiceSuccessTitle(avatar: MedievalAvatar) -> String {
        "Treino de \(avatar.name)"
    }

    static func successMessage(avatar: MedievalAvatar, bars: Int) -> String {
        "O minério está na bolsa. \(avatar.title) atravessou a estrada de areia e o pântano sem apagar o fogo. +\(bars) ao ofício."
    }

    static func practiceSuccessMessage(avatar: MedievalAvatar, bars: Int) -> String {
        "Foco cumprido. \(avatar.name) ganha \(bars) minério, mas a sessão curta não entra no desafio da estrada nem no ofício das 100 mil barras."
    }

    static func failureTitle(reason: ForgeFailureReason) -> String {
        switch reason {
        case .leftApp: return "O fogo apagou no pântano"
        case .cancelled: return "A forja foi abandonada"
        }
    }

    static func failureMessage(avatar: MedievalAvatar, reason: ForgeFailureReason) -> String {
        switch reason {
        case .leftApp:
            return "\(avatar.name) saiu do reino e o Lodoento cobriu a brasa. O minério voltou ao estado bruto."
        case .cancelled:
            return "\(avatar.title) baixou o martelo cedo demais. A estrada de barro continua, mas esta barra se perdeu."
        }
    }

    static func blockedTooShort(challengeName: String, minutes: Int) -> String {
        "Desafio \(challengeName): a estrada exige pelo menos \(minutes) min. O pântano não aceita forjas curtas."
    }
}
