import SwiftUI

struct BossRaidView: View {
    @State private var bossHealth: Double = 1.0 // 100%
    @State private var tasks = [
        RaidTask(title: "Complete 3 Workout Sessions", target: 3, current: 2),
        RaidTask(title: "Log 30 minutes of Focus Reading", target: 3, current: 1),
        RaidTask(title: "Save Rp100.000 this week", target: 1, current: 0)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
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
                    
                    // Boss Card with health bar
                    VStack(spacing: 12) {
                        Image(systemName: "flame.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Theme.purple)
                            .shadow(color: Theme.purple, radius: 10)
                            .padding(.top, 10)
                        
                        Text("IGRIS THE RED")
                            .font(Theme.titleFont(size: 20))
                            .foregroundColor(.white)
                        
                        Text("S-Rank Challenger")
                            .font(Theme.statsFont(size: 12))
                            .foregroundColor(Theme.purple)
                        
                        // HP bar
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("HP: \(Int(bossHealth * 100))%")
                                    .font(Theme.statsFont(size: 12))
                                    .foregroundColor(Theme.subtext)
                                Spacer()
                                Text("Time Left: 2d 5h")
                                    .font(Theme.statsFont(size: 12))
                                    .foregroundColor(Theme.gold)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Theme.purple, Color.red]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * CGFloat(bossHealth), height: 10)
                                        .shadow(color: Theme.purple.opacity(0.6), radius: 4)
                                }
                            }
                            .frame(height: 10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    }
                    .background(Theme.card)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.purple.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Raid Targets Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RAID TARGETS")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.neonCyan)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(tasks.indices, id: \.self) { idx in
                                RaidTaskRow(task: $tasks[idx]) {
                                    updateBossHealth()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Reward info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("VICTORY REWARDS")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.gold)
                        
                        HStack {
                            Image(systemName: "suit.diamond.fill")
                                .foregroundColor(Theme.gold)
                            Text("+1000 XP • ALL STATS +5 • Elite Badge")
                                .font(Theme.statsFont(size: 13))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.card)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
        }
        .onAppear {
            updateBossHealth()
        }
    }
    
    private func updateBossHealth() {
        let totalTarget = tasks.reduce(0) { $0 + $1.target }
        let totalCurrent = tasks.reduce(0) { $0 + min($1.current, $1.target) }
        
        if totalTarget > 0 {
            // HP starts at 100%, drops as current goals are finished
            bossHealth = 1.0 - (Double(totalCurrent) / Double(totalTarget))
        } else {
            bossHealth = 0
        }
    }
}

struct RaidTask {
    let title: String
    let target: Int
    var current: Int
}

struct RaidTaskRow: View {
    @Binding var task: RaidTask
    let onProgressUpdate: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(Theme.titleFont(size: 14))
                    .foregroundColor(.white)
                
                Text("Progress: \(task.current) / \(task.target)")
                    .font(Theme.statsFont(size: 12))
                    .foregroundColor(Theme.neonCyan)
            }
            
            Spacer()
            
            // Incrementor
            HStack(spacing: 12) {
                Button(action: {
                    if task.current > 0 {
                        task.current -= 1
                        onProgressUpdate()
                    }
                }) {
                    Image(systemName: "minus.square.fill")
                        .foregroundColor(Theme.subtext)
                        .font(.title3)
                }
                .disabled(task.current == 0)
                
                Button(action: {
                    if task.current < task.target {
                        task.current += 1
                        onProgressUpdate()
                    }
                }) {
                    Image(systemName: "plus.square.fill")
                        .foregroundColor(Theme.neonCyan)
                        .font(.title3)
                }
                .disabled(task.current == task.target)
            }
        }
        .padding()
        .background(Theme.card)
        .cornerRadius(10)
    }
}

struct BossRaidView_Previews: PreviewProvider {
    static var previews: some View {
        BossRaidView()
            .preferredColorScheme(.dark)
    }
}
