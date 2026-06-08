import SwiftUI
import LevelZeroCore

struct LibraryView: View {
    @StateObject private var supabase = SupabaseManager.shared
    @State private var selected: SupabaseManager.BookVM?

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("LIBRARY")
                        .font(Theme.titleFont(size: 24)).foregroundColor(.white)
                        .padding(.horizontal)
                    Text("Read for 10 focused minutes to absorb wisdom (+25 XP).")
                        .font(Theme.bodyFont(size: 13)).foregroundColor(Theme.subtext)
                        .padding(.horizontal)

                    if supabase.books.isEmpty {
                        Text("Loading library...")
                            .foregroundColor(Theme.subtext).padding()
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(supabase.books) { book in
                                Button { selected = book } label: { bookCard(book) }
                                    .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .task { await supabase.loadBooks() }
        .fullScreenCover(item: $selected) { ReaderView(book: $0) }
    }

    private func bookCard(_ book: SupabaseManager.BookVM) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Theme.card).frame(height: 150)
                Image(systemName: book.coverSymbol)
                    .font(.system(size: 44)).foregroundColor(Theme.neonCyan)
            }
            Text(book.title).font(Theme.bodyFont(size: 15)).foregroundColor(Theme.text).lineLimit(1)
            Text(book.author).font(Theme.bodyFont(size: 12)).foregroundColor(Theme.subtext).lineLimit(1)
        }
    }
}

/// 10-minute focus reader driven by the ReadingFocusTimer core reducer.
struct ReaderView: View {
    let book: SupabaseManager.BookVM
    @StateObject private var supabase = SupabaseManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var session = ReadingSession()
    @State private var pageIndex = 0
    @State private var takeaway = ""
    @State private var showReflection = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var remaining: Int { max(0, ReadingFocusTimer.focusDuration - session.elapsed) }
    private var timeString: String { String(format: "%02d:%02d", remaining / 60, remaining % 60) }

    var body: some View {
        ZStack {
            Color(hex: "1A1510").ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "xmark").foregroundColor(Theme.subtext) }
                    Spacer()
                    Text(book.title).font(Theme.titleFont(size: 14)).foregroundColor(.white)
                    Spacer()
                    Label(timeString, systemImage: "timer")
                        .font(Theme.statsFont(size: 14)).foregroundColor(Theme.neonCyan)
                }
                .padding()

                ScrollView {
                    Text(book.pages.indices.contains(pageIndex) ? book.pages[pageIndex] : "")
                        .font(.system(size: 19, design: .serif))
                        .foregroundColor(Color(hex: "EDE6D8"))
                        .lineSpacing(8)
                        .padding(24)
                }

                HStack {
                    Button { turn(-1) } label: { Text("‹ Prev").foregroundColor(Theme.neonCyan) }
                        .disabled(pageIndex == 0)
                    Spacer()
                    Text("Page \(pageIndex + 1) of \(book.pages.count)")
                        .font(Theme.statsFont(size: 12)).foregroundColor(Theme.subtext)
                    Spacer()
                    Button { turn(1) } label: { Text("Next ›").foregroundColor(Theme.neonCyan) }
                        .disabled(pageIndex >= book.pages.count - 1)
                }
                .padding()
            }

            if session.phase == .paused {
                Color.black.opacity(0.75).ignoresSafeArea()
                VStack(spacing: 14) {
                    Text("Are you still reading?")
                        .font(Theme.titleFont(size: 18)).foregroundColor(.white)
                    Button { resume() } label: {
                        Text("Keep reading").bold()
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(Theme.neonCyan).foregroundColor(Theme.background).cornerRadius(10)
                    }
                }
            }
        }
        .onReceive(ticker) { _ in
            guard session.phase == .reading else { return }
            session = ReadingFocusTimer.reduce(session, .tick)
            if session.phase == .awaitingReflection { showReflection = true }
        }
        .sheet(isPresented: $showReflection) { reflectionSheet }
    }

    private func turn(_ delta: Int) {
        pageIndex = max(0, min(book.pages.count - 1, pageIndex + delta))
        session = ReadingFocusTimer.reduce(session, .pageTurn)
    }

    private func resume() {
        session = ReadingFocusTimer.reduce(session, .pageTurn)
    }

    private var reflectionSheet: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("ABSORB WISDOM")
                    .font(Theme.titleFont(size: 20)).foregroundColor(Theme.neonCyan)
                Text("What did you learn? (one sentence)")
                    .foregroundColor(Theme.subtext)
                TextField("Your takeaway...", text: $takeaway, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .padding().background(Theme.card).cornerRadius(8).foregroundColor(Theme.text)
                Button {
                    session = ReadingFocusTimer.reduce(session, .submitTakeaway(takeaway))
                    if session.phase == .claimed {
                        let secs = session.elapsed
                        let text = takeaway
                        Task {
                            await supabase.saveReadingSession(bookId: book.id, takeaway: text, durationSeconds: secs)
                            showReflection = false
                            dismiss()
                        }
                    }
                } label: {
                    Text("Claim +25 XP").bold()
                        .frame(maxWidth: .infinity).padding()
                        .background(Theme.neonCyan).foregroundColor(Theme.background).cornerRadius(10)
                }
                .disabled(takeaway.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(24)
        }
        .interactiveDismissDisabled(true)
    }
}
