import Foundation
import SwiftData

@Model
public final class Transaction {
    @Attribute(.unique) public var id: UUID
    public var mcc: Int
    public var category: String
    public var amount: Double
    public var date: Date
    public var accountName: String
    public var note: String
    
    public var wallet: Wallet?
    
    public init(
        id: UUID = UUID(),
        mcc: Int,
        category: String,
        amount: Double,
        date: Date = Date(),
        accountName: String,
        note: String = ""
    ) {
        self.id = id
        self.mcc = mcc
        self.category = category
        self.amount = amount
        self.date = date
        self.accountName = accountName
        self.note = note
    }
}
