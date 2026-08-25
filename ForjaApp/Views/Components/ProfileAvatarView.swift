//
//  ProfileAvatarView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import PhotosUI
import SwiftUI
import UIKit

struct MedievalAvatarFaceView: View {
    let imageName: String
    var size: CGFloat = 52
    var lineWidth: CGFloat = 2
    var accentHex: String? = nil

    init(avatar: MedievalAvatar, size: CGFloat = 52, lineWidth: CGFloat = 2) {
        self.imageName = avatar.imageName
        self.size = size
        self.lineWidth = lineWidth
        self.accentHex = avatar.accentHex
    }

    init(imageName: String, size: CGFloat = 52, lineWidth: CGFloat = 2, accentHex: String? = nil) {
        self.imageName = imageName
        self.size = size
        self.lineWidth = lineWidth
        self.accentHex = accentHex
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .renderingMode(.original)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
            .clipShape(Circle())
            .overlay {
                if let accentHex {
                    Circle().stroke(Color(hex: accentHex) ?? .orange, lineWidth: lineWidth)
                }
            }
    }
}

struct ProfileAvatarView: View {
    let image: UIImage?
    let placeholderSystemName: String
    let avatarImageName: String
    let usesAvatar: Bool
    let onImageDataSelected: (Data) -> Void
    let onUseAvatar: () -> Void
    let onRemove: () -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var showSourceDialog = false
    @State private var showCamera = false
    @State private var showPhotosPicker = false

    var body: some View {
        VStack(spacing: 6) {
            Button { showSourceDialog = true } label: {
                ZStack(alignment: .bottomTrailing) {
                    avatarContent

                    Image(systemName: "camera.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(7)
                        .background(Color(hex: "#C05621") ?? .orange, in: Circle())
                        .overlay(Circle().stroke(Color(hex: "#0D1117") ?? .black, lineWidth: 2))
                        .offset(x: 4, y: 4)
                }
            }
            .buttonStyle(.plain)

            Text(usesAvatar ? "Avatar medieval" : (image == nil ? "Adicionar foto" : "Foto da galeria"))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .confirmationDialog("Foto de perfil", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("Usar avatar medieval") { onUseAvatar() }
            Button("Escolher da galeria") { showPhotosPicker = true }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Tirar foto") { showCamera = true }
            }
            if image != nil && !usesAvatar {
                Button("Remover foto", role: .destructive) { onRemove() }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    onImageDataSelected(data)
                }
                selectedItem = nil
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                if let data = image.jpegData(compressionQuality: 0.85) {
                    onImageDataSelected(data)
                }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var avatarContent: some View {
        Group {
            if usesAvatar {
                Image(avatarImageName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFill()
            } else if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: placeholderSystemName)
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "#F6AD55") ?? .orange)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.08))
            }
        }
        .frame(width: 68, height: 68)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(Color(hex: "#F6AD55") ?? .orange, lineWidth: 2)
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let image {
                parent.onImage(image)
            }
            parent.dismiss()
        }
    }
}

#Preview {
    ProfileAvatarView(
        image: nil,
        placeholderSystemName: "person.crop.circle.fill",
        avatarImageName: "Avatar_smith",
        usesAvatar: true,
        onImageDataSelected: { _ in },
        onUseAvatar: {},
        onRemove: {}
    )
    .padding()
    .background(Color.black)
}
