//
//  VoucherCatalog.swift
//  ForjaApp
//

import Foundation

enum VoucherCatalog {
    static let fullAccessCodes: Set<String> = [
        "FORJA-XGX3-TTUW",
        "FORJA-5NL2-DP3T",
        "FORJA-72XG-5QMF",
        "FORJA-5APP-GQR7",
        "FORJA-G9KK-LZBZ",
        "FORJA-RVJN-4LZM",
        "FORJA-6YLE-FB88",
        "FORJA-7MMA-V5FE",
        "FORJA-MYDN-68S4",
        "FORJA-QP2T-J5DA",
        "FORJA-DAV8-FCNR",
        "FORJA-U33J-FD5V",
        "FORJA-ZZ7T-E5Y4",
        "FORJA-F4T9-DVDZ",
        "FORJA-MNQT-SWNZ",
        "FORJA-WGEH-N468",
        "FORJA-F5UH-QV2C",
        "FORJA-UJEU-TN7E",
        "FORJA-SGGP-T97L",
        "FORJA-P8MA-FGD4",
        "FORJA-4NGV-RGC4",
        "FORJA-734Y-ZTGP",
        "FORJA-CCGC-39TP",
        "FORJA-RG6R-LAED",
        "FORJA-SWZL-5EFP",
        "FORJA-357P-5J4L",
        "FORJA-WHN6-RK4F",
        "FORJA-LB8C-LVE8",
        "FORJA-BV6Y-SQW9",
        "FORJA-6Q2R-N3AN"
    ]

    static func normalize(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")
    }

    static func isFullAccess(_ raw: String) -> Bool {
        fullAccessCodes.contains(normalize(raw))
    }
}

enum VoucherRedeemError: LocalizedError {
    case invalid
    case alreadyUnlocked
    case alreadyUsed

    var errorDescription: String? {
        switch self {
        case .invalid:
            return "Este código não é válido."
        case .alreadyUnlocked:
            return "Esta conta já tem o conteúdo completo."
        case .alreadyUsed:
            return "Este voucher já foi resgatado."
        }
    }
}
