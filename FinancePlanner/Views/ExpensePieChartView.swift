import SwiftUI
import Charts

public struct CategoryExpense: Identifiable {
    public var id: String { category }
    public let category: String
    public let amount: Double
}

public struct ExpensePieChartView: View {
    public let transactions: [Transaction]
    
    private var chartData: [CategoryExpense] {
        let grouped = Dictionary(grouping: transactions, by: { $0.category })
        return grouped.map { key, values in
            CategoryExpense(category: key, amount: values.reduce(0) { $0 + $1.amount })
        }.sorted { $0.amount > $1.amount }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Структура расходов")
                .font(.headline)
            
            if chartData.isEmpty {
                ContentUnavailableView(
                    "Нет данных",
                    systemImage: "chart.pie",
                    description: Text("Импортируйте выписку для построения аналитики")
                )
                .frame(height: 180)
            } else {
                Chart(chartData) { item in
                    SectorMark(
                        angle: .value("Сумма", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Категория", item.category))
                    .cornerRadius(4)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
