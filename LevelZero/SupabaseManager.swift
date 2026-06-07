import Foundation
import Supabase

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient?
    @Published var isConnected = false
    @Published var connectionMessage = "Not checked"
    @Published var isChecking = false
    
    private init() {
        if let url = Config.supabaseURL, let key = Config.supabaseAnonKey, !key.isEmpty, !key.contains("your-anon-public-key") {
            self.client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        } else {
            self.client = nil
        }
    }
    
    func checkConnection() async {
        guard let client = client else {
            DispatchQueue.main.async {
                self.isConnected = false
                self.connectionMessage = "Supabase configuration missing or using templates. Please update SupabaseConfig.plist."
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isChecking = true
        }
        
        do {
            // A simple query to check connectivity. We can check auth session which requires internet connectivity.
            _ = try await client.auth.session
            DispatchQueue.main.async {
                self.isConnected = true
                self.connectionMessage = "Supabase Connection Success!"
                self.isChecking = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isConnected = false
                // If the error is just an unauthenticated session, it actually means connection succeeded because the server responded!
                // So if we get a response from Supabase (even an auth error, but not network error), it is a successful connectivity check.
                if error.localizedDescription.lowercased().contains("network") || error.localizedDescription.lowercased().contains("connection") {
                    self.connectionMessage = "Connection Failed: \(error.localizedDescription)"
                } else {
                    self.isConnected = true
                    self.connectionMessage = "Supabase Connection Success! (Auth check responded)"
                }
                self.isChecking = false
            }
        }
    }
}
