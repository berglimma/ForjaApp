//
//  ProfileAvatarView.swift
//  ForjaApp
//
//  Created by Berg Limma on 20/06/26.

import PhotosUI
import SwiftUI

struct ProfileAvatarView: View {
    let image: UIImage?
    let placeholderSystemName: String
    let onImageDataSelected: (Data) -> Void
    let onRemove: () -> Void

    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 6) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
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

            if image != nil {
                Button("Remover foto", role: .destructive) {
                    onRemove()
                }
                .font(.caption2)
            } else {
                Text("Adicionar foto")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    onImageDataSelected(data)
                }
                selectedItem = nil
            }
        }
    }

    @ViewBuilder
    private var avatarContent: some View {
        Group {
            if let image {
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

#Preview {
    ProfileAvatarView(
        image: nil,
        placeholderSystemName: "person.crop.circle.fill",
        onImageDataSelected: { _ in },
        onRemove: {}
    )
    .padding()
    .background(Color.black)
}
