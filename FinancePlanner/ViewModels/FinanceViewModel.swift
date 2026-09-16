import Foundation
import Combine
import SwiftData

@MainActor
public final class FinanceViewModel: ObservableObject {
    @Published public var selectedCategoryFilter: String? = nil
    @Published public var isImporting: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var hasError: Bool = false
    @Published public var successMessage: String? = nil
    @Published public var isShowingSuccess: Bool = false
    
    private let pipeline = StatementImportPipeline()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    public func importBankStatement(from url: URL, context: ModelContext) {
        isImporting = true
        
        pipeline.processFile(at: url)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isImporting = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.hasError = true
                    }
                },
                receiveValue: { [weak self] records in
                    guard let self = self else { return }
                    self.saveImportedRecords(records, in: context)
                }
            )
            .store(in: &cancellables)
    }
    
    public func importSampleDataDirectly(context: ModelContext) {
        guard let sampleUrl = Bundle.main.url(forResource: "sample_statement", withExtension: "json") ??
                              Bundle.module.url(forResource: "sample_statement", withExtension: "json") else {
            self.errorMessage = "Демо-файл не найден в Bundle."
            self.hasError = true
            return
        }
        importBankStatement(from: sampleUrl, context: context)
    }
    
    private func saveImportedRecords(_ records: [ParsedRecord], in context: ModelContext) {
        var addedCount = 0
        
        for record in records {
            let targetId = record.id
            var fetchDescriptor = FetchDescriptor<Transaction>(
                predicate: #Predicate { $0.id == targetId }
            )
            fetchDescriptor.fetchLimit = 1
            
            if let existing = try? context.fetch(fetchDescriptor), !existing.isEmpty {
                continue
            }
            
            let account = record.accountName
            var walletDescriptor = FetchDescriptor<Wallet>(
                predicate: #Predicate { $0.name == account }
            )
            walletDescriptor.fetchLimit = 1
            
            let wallet: Wallet
            if let foundWallet = try? context.fetch(walletDescriptor).first {
                wallet = foundWallet
            } else {
                let newWallet = Wallet(name: record.accountName, balance: 10000.0)
                context.insert(newWallet)
                wallet = newWallet
            }
            
            let tx = Transaction(
                id: record.id,
                mcc: record.mcc,
                category: record.category,
                amount: record.amount,
                date: record.date,
                accountName: record.accountName,
                note: record.note
            )
            tx.wallet = wallet
            wallet.balance -= tx.amount
            context.insert(tx)
            addedCount += 1
        }
        
        try? context.save()
        self.successMessage = "Импортировано записей: \(addedCount)"
        self.isShowingSuccess = true
    }
}
