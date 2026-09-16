import Foundation

public final class MCCDirectoryService {
    public static let shared = MCCDirectoryService()
    private var directory: [Int: MCCEntry] = [:]
    
    private init() {
        loadDirectory()
    }
    
    private func loadDirectory() {
        guard let url = Bundle.main.url(forResource: "mcc_codes", withExtension: "json") else {
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let entries = try JSONDecoder().decode([MCCEntry].self, from: data)
            self.directory = Dictionary(uniqueKeysWithValues: entries.map { ($0.code, $0) })
        } catch {
            print("Failed to decode MCC directory: \(error)")
        }
    }
    
    public func resolveCategory(for mcc: Int) -> (category: String, icon: String) {
        if let match = directory[mcc] {
            return (match.category, match.icon)
        }
        return ("Прочее", "questionmark.circle")
    }
}
