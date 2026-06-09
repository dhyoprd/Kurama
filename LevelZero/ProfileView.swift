import SwiftUI
import UIKit
import LevelZeroCore

struct ProfileView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var showNotifSettings = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header info
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Theme.neonCyan)
                            .padding(.top, 10)
                        
                        Text(supabase.username)
                            .font(Theme.titleFont(size: 22))
                            .foregroundColor(.white)
                        
                        Text("Class: \((supabase.lifeClass?.rawValue ?? "warrior").capitalized)  |  \(supabase.rankCode)-Rank  |  Lv \(supabase.level)")
                            .font(Theme.statsFont(size: 14))
                            .foregroundColor(Theme.subtext)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    // Share Profile Card Button
                    Button(action: {
                        shareProfileCard()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("SHARE PROFILE CARD")
                                .font(Theme.titleFont(size: 14))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.neonCyan)
                        .cornerRadius(10)
                        .shadow(color: Theme.neonCyan.opacity(0.4), radius: 6)
                    }
                    .padding(.horizontal)
                    
                    // Trophy Room (#14)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TROPHY ROOM")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.neonCyan)
                            .padding(.horizontal)

                        if supabase.trophies.isEmpty {
                            Text("No trophies yet. Conquer a weekly boss to earn your first badge.")
                                .font(Theme.bodyFont(size: 13))
                                .foregroundColor(Theme.subtext)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(supabase.trophies) { trophy in
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle().fill(Theme.gold.opacity(0.15)).frame(width: 44, height: 44)
                                            Image(systemName: "trophy.fill").foregroundColor(Theme.gold)
                                        }
                                        .overlay(Circle().stroke(Theme.gold.opacity(0.4), lineWidth: 1))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(trophy.title)
                                                .font(Theme.titleFont(size: 15))
                                                .foregroundColor(.white)
                                            Text(trophy.badge.replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(Theme.bodyFont(size: 12))
                                                .foregroundColor(Theme.subtext)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Theme.card)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // App settings / account info
                    VStack(spacing: 1) {
                        Button { showSettings = true } label: {
                            ProfileSettingRow(title: "Account Settings", icon: "person.crop.circle")
                        }
                        .buttonStyle(.plain)
                        Button { showNotifSettings = true } label: {
                            ProfileSettingRow(title: "Notifications Configuration", icon: "bell")
                        }
                        .buttonStyle(.plain)
                        Button { showSettings = true } label: {
                            ProfileSettingRow(title: "Intensity Level Options", icon: "slider.horizontal.3")
                        }
                        .buttonStyle(.plain)
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showNotifSettings) { NotificationSettingsView() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .task {
            await supabase.loadProfileStatus()
            await supabase.loadTrophies()
        }
    }

    private var statsForCard: [(String, Int)] {
        [
            ("STR", supabase.stats["strength"] ?? 10), ("INT", supabase.stats["intelligence"] ?? 10),
            ("DIS", supabase.stats["discipline"] ?? 10), ("CHA", supabase.stats["charisma"] ?? 10),
            ("WEA", supabase.stats["wealth"] ?? 10), ("MND", supabase.stats["mind"] ?? 10),
        ]
    }

    @MainActor
    private func shareProfileCard() {
        Task {
            // Pre-load the avatar so it appears in the rendered card.
            var avatarImage: UIImage?
            if let url = supabase.avatarURL, let (data, _) = try? await URLSession.shared.data(from: url) {
                avatarImage = UIImage(data: data)
            }
            let card = ProfileCardView(
                name: supabase.username, rank: supabase.rankCode, level: supabase.level,
                xp: supabase.xp, stats: statsForCard, avatar: avatarImage
            )
            let renderer = ImageRenderer(content: card)
            renderer.scale = 3
            guard let image = renderer.uiImage else { return }
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
                Analytics.log("profile_card_shared")
            }
        }
    }
}

/// Shareable RPG status card (#21) — no sensitive data (no email).
struct ProfileCardView: View {
    let name: String
    let rank: String
    let level: Int
    let xp: Int
    let stats: [(String, Int)]
    let avatar: UIImage?

    var body: some View {
        VStack(spacing: 14) {
            Text("LEVEL ZERO")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.neonCyan)
            Group {
                if let avatar {
                    Image(uiImage: avatar).resizable().scaledToFill()
                } else {
                    Image(systemName: "figure.stand").resizable().scaledToFit().padding(24)
                        .foregroundColor(Theme.neonCyan)
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Theme.neonCyan, lineWidth: 2))

            Text(name).font(.system(size: 24, weight: .bold)).foregroundColor(.white)
            HStack(spacing: 8) {
                Text("LV \(level)").font(.system(size: 14, weight: .bold, design: .monospaced)).foregroundColor(.white)
                Text("\(rank)-RANK")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.background)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Theme.neonCyan).cornerRadius(6)
            }
            RadarChartView(stats: stats).frame(width: 200, height: 200)
            Text("\(xp) / \(level * 100) XP")
                .font(.system(size: 12, design: .monospaced)).foregroundColor(Theme.subtext)
        }
        .padding(28)
        .frame(width: 340)
        .background(Theme.background)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.neonCyan.opacity(0.5), lineWidth: 2))
    }
}

struct RaidBadge {
    let name: String
    let desc: String
    let icon: String
    let color: Color
}

/// Account & settings (#23): change intensity/goals, password reset, delete account.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var supabase = SupabaseManager.shared
    @State private var intensity: Intensity = .normal
    @State private var goals: Set<MainGoal> = []
    @State private var message: String?
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("ACCOUNT & SETTINGS")
                        .font(Theme.titleFont(size: 20)).foregroundColor(Theme.neonCyan)

                    Text("Intensity").font(Theme.statsFont(size: 12)).foregroundColor(Theme.subtext)
                    Picker("", selection: $intensity) {
                        ForEach(Intensity.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    Text("Main goals").font(Theme.statsFont(size: 12)).foregroundColor(Theme.subtext)
                    ForEach(MainGoal.allCases, id: \.self) { g in
                        Button { if goals.contains(g) { goals.remove(g) } else { goals.insert(g) } } label: {
                            HStack {
                                Text(g.displayName).foregroundColor(Theme.text)
                                Spacer()
                                if goals.contains(g) { Image(systemName: "checkmark.circle.fill").foregroundColor(Theme.neonCyan) }
                            }
                            .padding().background(Theme.card).cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        Task {
                            await supabase.updateIntensity(intensity)
                            if !goals.isEmpty { await supabase.updateGoals(Array(goals)) }
                            message = "Saved."
                        }
                    } label: {
                        Text("Save changes").bold()
                            .frame(maxWidth: .infinity).padding()
                            .background(Theme.neonCyan).foregroundColor(Theme.background).cornerRadius(10)
                    }

                    Button {
                        Task { message = (await supabase.sendPasswordReset()) ? "Password reset email sent." : "Could not send reset email." }
                    } label: { Text("Send password reset email").foregroundColor(Theme.neonCyan) }

                    Button { Task { try? await supabase.signOut() } } label: {
                        Text("Sign out").foregroundColor(Theme.gold)
                    }

                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        Text("Delete account").foregroundColor(.red)
                    }

                    if let message {
                        Text(message).font(.caption).foregroundColor(Theme.subtext)
                    }
                }
                .padding(24)
            }
        }
        .onAppear { intensity = supabase.intensity }
        .confirmationDialog("Delete your account and all data? This cannot be undone.",
                            isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete everything", role: .destructive) { Task { await supabase.deleteAccount(); dismiss() } }
            Button("Cancel", role: .cancel) {}
        }
    }
}

/// Notifications settings (#22): toggle + morning reminder time.
struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var enabled = NotificationManager.shared.enabled
    @State private var time: Date = {
        var dc = DateComponents()
        dc.hour = NotificationManager.shared.reminderHour
        dc.minute = NotificationManager.shared.reminderMinute
        return Calendar.current.date(from: dc) ?? Date()
    }()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("NOTIFICATIONS")
                    .font(Theme.titleFont(size: 20)).foregroundColor(Theme.neonCyan)
                Toggle("Enable reminders", isOn: $enabled)
                    .tint(Theme.neonCyan).foregroundColor(Theme.text)
                DatePicker("Morning reminder", selection: $time, displayedComponents: .hourAndMinute)
                    .foregroundColor(Theme.text)
                    .disabled(!enabled)
                Spacer()
                Button {
                    let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                    NotificationManager.shared.reminderHour = comps.hour ?? 9
                    NotificationManager.shared.reminderMinute = comps.minute ?? 0
                    NotificationManager.shared.enabled = enabled
                    dismiss()
                } label: {
                    Text("Save").bold()
                        .frame(maxWidth: .infinity).padding()
                        .background(Theme.neonCyan).foregroundColor(Theme.background).cornerRadius(10)
                }
            }
            .padding(24)
        }
    }
}

struct ProfileSettingRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.neonCyan)
                .frame(width: 24)
            Text(title)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.subtext)
                .font(.footnote)
        }
        .padding()
        .background(Theme.card)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
