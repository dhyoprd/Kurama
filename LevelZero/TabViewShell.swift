import SwiftUI

struct TabViewShell: View {
    @State private var selectedTab = 0
    
    init() {
        // Customize TabBar appearance for dark RPG theme
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.background)
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(Theme.subtext)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.subtext)]
        itemAppearance.selected.iconColor = UIColor(Theme.neonCyan)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.neonCyan)]
        
        appearance.stackedLayoutAppearance = itemAppearance
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Status", systemImage: "person.fill")
                }
                .tag(0)
            
            QuestBoardView()
                .tabItem {
                    Label("Quests", systemImage: "scroll.fill")
                }
                .tag(1)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "book.fill")
                }
                .tag(2)
            
            BossRaidView()
                .tabItem {
                    Label("Boss", systemImage: "flame.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Trophy", systemImage: "trophy.fill")
                }
                .tag(4)
        }
        .tint(Theme.neonCyan)
        .background(Theme.background.ignoresSafeArea())
    }
}

struct TabViewShell_Previews: PreviewProvider {
    static var previews: some View {
        TabViewShell()
            .preferredColorScheme(.dark)
    }
}
