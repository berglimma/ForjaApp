//
//  AssembledAvatarView.swift
//  ForjaApp
//

import SwiftUI
import UIKit

struct AssembledAvatarView: View {
    let look: AvatarLook
    var style: Style = .fullBody

    enum Style {
        case fullBody
        case bust
    }

    var body: some View {
        Group {
            switch style {
            case .fullBody:
                layers
            case .bust:
                layers
                    .scaleEffect(1.55, anchor: .top)
                    .frame(width: 220, height: 220, alignment: .top)
                    .clipped()
            }
        }
        .accessibilityHidden(true)
    }

    private var layers: some View {
        ZStack {
            cloakLayer
            dressedFigure
            bootsLayer
            headwearLayer
        }
        .overlay {
            LinearGradient(
                colors: [
                    AvatarStudioCatalog.hairTint(look.hairColorID).opacity(0.18),
                    .clear
                ],
                startPoint: .top,
                endPoint: .center
            )
            .blendMode(.overlay)
            .allowsHitTesting(false)
        }
        .frame(width: 220, height: 320)
    }

    private var dressedFigure: some View {
        let name = AvatarStudioCatalog.chestImageName(for: look)
            ?? AvatarStudioCatalog.bodyImageName(for: look)
        return Image(name)
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 220, height: 320)
            .overlay {
                AvatarStudioCatalog.skinTint(look.skinID)
                    .opacity(look.skinID == "tan" ? 0.04 : 0.18)
                    .blendMode(.multiply)
                    .mask {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 320)
                    }
            }
            .shadow(color: .black.opacity(0.35), radius: 8, y: 6)
    }

    @ViewBuilder
    private var cloakLayer: some View {
        if look.cloakID != "none" {
            Image("StudioCloak_drape")
                .resizable()
                .renderingMode(.original)
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 128, height: 168)
                .offset(y: 22)
                .overlay {
                    if look.cloakID == "royal" {
                        Color(hex: "#B7791F")?.opacity(0.32)
                            .blendMode(.overlay)
                            .mask {
                                Image("StudioCloak_drape")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 128, height: 168)
                            }
                    }
                }
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var bootsLayer: some View {
        if look.bootsID == "plate", let name = AvatarStudioCatalog.boots(look.bootsID).imageName {
            ZStack {
                bootSlice(named: name, side: .left)
                    .frame(width: 44, height: 76)
                    .position(x: 78, y: 276)
                bootSlice(named: name, side: .right)
                    .frame(width: 44, height: 76)
                    .position(x: 139, y: 276)
            }
            .frame(width: 220, height: 320)
            .allowsHitTesting(false)
        }
    }

    private enum BootSide {
        case left, right
    }

    private func bootSlice(named name: String, side: BootSide) -> some View {
        Image(uiImage: Self.slicedBoot(named: name, side: side))
            .resizable()
            .renderingMode(.original)
            .interpolation(.high)
            .scaledToFit()
    }

    private static func slicedBoot(named name: String, side: BootSide) -> UIImage {
        guard let image = UIImage(named: name), let cgImage = image.cgImage else {
            return UIImage()
        }
        let width = cgImage.width
        let height = cgImage.height
        let rect: CGRect = {
            switch side {
            case .left:
                return CGRect(x: 0, y: 0, width: width / 2, height: height)
            case .right:
                return CGRect(x: width / 2, y: 0, width: width - width / 2, height: height)
            }
        }()
        guard let cropped = cgImage.cropping(to: rect) else { return image }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }

    @ViewBuilder
    private var headwearLayer: some View {
        if let name = AvatarStudioCatalog.headwear(look.headwearID).imageName {
            let hood = look.headwearID == "hood"
            let feminine = look.physiqueID == "feminine"
            VStack {
                Image(name)
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: hood ? 50 : 42, height: hood ? 58 : 48)
                    .padding(.top, hood ? (feminine ? 8 : 0) : 3)
                Spacer()
            }
            .frame(width: 220, height: 320)
            .allowsHitTesting(false)
        }
    }
}
