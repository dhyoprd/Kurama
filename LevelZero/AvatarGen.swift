import SwiftUI
import PhotosUI
import UIKit
import LevelZeroCore

/// Selfie -> Level 1 full-body avatar via the generate-avatar Edge Function.
struct AvatarGenView: View {
    @StateObject private var supa = SupabaseManager.shared
    @State private var item: PhotosPickerItem?
    @State private var selfie: Data?
    @State private var loading = false
    @State private var message: String?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("FORGE YOUR AVATAR")
                    .font(.title.bold())
                    .foregroundStyle(Theme.neonCyan)
                Text("Upload a selfie to generate your Level 1 character.")
                    .foregroundStyle(Theme.subtext)
                    .multilineTextAlignment(.center)

                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Theme.card)
                        .frame(width: 200, height: 200)
                    if let selfie, let ui = UIImage(data: selfie) {
                        Image(uiImage: ui).resizable().scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Image(systemName: "person.crop.square.badge.camera")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.subtext)
                    }
                }

                PhotosPicker(selection: $item, matching: .images) {
                    Text(selfie == nil ? "Choose selfie" : "Change selfie")
                        .foregroundStyle(Theme.neonCyan)
                }

                if let message {
                    Text(message).font(.caption)
                        .foregroundStyle(Theme.gold)
                        .multilineTextAlignment(.center)
                }

                Button(action: generate) {
                    HStack {
                        if loading { ProgressView().tint(Theme.background) }
                        Text("Generate avatar").bold()
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(selfie == nil ? Theme.card : Theme.neonCyan)
                    .foregroundStyle(selfie == nil ? Theme.subtext : Theme.background)
                    .cornerRadius(10)
                }
                .disabled(selfie == nil || loading)

                Button("Skip for now") { supa.skipAvatar() }
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
            }
            .padding(24)
        }
        .onChange(of: item) { newItem in
            Task {
                if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                    selfie = data
                }
            }
        }
    }

    private func generate() {
        guard let selfie else { return }
        loading = true
        message = nil
        let cls = supa.lifeClass ?? .warrior
        let prompt = AvatarPromptSelector.prompt(rank: .e, lifeClass: cls)
        Task {
            do {
                try await supa.uploadSelfie(selfie)
                try await supa.generateAvatar(prompt: prompt)
            } catch {
                message = "Generation failed: \(error.localizedDescription)\nRetry or skip."
            }
            loading = false
        }
    }
}
