//
//  AvatarLook.swift
//  ForjaApp
//

import Foundation
import SwiftUI

struct AvatarLook: Codable, Equatable, Hashable {
    var physiqueID: String
    var skinID: String
    var hairID: String
    var hairColorID: String
    var beardID: String
    var chestID: String
    var legsID: String
    var cloakID: String
    var headwearID: String
    var bootsID: String

    static let `default` = AvatarLook(
        physiqueID: AvatarStudioCatalog.physiques[0].id,
        skinID: AvatarStudioCatalog.skins[1].id,
        hairID: AvatarStudioCatalog.hairs[0].id,
        hairColorID: AvatarStudioCatalog.hairColors[0].id,
        beardID: AvatarStudioCatalog.beards[0].id,
        chestID: AvatarStudioCatalog.chests[1].id,
        legsID: AvatarStudioCatalog.legs[0].id,
        cloakID: AvatarStudioCatalog.cloaks[0].id,
        headwearID: AvatarStudioCatalog.headwear[0].id,
        bootsID: AvatarStudioCatalog.boots[0].id
    )

    static func seeded(from avatar: MedievalAvatar) -> AvatarLook {
        var look = AvatarLook.default
        switch avatar.id {
        case "smith", "barbarian":
            look.chestID = "leather"
            look.legsID = "trousers"
            look.beardID = avatar.id == "smith" ? "full" : "none"
        case "knight", "paladin", "cavalier":
            look.chestID = "plate"
            look.legsID = "mail"
            look.headwearID = avatar.id == "knight" ? "helm" : "none"
            look.cloakID = avatar.id == "paladin" ? "royal" : "wool"
        case "mage", "wizard", "warlock", "monk":
            look.chestID = "robe"
            look.legsID = "trousers"
            look.cloakID = "wool"
            look.hairID = avatar.id == "mage" ? "long" : "short"
            look.physiqueID = (avatar.id == "mage") ? "feminine" : "masculine"
        case "archer", "rogue", "druid":
            look.chestID = "leather"
            look.cloakID = avatar.id == "druid" ? "wool" : "none"
            look.hairID = avatar.id == "rogue" ? "braids" : "short"
            look.physiqueID = (avatar.id == "rogue") ? "feminine" : "masculine"
        default:
            break
        }
        return look
    }
}

struct AvatarStudioPiece: Identifiable, Hashable {
    let id: String
    let name: String
    let imageName: String?
    let accentHex: String
}

enum AvatarStudioCatalog {
    static let physiques: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "masculine", name: "Masculino", imageName: "StudioBody_masc", accentHex: "#C05621"),
        AvatarStudioPiece(id: "feminine", name: "Feminino", imageName: "StudioBody_fem", accentHex: "#B7791F")
    ]

    static let skins: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "pale", name: "Clara", imageName: nil, accentHex: "#F6E0C8"),
        AvatarStudioPiece(id: "tan", name: "Morena", imageName: nil, accentHex: "#C68642"),
        AvatarStudioPiece(id: "olive", name: "Azeitona", imageName: nil, accentHex: "#8D5524"),
        AvatarStudioPiece(id: "deep", name: "Escura", imageName: nil, accentHex: "#4A2C1A")
    ]

    static let hairs: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "short", name: "Curto", imageName: "StudioHair_short", accentHex: "#2D2416"),
        AvatarStudioPiece(id: "long", name: "Longo", imageName: "StudioHair_long", accentHex: "#744210"),
        AvatarStudioPiece(id: "braids", name: "Tranças", imageName: "StudioHair_braids", accentHex: "#1A1208")
    ]

    static let hairColors: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "ash", name: "Cinza-forja", imageName: nil, accentHex: "#A0AEC0"),
        AvatarStudioPiece(id: "brown", name: "Castanho", imageName: nil, accentHex: "#5C3317"),
        AvatarStudioPiece(id: "black", name: "Ébano", imageName: nil, accentHex: "#1A202C"),
        AvatarStudioPiece(id: "copper", name: "Cobre", imageName: nil, accentHex: "#C05621"),
        AvatarStudioPiece(id: "gold", name: "Trigo", imageName: nil, accentHex: "#D69E2E")
    ]

    static let beards: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "none", name: "Rosto limpo", imageName: nil, accentHex: "#A0AEC0"),
        AvatarStudioPiece(id: "full", name: "Barba de ofício", imageName: "StudioBeard_full", accentHex: "#2D2416")
    ]

    static let chests: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "linen", name: "Túnica de linho", imageName: "StudioChest_linen", accentHex: "#E2D3B3"),
        AvatarStudioPiece(id: "leather", name: "Gibão de couro", imageName: "StudioChest_leather", accentHex: "#8B5A2B"),
        AvatarStudioPiece(id: "mail", name: "Cota de malha", imageName: "StudioChest_mail", accentHex: "#A0AEC0"),
        AvatarStudioPiece(id: "plate", name: "Peitoral de placas", imageName: "StudioChest_plate", accentHex: "#CBD5E0"),
        AvatarStudioPiece(id: "robe", name: "Manto da brasa", imageName: "StudioChest_robe", accentHex: "#553C9A")
    ]

    static let legs: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "trousers", name: "Calças de lã", imageName: "StudioLegs_trousers", accentHex: "#4A3728"),
        AvatarStudioPiece(id: "mail", name: "Grevas e malha", imageName: "StudioLegs_mail", accentHex: "#A0AEC0")
    ]

    static let cloaks: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "none", name: "Sem capa", imageName: nil, accentHex: "#4A5568"),
        AvatarStudioPiece(id: "wool", name: "Capa de lã", imageName: "StudioCloak_drape", accentHex: "#2B6CB0"),
        AvatarStudioPiece(id: "royal", name: "Manto real", imageName: "StudioCloak_drape", accentHex: "#B7791F")
    ]

    static let headwear: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "none", name: "Cabeça nua", imageName: nil, accentHex: "#A0AEC0"),
        AvatarStudioPiece(id: "hood", name: "Capuz de viajante", imageName: "StudioHead_hood", accentHex: "#4A3728"),
        AvatarStudioPiece(id: "helm", name: "Elmo da vigília", imageName: "StudioHead_helm", accentHex: "#CBD5E0")
    ]

    static let boots: [AvatarStudioPiece] = [
        AvatarStudioPiece(id: "leather", name: "Botas de couro", imageName: "StudioBoots_leather", accentHex: "#5C3317"),
        AvatarStudioPiece(id: "plate", name: "Escarpes", imageName: "StudioBoots_plate", accentHex: "#A0AEC0")
    ]

    static func physique(_ id: String) -> AvatarStudioPiece {
        physiques.first { $0.id == id } ?? physiques[0]
    }

    static func skin(_ id: String) -> AvatarStudioPiece {
        skins.first { $0.id == id } ?? skins[1]
    }

    static func hair(_ id: String) -> AvatarStudioPiece {
        hairs.first { $0.id == id } ?? hairs[0]
    }

    static func hairColor(_ id: String) -> AvatarStudioPiece {
        hairColors.first { $0.id == id } ?? hairColors[0]
    }

    static func beard(_ id: String) -> AvatarStudioPiece {
        beards.first { $0.id == id } ?? beards[0]
    }

    static func chest(_ id: String) -> AvatarStudioPiece {
        chests.first { $0.id == id } ?? chests[0]
    }

    static func legs(_ id: String) -> AvatarStudioPiece {
        legs.first { $0.id == id } ?? legs[0]
    }

    static func cloak(_ id: String) -> AvatarStudioPiece {
        cloaks.first { $0.id == id } ?? cloaks[0]
    }

    static func headwear(_ id: String) -> AvatarStudioPiece {
        headwear.first { $0.id == id } ?? headwear[0]
    }

    static func boots(_ id: String) -> AvatarStudioPiece {
        boots.first { $0.id == id } ?? boots[0]
    }

    static func skinTint(_ id: String) -> Color {
        Color(hex: skin(id).accentHex) ?? .orange
    }

    static func hairTint(_ id: String) -> Color {
        Color(hex: hairColor(id).accentHex) ?? .brown
    }

    static func previewImageName(for piece: AvatarStudioPiece, look: AvatarLook) -> String? {
        if chests.contains(where: { $0.id == piece.id }) {
            var probe = look
            probe.chestID = piece.id
            return chestImageName(for: probe)
        }
        return piece.imageName
    }

    static func bodyImageName(for look: AvatarLook) -> String {
        look.physiqueID == "feminine" ? "StudioBody_fem" : "StudioBody_masc"
    }

    static func chestImageName(for look: AvatarLook) -> String? {
        let feminine = look.physiqueID == "feminine"
        switch look.chestID {
        case "linen":
            return feminine ? "StudioOutfit_fem_linen" : "StudioOutfit_masc_linen"
        case "leather":
            return feminine ? "StudioChest_leather_fem" : "StudioOutfit_masc_leather"
        case "mail":
            return feminine ? "StudioOutfit_fem_mail" : "StudioOutfit_masc_mail"
        case "plate":
            return feminine ? "StudioChest_plate_fem" : "StudioOutfit_masc_plate"
        case "robe":
            return feminine ? "StudioChest_robe_fem" : "StudioOutfit_masc_robe"
        default:
            return feminine ? "StudioChest_leather_fem" : "StudioOutfit_masc_leather"
        }
    }

    static func legsImageName(for look: AvatarLook) -> String? {
        if look.physiqueID == "feminine" { return nil }
        if look.chestID == "plate" || look.chestID == "robe" { return nil }
        if look.bootsID == "plate" || look.legsID == "mail" {
            return "StudioLegs_mail"
        }
        if look.legsID == "trousers", look.chestID == "linen" {
            return "StudioLegs_trousers"
        }
        return nil
    }

    static func cloakImageName(for look: AvatarLook) -> String? {
        guard look.cloakID != "none" else { return nil }
        if look.physiqueID == "masculine", look.chestID == "leather" {
            return "StudioCloak_wool"
        }
        return nil
    }

    static func shouldOverlayHair(for look: AvatarLook) -> Bool {
        if look.physiqueID == "masculine", look.hairID == "short" { return false }
        if look.physiqueID == "feminine", look.hairID == "long" { return false }
        return hair(look.hairID).imageName != nil
    }
}
