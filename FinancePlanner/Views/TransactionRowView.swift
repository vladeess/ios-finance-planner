import SwiftUI

public struct TransactionRowView: View {
    public let transaction: Transaction
    private let mccService = MCCDirectoryService.shared
    
    public var body: some View {
        HStack(spacing: 12) {
            let info = mccService.resolveCategory(for: transaction.mcc)
            Image(systemName: info.icon)
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category)
                    .font(.body)
                    .fontWeight(.medium)
                Text("\(transaction.accountName) • MCC \(transaction.mcc)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "-%.2f ₽", transaction.amount))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                Text(transaction.date.formatted(date: .numeric, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
