//
//  AvatarStudioView.swift
//  ForjaApp
//

import SwiftUI

struct AvatarStudioView: View {
    @EnvironmentObject private var inventory: InventoryManager
    @Environment(\.dismiss) private var dismiss

    @State private var look: AvatarLook
    @State private var section: StudioSection = .body

    enum StudioSection: String, CaseIterable, Identifiable {
        case body
        case vestments

        var id: String { rawValue }

        var title: String {
            switch self {
            case .body: return "Corpo"
            case .vestments: return "Vestimentas"
            }
        }
    }

    init(look: AvatarLook) {
        _look = State(initialValue: look)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                preview
                    .padding(.top, 8)

                Picker("Seção", selection: $section) {
                    ForEach(StudioSection.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)

                Picker("Sexo", selection: $look.physiqueID) {
                    Text("Masculino").tag("masculine")
                    Text("Feminino").tag("feminine")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        switch section {
                        case .body:
                            pieceRow("Pele", pieces: AvatarStudioCatalog.skins, selection: $look.skinID)
                            pieceRow("Cabelo", pieces: AvatarStudioCatalog.hairs, selection: $look.hairID)
                            pieceRow("Cor do cabelo", pieces: AvatarStudioCatalog.hairColors, selection: $look.hairColorID)
                            pieceRow("Barba", pieces: AvatarStudioCatalog.beards, selection: $look.beardID)
                        case .vestments:
                            pieceRow("Peito", pieces: AvatarStudioCatalog.chests, selection: $look.chestID)
                            pieceRow("Pernas", pieces: AvatarStudioCatalog.legs, selection: $look.legsID)
                            pieceRow("Capa", pieces: AvatarStudioCatalog.cloaks, selection: $look.cloakID)
                            pieceRow("Cabeça", pieces: AvatarStudioCatalog.headwear, selection: $look.headwearID)
                            pieceRow("Calçado", pieces: AvatarStudioCatalog.boots, selection: $look.bootsID)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .background {
                MedievalBackdropView()
            }
            .navigationTitle("Ateliê do herói")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        inventory.updateAvatarLook(look)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button {
                        look = AvatarLook.seeded(from: inventory.progress.selectedAvatar)
                    } label: {
                        Text("Usar traje de \(inventory.progress.selectedAvatar.name)")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(ForgeSecondaryButtonStyle())

                    Button {
                        inventory.setUsesCustomAvatar(false)
                        dismiss()
                    } label: {
                        Text("Voltar ao retrato clássico")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.ultraThinMaterial)
            }
        }
    }

    private var preview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#C05621")?.opacity(0.35) ?? .orange.opacity(0.3),
                            Color.black.opacity(0.55)
                        ],
                        center: .bottom,
                        startRadius: 20,
                        endRadius: 220
                    )
                )

            AssembledAvatarView(look: look, style: .fullBody)
                .padding(.top, 8)
        }
        .frame(height: 340)
        .padding(.horizontal)
        .overlay(alignment: .bottom) {
            Text("Toque nas peças para montar o corpo e o traje.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.78))
                .padding(.bottom, 10)
        }
    }

    private func pieceRow(
        _ title: String,
        pieces: [AvatarStudioPiece],
        selection: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(pieces) { piece in
                        Button {
                            withAnimation(.easeOut(duration: 0.18)) {
                                selection.wrappedValue = piece.id
                            }
                        } label: {
                            VStack(spacing: 6) {
                                pieceThumb(piece, selected: selection.wrappedValue == piece.id)
                                Text(piece.name)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 88)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(selection.wrappedValue == piece.id ? 0.16 : 0.06))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func pieceThumb(_ piece: AvatarStudioPiece, selected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(Color(hex: piece.accentHex) ?? .orange)
            if let name = AvatarStudioCatalog.previewImageName(for: piece, look: look) {
                Image(name)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFill()
                    .scaleEffect(1.4, anchor: .top)
            }
        }
        .frame(width: 52, height: 52)
        .clipped()
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(.white.opacity(selected ? 0.95 : 0.22), lineWidth: selected ? 2.5 : 1.5)
        }
    }
}
