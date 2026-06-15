import UIKit

final class ProfileImageStore {
    static let shared = ProfileImageStore()

    private let fileName = "profile_avatar.jpg"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    private init() {}

    func load() -> UIImage? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    func save(_ image: UIImage) {
        let resized = image.resizedForAvatar(maxDimension: 512)
        guard let data = resized.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    func delete() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}

private extension UIImage {
    func resizedForAvatar(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
