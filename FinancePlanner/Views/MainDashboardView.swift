import SwiftUI
import SwiftData

public struct MainDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = FinanceViewModel()
    
    @Query private var wallets: [Wallet]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var isPickerPresented = false
    
    private var filteredTransactions: [Transaction] {
        if let filter = viewModel.selectedCategoryFilter, !filter.isEmpty {
            return transactions.filter { $0.category == filter }
        }
        return transactions
    }
    
    private var categories: [String] {
        Array(Set(transactions.map { $0.category })).sorted()
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(wallets) { wallet in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(wallet.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.2f ₽", wallet.balance))
                                        .font(.headline)
                                }
                                .padding()
                                .frame(width: 170, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    ExpensePieChartView(transactions: transactions)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(title: "Все", isSelected: viewModel.selectedCategoryFilter == nil) {
                                viewModel.selectedCategoryFilter = nil
                            }
                            ForEach(categories, id: \.self) { cat in
                                FilterChip(title: cat, isSelected: viewModel.selectedCategoryFilter == cat) {
                                    viewModel.selectedCategoryFilter = cat
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    .listRowBackground(Color.clear)
                }
                
                Section("История транзакций") {
                    if filteredTransactions.isEmpty {
                        Text("Нет операций")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(filteredTransactions) { tx in
                            NavigationLink(destination: TransactionDetailView(transaction: tx)) {
                                TransactionRowView(transaction: tx)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Финансы")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { viewModel.importSampleDataDirectly(context: modelContext) }) {
                        Label("Демо", systemImage: "sparkles")
                    }
                    Button(action: { isPickerPresented = true }) {
                        Label("Импорт", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let fileUrl = urls.first else { return }
                    viewModel.importBankStatement(from: fileUrl, context: modelContext)
                case .failure(let err):
                    viewModel.errorMessage = err.localizedDescription
                    viewModel.hasError = true
                }
            }
            .alert("Ошибка импорта", isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Успешно", isPresented: $viewModel.isShowingSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.successMessage ?? "")
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
