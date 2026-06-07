import SwiftUI

struct QuestBoardView: View {
    @State private var quests = [
        QuestItem(title: "Complete 20-minute Workout", desc: "Build physical strength and discipline", reward: "50 XP • STR +1", diff: "E", isCompleted: false),
        QuestItem(title: "Read Book for 10 minutes", desc: "Focus reading session in app library", reward: "25 XP • INT +1", diff: "E", isCompleted: false),
        QuestItem(title: "Review Weekly Goal Progress", desc: "Maintain absolute clarity of your milestones", reward: "150 XP • MND +3", diff: "C", isCompleted: false)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DUNGEON BOARD")
                            .font(Theme.titleFont(size: 12))
                            .foregroundColor(Theme.neonCyan)
                        Text("Active Quests")
                            .font(Theme.titleFont(size: 24))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Quest list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(quests.indices, id: \.self) { idx in
                            QuestCard(quest: $quests[idx])
                        }
                    }
                    .padding()
                }
            }
            .padding(.top)
        }
    }
}

struct QuestItem {
    let title: String
    let desc: String
    let reward: String
    let diff: String
    var isCompleted: Bool
}

struct QuestCard: View {
    @Binding var quest: QuestItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .stroke(Theme.neonCyan, lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                Text(quest.diff)
                    .font(Theme.titleFont(size: 18))
                    .foregroundColor(Theme.neonCyan)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(Theme.titleFont(size: 16))
                    .foregroundColor(quest.isCompleted ? Theme.subtext : .white)
                    .strikethrough(quest.isCompleted, color: Theme.subtext)
                
                Text(quest.desc)
                    .font(Theme.bodyFont(size: 12))
                    .foregroundColor(Theme.subtext)
                
                Text(quest.reward)
                    .font(Theme.statsFont(size: 12))
                    .foregroundColor(Theme.neonCyan)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Checkmark button
            Button(action: {
                withAnimation {
                    quest.isCompleted.toggle()
                }
            }) {
                Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(quest.isCompleted ? Theme.neonCyan : Theme.subtext)
            }
        }
        .padding()
        .background(Theme.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(quest.isCompleted ? Theme.neonCyan.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct QuestBoardView_Previews: PreviewProvider {
    static var previews: some View {
        QuestBoardView()
            .preferredColorScheme(.dark)
    }
}
