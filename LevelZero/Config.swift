import Foundation

enum Config {
    static var supabaseURL: URL? {
        guard let urlString = plistValues["SUPABASE_URL"] as? String else { return nil }
        return URL(string: urlString)
    }
    
    static var supabaseAnonKey: String? {
        return plistValues["SUPABASE_ANON_KEY"] as? String
    }
    
    private static var plistValues: [String: Any] {
        guard let path = Bundle.main.path(forResource: "SupabaseConfig", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path),
              let plist = try? PropertyListSerialization.propertyList(from: xml, options: [], format: nil) as? [String: Any] else {
            return [:]
        }
        return plist
    }
}
