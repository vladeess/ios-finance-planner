import SwiftUI

public struct TransactionDetailView: View {
    public let transaction: Transaction
    
    public var body: some View {
        List {
            Section("Основные параметры") {
                LabeledContent("Сумма", value: String(format: "%.2f ₽", transaction.amount))
                LabeledContent("Категория", value: transaction.category)
                LabeledContent("MCC-код", value: "\(transaction.mcc)")
            }
            
            Section("Транзакционные данные") {
                LabeledContent("Счет / Кошелек", value: transaction.accountName)
                LabeledContent("Дата и время", value: transaction.date.formatted(date: .complete, time: .standard))
                if !transaction.note.isEmpty {
                    LabeledContent("Примечание", value: transaction.note)
                }
            }
            
            Section("Идентификатор") {
                Text(transaction.id.uuidString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle("Детали операции")
        .navigationBarTitleDisplayMode(.inline)
    }
}
