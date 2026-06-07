import SwiftUI

struct Book {
    let id: UUID = UUID()
    let title: String
    let author: String
    let pages: [String]
}

struct LibraryView: View {
    let books = [
        Book(
            title: "Atomic Habits",
            author: "James Clear",
            pages: [
                "Page 1: An atomic habit is a regular practice or routine that is not only small and easy to do but also the source of incredible power.",
                "Page 2: Small changes make a big difference. Success is the product of daily habits—not once-in-a-lifetime transformations.",
                "Page 3: You do not rise to the level of your goals. You fall to the level of your systems.",
                "Page 4: If you want better results, then forget about goals. Focus on your system instead.",
                "Page 5: Habits are the compound interest of self-improvement. Getting 1 percent better every day counts for a lot in the long-run."
            ]
        ),
        Book(
            title: "Deep Work",
            author: "Cal Newport",
            pages: [
                "Page 1: Deep work is the ability to focus without distraction on a cognitively demanding task.",
                "Page 2: High-Quality Work Produced = (Time Spent) x (Intensity of Focus).",
                "Page 3: To produce at your peak level you need to work for extended periods with full concentration.",
                "Page 4: Deep work makes you better at what you do and provides the sense of true fulfillment.",
                "Page 5: Network tools are distracting you from the focus needed to build rare and valuable skills."
            ]
        ),
        Book(
            title: "Meditations",
            author: "Marcus Aurelius",
            pages: [
                "Page 1: You have power over your mind - not outside events. Realize this, and you will find strength.",
                "Page 2: The happiness of your life depends upon the quality of your thoughts.",
                "Page 3: Waste no more time arguing about what a good man should be. Be one.",
                "Page 4: Everything we hear is an opinion, not a fact. Everything we see is a perspective, not the truth.",
                "Page 5: Very little is needed to make a happy life; it is all within yourself, in your way of thinking."
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("WISDOM RAID")
                                .font(Theme.titleFont(size: 12))
                                .foregroundColor(Theme.neonCyan)
                            Text("Reading Library")
                                .font(Theme.titleFont(size: 24))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Catalog list
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(books, id: \.id) { book in
                                NavigationLink(destination: BookReaderView(book: book)) {
                                    BookRow(book: book)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
        }
        .tint(Theme.neonCyan)
    }
}

struct BookRow: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 16) {
            // Mock Cover
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.neonCyan.opacity(0.15))
                    .frame(width: 50, height: 70)
                
                Image(systemName: "book.closed.fill")
                    .foregroundColor(Theme.neonCyan)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Theme.neonCyan.opacity(0.3), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(Theme.titleFont(size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(book.author)
                    .font(Theme.bodyFont(size: 12))
                    .foregroundColor(Theme.subtext)
                
                Text("10-minute Focus Target")
                    .font(Theme.statsFont(size: 10))
                    .foregroundColor(Theme.neonCyan)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.subtext)
        }
        .padding()
        .background(Theme.card)
        .cornerRadius(12)
    }
}

// Book Reader View with Focus Timer and Anti-Idle check
struct BookReaderView: View {
    let book: Book
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPageIdx = 0
    @State private var timeRemaining = 600 // 10 minutes in seconds (demo can be tested)
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    
    // Anti-idle states
    @State private var secondsSinceLastPageTurn = 0
    @State private var showIdleAlert = false
    
    // Reflection states
    @State private var showReflectionModal = false
    @State private var reflectionText = ""
    @State private var xpClaimed = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Top header bar
                HStack {
                    Button(action: {
                        stopTimer()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(book.title)
                        .font(Theme.titleFont(size: 16))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Timer box
                    Text(timeString(timeRemaining))
                        .font(Theme.statsFont(size: 16))
                        .foregroundColor(isRunning ? Theme.neonCyan : Theme.gold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.card)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isRunning ? Theme.neonCyan : Theme.gold, lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Page Content
                VStack {
                    Spacer()
                    Text(book.pages[currentPageIdx])
                        .font(.custom("Georgia", size: 18))
                        .foregroundColor(.white)
                        .lineSpacing(8)
                        .padding(.horizontal, 30)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.card.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Page Controls
                HStack {
                    Button(action: {
                        if currentPageIdx > 0 {
                            currentPageIdx -= 1
                            registerPageTurn()
                        }
                    }) {
                        Text("< Previous")
                            .font(Theme.statsFont(size: 14))
                            .foregroundColor(currentPageIdx > 0 ? Theme.neonCyan : Theme.subtext.opacity(0.3))
                    }
                    .disabled(currentPageIdx == 0)
                    
                    Spacer()
                    
                    Text("Page \(currentPageIdx + 1) of \(book.pages.count)")
                        .font(Theme.bodyFont(size: 12))
                        .foregroundColor(Theme.subtext)
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPageIdx < book.pages.count - 1 {
                            currentPageIdx += 1
                            registerPageTurn()
                        }
                    }) {
                        Text("Next >")
                            .font(Theme.statsFont(size: 14))
                            .foregroundColor(currentPageIdx < book.pages.count - 1 ? Theme.neonCyan : Theme.subtext.opacity(0.3))
                    }
                    .disabled(currentPageIdx == book.pages.count - 1)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                // Start / Pause button
                Button(action: {
                    if isRunning {
                        pauseTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Text(isRunning ? "PAUSE FOCUS" : "START FOCUS (10 MIN)")
                        .font(Theme.titleFont(size: 14))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRunning ? Theme.gold : Theme.neonCyan)
                        .cornerRadius(10)
                        .shadow(color: isRunning ? Theme.gold.opacity(0.4) : Theme.neonCyan.opacity(0.4), radius: 6)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .alert(isPresented: $showIdleAlert) {
            Alert(
                title: Text("Idle Detected"),
                message: Text("Focus session paused. Please read actively to resume."),
                dismissButton: .default(Text("Resume Reading"), action: {
                    registerPageTurn()
                    startTimer()
                })
            )
        }
        .sheet(isPresented: $showReflectionModal) {
            ReflectionView(xpClaimed: $xpClaimed) { takeaway in
                xpClaimed = true
                showReflectionModal = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                secondsSinceLastPageTurn += 1
                
                // Demo speedup/anti-idle limit: 3 minutes (180 seconds)
                // We check if inactive for 180 seconds
                if secondsSinceLastPageTurn >= 180 {
                    pauseTimer()
                    showIdleAlert = true
                }
            } else {
                stopTimer()
                showReflectionModal = true
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        pauseTimer()
    }
    
    private func registerPageTurn() {
        secondsSinceLastPageTurn = 0
    }
    
    private func timeString(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Reflection Modal
struct ReflectionView: View {
    @Binding var xpClaimed: Bool
    @State private var reflectionText = ""
    let onSubmit: (String) -> Void
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("WISDOM ABSORBED")
                    .font(Theme.titleFont(size: 14))
                    .foregroundColor(Theme.neonCyan)
                
                Text("Write down your reflection")
                    .font(Theme.titleFont(size: 20))
                    .foregroundColor(.white)
                
                Text("To claim your reward, write at least one sentence about what you learned from this reading session.")
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(Theme.subtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextEditor(text: $reflectionText)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Theme.card)
                    .cornerRadius(8)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.neonCyan.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Button(action: {
                    if !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSubmit(reflectionText)
                    }
                }) {
                    Text("CLAIM +25 XP")
                        .font(Theme.titleFont(size: 14))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Theme.neonCyan)
                        .cornerRadius(10)
                }
                .disabled(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .preferredColorScheme(.dark)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .preferredColorScheme(.dark)
    }
}
