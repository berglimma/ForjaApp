//
//  SocialStoryShare.swift
//  ForjaApp
//

import UIKit

enum SocialStoryShare {
    enum Destination: String, Identifiable {
        case system
        case instagramStories
        case whatsAppStatus

        var id: String { rawValue }
    }

    enum ShareError: LocalizedError {
        case instagramMissing
        case whatsAppMissing
        case imageFailed

        var errorDescription: String? {
            switch self {
            case .instagramMissing:
                return "Instale o Instagram para postar nos Stories."
            case .whatsAppMissing:
                return "Instale o WhatsApp para postar no Status."
            case .imageFailed:
                return "Não foi possível preparar o pergaminho."
            }
        }
    }

    static var canOpenInstagramStories: Bool {
        URL(string: "instagram-stories://share").map { UIApplication.shared.canOpenURL($0) } ?? false
    }

    static var canOpenWhatsApp: Bool {
        URL(string: "whatsapp://").map { UIApplication.shared.canOpenURL($0) } ?? false
    }

    static func shareToInstagramStories(_ image: UIImage) throws {
        guard canOpenInstagramStories else { throw ShareError.instagramMissing }
        guard let png = image.pngData() else { throw ShareError.imageFailed }

        let pasteboardItems: [[String: Any]] = [[
            "com.instagram.sharedSticker.backgroundImage": png,
            "com.instagram.sharedSticker.backgroundTopColor": "#1A1208",
            "com.instagram.sharedSticker.backgroundBottomColor": "#C05621"
        ]]
        UIPasteboard.general.setItems(
            pasteboardItems,
            options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
        )

        let appID = Bundle.main.bundleIdentifier ?? "com.lindenbergbrito.forja"
        guard let url = URL(string: "instagram-stories://share?source_application=\(appID)") else {
            throw ShareError.imageFailed
        }
        UIApplication.shared.open(url)
    }

    static func temporaryJPEGURL(for image: UIImage) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.92) else {
            throw ShareError.imageFailed
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("forja-pergaminho-\(UUID().uuidString).jpg")
        try data.write(to: url, options: .atomic)
        return url
    }
}
