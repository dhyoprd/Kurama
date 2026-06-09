import SwiftUI
import LevelZeroCore

/// Weekly Boss Raid Room (#12): HP bar depletes as requirements are checked off;
/// conquer before the Sunday deadline for the reward.
struct BossRaidView: View {
    @StateObject private var supabase = SupabaseManager.shared

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    header
                    if let boss = supabase.boss {
                        bossCard(boss)
                    } else {
                        Text("Summoning this week's boss...")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundColor(Theme.subtext)
                            .padding(.top, 60)
                    }
                }
                .padding(.vertical)
            }
        }
        .task {
            await supabase.loadProfileStatus()
            await supabase.loadOrSpawnWeeklyBoss()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("BOSS DUNGEON")
                    .font(Theme.titleFont(size: 12))
                    .foregroundColor(Theme.purple)
                Text("Weekly Boss Raid")
                    .font(Theme.titleFont(size: 24))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private func bossCard(_ boss: SupabaseManager.BossVM) -> some View {
        let hp = boss.required > 0 ? max(0, 1 - Double(boss.progress) / Double(boss.required)) : 0
        let ready = boss.progress >= boss.required
        return VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundColor(Theme.purple)
                .shadow(color: Theme.purple, radius: 16)

            Text(boss.title)
                .font(Theme.titleFont(size: 20))
                .foregroundColor(.white)
            Text(boss.description)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.subtext)
                .multilineTextAlignment(.center)

            // HP bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("BOSS HP").font(Theme.statsFont(size: 11)).foregroundColor(Theme.subtext)
                    Spacer()
                    Text("\(boss.progress)/\(boss.required) cleared")
                        .font(Theme.statsFont(size: 11)).foregroundColor(Theme.subtext)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.card).frame(height: 14)
                        Capsule().fill(Theme.purple)
                            .frame(width: geo.size.width * hp, height: 14)
                            .shadow(color: Theme.purple, radius: 4)
                    }
                }
                .frame(height: 14)
            }

            Text(countdown(to: boss.deadline))
                .font(Theme.statsFont(size: 12))
                .foregroundColor(Theme.gold)

            switch boss.status {
            case "completed":
                Label("BOSS DEFEATED", systemImage: "trophy.fill")
                    .font(Theme.titleFont(size: 16))
                    .foregroundColor(Theme.gold)
            case "failed":
                Text("The boss escaped this week. A new one arrives Monday.")
                    .font(Theme.bodyFont(size: 13))
                    .foregroundColor(Theme.subtext)
                    .multilineTextAlignment(.center)
            default:
                VStack(spacing: 10) {
                    Button {
                        Task { await supabase.bossAttack() }
                    } label: {
                        Text("Strike (clear a requirement)")
                            .bold().frame(maxWidth: .infinity).padding()
                            .background(ready ? Theme.card : Theme.purple)
                            .foregroundColor(.white).cornerRadius(10)
                    }
                    .disabled(ready)

                    Button {
                        Task { await supabase.conquerBoss() }
                    } label: {
                        Text("Conquer Boss  (+\(boss.xpReward) XP)")
                            .bold().frame(maxWidth: .infinity).padding()
                            .background(ready ? Theme.gold : Theme.card)
                            .foregroundColor(ready ? Theme.background : Theme.subtext)
                            .cornerRadius(10)
                    }
                    .disabled(!ready)

                    if WeeklyBossLifecycle.canReroll(
                        BossState(status: .active, weekStart: boss.weekStart, rerollsUsed: boss.rerollsUsed),
                        now: Date()
                    ) {
                        Button {
                            Task { await supabase.rerollBoss() }
                        } label: {
                            Text("Reroll boss (1 left, until Wed)")
                                .font(Theme.bodyFont(size: 13))
                                .foregroundColor(Theme.subtext)
                                .underline()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Theme.card.opacity(0.6))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.purple.opacity(0.5), lineWidth: 1))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func countdown(to deadline: Date) -> String {
        let remaining = max(0, deadline.timeIntervalSinceNow)
        let days = Int(remaining) / 86400
        let hours = (Int(remaining) % 86400) / 3600
        return "Ends in \(days)d \(hours)h"
    }
}
