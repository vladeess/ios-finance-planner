import Foundation

public struct MCCEntry: Codable, Identifiable, Hashable {
    public var id: Int { code }
    public let code: Int
    public let category: String
    public let icon: String
}
