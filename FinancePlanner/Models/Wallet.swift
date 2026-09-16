import Foundation
import SwiftData

@Model
public final class Wallet {
    @Attribute(.unique) public var name: String
    public var balance: Double
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.wallet)
    public var transactions: [Transaction] = []
    
    public init(name: String, balance: Double = 0.0) {
        self.name = name
        self.balance = balance
    }
}
