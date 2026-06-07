import SwiftUI

struct ProfileView: View {
    let badges = [
        RaidBadge(name: "Novice Clear", desc: "Defeated E-Rank Boss", icon: "shield.fill", color: Theme.neonCyan),
        RaidBadge(name: "Iron Conqueror", desc: "Defeated D-Rank Boss", icon: "hammer.fill", color: Theme.subtext),
        RaidBadge(name: "Aura Master", desc: "Reached 10-day reading streak", icon: "flame.fill", color: Theme.gold)
    ]
    
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
                        
                        Text("JinWoo")
                            .font(Theme.titleFont(size: 22))
                            .foregroundColor(.white)
                        
                        Text("Class: Warrior | Rank: D-Rank")
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
                    
                    // Badges Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COLLECTED BADGES")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.neonCyan)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(badges, id: \.name) { badge in
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(badge.color.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: badge.icon)
                                            .foregroundColor(badge.color)
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(badge.color.opacity(0.4), lineWidth: 1)
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(badge.name)
                                            .font(Theme.titleFont(size: 15))
                                            .foregroundColor(.white)
                                        
                                        Text(badge.desc)
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
                    
                    // App settings / account info
                    VStack(spacing: 1) {
                        ProfileSettingRow(title: "Account Settings", icon: "person.crop.circle")
                        ProfileSettingRow(title: "Notifications Configuration", icon: "bell")
                        ProfileSettingRow(title: "Intensity Level Options", icon: "slider.horizontal.3")
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func shareProfileCard() {
        // Mock share behavior
        let activityVC = UIActivityViewController(activityItems: ["Level Zero Profile - JinWoo. Level: 14, Rank: D-Rank. Stats: STR 45, INT 18, DIS 30."], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

struct RaidBadge {
    let name: String
    let desc: String
    let icon: String
    let color: Color
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
