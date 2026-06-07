import SwiftUI
import LevelZeroCore

struct DashboardView: View {
    @ObservedObject var supabase = SupabaseManager.shared
    @State private var showingDialogue = false
    @State private var dialogueText = "Welcome back, Hunter. Tap me to check your condition."
    
    // CoreMotion/Gyroscope simulation states
    @State private var tiltOffset: CGFloat = 0
    
    // Stats mapping from LevelZeroCore
    let stats = [
        ("STR", 45),
        ("INT", 18),
        ("DIS", 30),
        ("CHA", 25),
        ("WEA", 12),
        ("MND", 28)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("STATUS HUD")
                                .font(Theme.titleFont(size: 12))
                                .foregroundColor(Theme.neonCyan)
                            Text("JinWoo")
                                .font(Theme.titleFont(size: 24))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                        // Streak badge
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Theme.gold)
                            Text("14 Days")
                                .font(Theme.statsFont(size: 14))
                                .foregroundColor(Theme.gold)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.card)
                        .cornerRadius(8)
                        .shadow(color: Theme.gold.opacity(0.3), radius: 4)
                    }
                    .padding(.horizontal)
                    
                    // Full-Body AI Avatar Card (Interactive)
                    VStack(spacing: 0) {
                        ZStack {
                            // Background glow particles
                            ZStack {
                                Circle()
                                    .fill(Theme.neonCyan.opacity(0.15))
                                    .blur(radius: 30)
                                    .frame(width: 200, height: 200)
                                
                                // Floating codes or magic dots
                                ForEach(0..<15) { i in
                                    Circle()
                                        .fill(Theme.neonCyan)
                                        .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 2...4))
                                        .offset(x: CGFloat.random(in: -80...80), y: CGFloat.random(in: -120...120))
                                }
                            }
                            
                            // Mock Full Body Standing Novice Avatar
                            VStack {
                                Spacer()
                                Image(systemName: "figure.walk.motion")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 160)
                                    .foregroundColor(Theme.neonCyan)
                                    .shadow(color: Theme.neonCyan, radius: 8)
                                    .offset(x: tiltOffset) // Gyroscope simulation offset
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                            tiltOffset = 5
                                        }
                                    }
                                Spacer()
                            }
                            .frame(height: 200)
                            
                            // Dialogue Speech Bubble
                            if showingDialogue {
                                VStack {
                                    HStack {
                                        Text(dialogueText)
                                            .font(Theme.bodyFont(size: 12))
                                            .foregroundColor(.black)
                                            .padding(10)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .overlay(
                                                Triangle()
                                                    .fill(Color.white)
                                                    .frame(width: 15, height: 10)
                                                    .offset(y: 5),
                                                alignment: .bottom
                                            )
                                            .shadow(radius: 4)
                                    }
                                    .padding(.top, -120)
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .background(Theme.card)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.neonCyan.opacity(0.4), lineWidth: 1)
                        )
                        .onTapGesture {
                            triggerDialogue()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Level, Rank & XP Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("LEVEL 14")
                                .font(Theme.titleFont(size: 16))
                                .foregroundColor(.white)
                            Spacer()
                            Text("RANK D")
                                .font(Theme.titleFont(size: 16))
                                .foregroundColor(Theme.neonCyan)
                        }
                        
                        // XP Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 10)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Theme.neonCyan, Theme.purple]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * 0.85, height: 10) // 85% full
                                    .shadow(color: Theme.neonCyan.opacity(0.6), radius: 4)
                            }
                        }
                        .frame(height: 10)
                        
                        Text("XP: 1420 / 1500")
                            .font(Theme.statsFont(size: 12))
                            .foregroundColor(Theme.subtext)
                    }
                    .padding()
                    .background(Theme.card)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Stats Radar Chart Area
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ATTRIBUTE POLYGON")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.neonCyan)
                        
                        HStack(spacing: 20) {
                            // Custom SwiftUI drawing of Radar Chart
                            RadarChartView(stats: stats)
                                .frame(width: 140, height: 140)
                                .padding(.vertical, 10)
                            
                            // Stats values list
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(stats, id: \.0) { stat, val in
                                    HStack {
                                        Text(stat)
                                            .font(Theme.statsFont(size: 14))
                                            .foregroundColor(Theme.subtext)
                                        Spacer()
                                        Text("\(val)")
                                            .font(Theme.statsFont(size: 14))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Theme.card)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Supabase Connection Smoke Check Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SUPABASE INTEGRATION CHECK")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.neonCyan)
                        
                        HStack {
                            Circle()
                                .fill(supabase.isConnected ? Color.green : (supabase.isChecking ? Color.yellow : Color.red))
                                .frame(width: 10, height: 10)
                                .shadow(color: supabase.isConnected ? Color.green : Color.red, radius: 4)
                            
                            Text(supabase.connectionMessage)
                                .font(Theme.bodyFont(size: 12))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            if supabase.isChecking {
                                ProgressView()
                                    .tint(Theme.neonCyan)
                            } else {
                                Button(action: {
                                    Task {
                                        await supabase.checkConnection()
                                    }
                                }) {
                                    Text("Test")
                                        .font(Theme.statsFont(size: 12))
                                        .foregroundColor(Theme.neonCyan)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Theme.card)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Theme.neonCyan, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .padding()
                    .background(Theme.card)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func triggerDialogue() {
        let dialogues = [
            "Your current focus is STR. Keep pushing your body!",
            "Daily quests grant up to +50 XP. Complete them to rank up.",
            "Make sure to read for 10 minutes in the Library to raise INT.",
            "Boss challenge is waiting in the raid room. Clear it this week!",
            "Hunter, remember to rest if your energy gets too low."
        ]
        dialogueText = dialogues.randomElement() ?? ""
        showingDialogue = true
        
        // Hide after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            showingDialogue = false
        }
    }
}

// Helper Shape for Triangle
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Custom Radar Chart View using SwiftUI Path
struct RadarChartView: View {
    let stats: [(String, Int)]
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let maxRadius = min(geo.size.width, geo.size.height) / 2
            
            ZStack {
                // Background grid (3 polygons)
                ForEach(1...3, id: \.self) { step in
                    let r = maxRadius * CGFloat(step) / 3
                    RadarGridPolygon(center: center, radius: r, count: stats.count)
                        .stroke(Theme.subtext.opacity(0.2), lineWidth: 1)
                }
                
                // Axes lines
                ForEach(0..<stats.count, id: \.self) { idx in
                    let angle = CGFloat(idx) * 2 * .pi / CGFloat(stats.count) - .pi / 2
                    let endpoint = CGPoint(
                        x: center.x + maxRadius * cos(angle),
                        y: center.y + maxRadius * sin(angle)
                    )
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: endpoint)
                    }
                    .stroke(Theme.subtext.opacity(0.15), lineWidth: 1)
                }
                
                // Active polygon based on stat values
                RadarValuePolygon(center: center, radius: maxRadius, stats: stats)
                    .fill(Theme.neonCyan.opacity(0.3))
                
                RadarValuePolygon(center: center, radius: maxRadius, stats: stats)
                    .stroke(Theme.neonCyan, lineWidth: 2)
                    .shadow(color: Theme.neonCyan, radius: 4)
            }
        }
    }
}

struct RadarGridPolygon: Shape {
    let center: CGPoint
    let radius: CGFloat
    let count: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for idx in 0..<count {
            let angle = CGFloat(idx) * 2 * .pi / CGFloat(count) - .pi / 2
            let pt = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if idx == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarValuePolygon: Shape {
    let center: CGPoint
    let radius: CGFloat
    let stats: [(String, Int)]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for idx in 0..<stats.count {
            // Normalize value (max value 50)
            let val = CGFloat(stats[idx].1) / 50.0
            let r = radius * val
            let angle = CGFloat(idx) * 2 * .pi / CGFloat(stats.count) - .pi / 2
            let pt = CGPoint(
                x: center.x + r * cos(angle),
                y: center.y + r * sin(angle)
            )
            if idx == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}
