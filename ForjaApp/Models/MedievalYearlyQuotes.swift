//
//  MedievalYearlyQuotes.swift
//  ForjaApp
//

import Foundation

enum MedievalYearlyQuotes {
    static func battleCry(dayOfYear: Int) -> String {
        let cries = [
            "Quem forja não foge da batalha.",
            "A bigorna não se ajoelha ao inimigo.",
            "Conquista-se o reino um golpe de cada vez.",
            "O pântano prova o ferreiro; o ferreiro prova o aço.",
            "Levanta o martelo e o medo cai por terra.",
            "Não há coroa sem cicatriz na palma.",
            "A estrada de areia só respeita quem marcha.",
            "Hoje o lodo recua. Amanhã o castelo abre.",
            "Foco é escudo. Disciplina é espada.",
            "Quem apaga o fogo perde a guerra.",
            "A vitória mora no último segundo da forja.",
            "Nenhum dragão vence um ofício constante.",
            "O Umbrawolf late; o ferreiro não olha para trás.",
            "Conquistar é permanecer quando o carvão pede trégua.",
            "A glória não chega a quem troca a bigorna pelo descanso.",
            "Cada sessão é um cerco vencido.",
            "O minério é tributo pago à coragem.",
            "Em nome da forja: avançar, sempre avançar."
        ]
        return cries[safeIndex(dayOfYear, count: cries.count)]
    }

    static func dailyPhrase(dayOfYear: Int) -> String {
        phrases[safeIndex(dayOfYear, count: phrases.count)]
    }

    static func dayOfYear(from date: Date = Date()) -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    private static func safeIndex(_ dayOfYear: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (max(1, dayOfYear) - 1) % count
    }

    private static let phrases: [String] = makeYearPhrases()

    private static func makeYearPhrases() -> [String] {
        let places = [
            "No pântano sombrio",
            "Na estrada de areia e barro",
            "Sob as muralhas do castelo",
            "Na clareira do Cervo-Brasão",
            "Diante da bigorna acesa",
            "Entre tochas da sentinela",
            "No charco do Lodoento",
            "Na névoa do Corvo-de-Ferro",
            "À sombra do Grifo-do-Charco",
            "No lodaçal da Hidra",
            "Na trilha do Umbrawolf",
            "Perante o trono de minério",
            "No brejo do Wyrm",
            "Na oficina do mestre",
            "Sob a lua da ronda",
            "No portão da véspera",
            "Entre os sulcos da estrada real",
            "Na fornalha ainda quente"
        ]
        let deeds = [
            "o ferreiro ergue o martelo e recusa a fuga",
            "a coragem vale mais do que qualquer coroa",
            "quem permanece conquista o que o medo abandona",
            "o foco corta o inimigo melhor que a espada",
            "cada minuto forjado é território tomado",
            "a disciplina vence o dragão da distração",
            "não se rende quem ainda tem brasa na palma",
            "o ofício marcha quando as pernas já pedem trégua",
            "a vitória chega ao que não apaga o fogo",
            "o reino lembra os que voltaram à bigorna",
            "a conquista se mede em sessões, não em desculpas",
            "o aço nasceu de quem escolheu ficar",
            "a batalha do dia se ganha segundo a segundo",
            "o pântano recua diante de um juramento cumprido"
        ]
        let seals = [
            "Ergue-te e forja.",
            "Avança: o castelo ainda não caiu.",
            "Hoje o martelo fala mais alto.",
            "Não deixe a estrada sem pegada.",
            "A glória espera o próximo golpe.",
            "O minério só obedece ao destemido.",
            "Que o medo sirva de bigorna.",
            "A guerra do foco continua — e você vence."
        ]

        var lines: [String] = []
        lines.reserveCapacity(366)
        for index in 0..<366 {
            let place = places[index % places.count]
            let deed = deeds[(index / places.count) % deeds.count]
            let seal = seals[(index / (places.count * deeds.count)) % seals.count]
            lines.append("\(place), \(deed). \(seal)")
        }
        return lines
    }
}
